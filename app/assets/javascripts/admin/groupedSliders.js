	$(document).ready(function(){
		createSliders();
	});

	//runs when the document loads
	//$(function() {
	function createSliders(){
	
		// iterate over ever sliderGroup div found in the document to turn it into a grouped slider system.
		$( ".sliderGroup span:.slide" ).each(function() {
			// read initial values from markup and remove that
			var value = parseInt( $( this ).text(), 10 );
		
			//figure out if the bar will be locked from the start, and if so, set it to locked.
			if($(this).attr('locked') == null)
			{
				$(this).attr('locked','false');
			}

			//now create the actual sliders
			$( this ).empty().slider({
				value: value,
				min:  parseInt($(this).parents('#eq').attr('min'),10), //read min value from the div
				max:  parseInt($(this).parents('#eq').attr('max'),10), //read max value from the div
				animate: true,
				orientation: "horizontal",
				change: function(event, ui)
				{
					//when slider changes, make sure to update the visual totals under the bars.
					//this is a little weird. The value reported by the $(this).slider('value') is one off for the bar that is triggering 
					//this event. So we get the active bars value from the ui.value passed in, and sum the rest of bars, excluding the active one.					
					$( "#eq"+" span:.slide" ).each(function() 
					{
						$('#sliderTally_eq_'+$(this).attr('id')).html($(this).slider("value") + '%');

						//this updates the headings which show section totals. 
						var headingVal = 0;
						//we iterate through each slider and count the values together
						$(this).parent().parent().parent().find('.sliderGroupTally').each(function(index, value) {
						  	headingVal = headingVal + parseInt($(value).html());
						})
						$(this).parent().parent().parent().find('.headingValue').html(headingVal + "%");
						var sectionName = $(this).parent().parent().parent().attr('id');
						//we also have to store sectionTotals into JSON.
						reqJsonObj.SectionTotals[sectionName] = headingVal;
			
					});	
									
				},
				slide: function(event, ui){
					
					//set the default max percent incase the user forgets to set one.
					var percentTotal = 100;
					
					//if the user set one, use that instead.
					if($(this).parents('#eq').attr('total') != null)
					{	
						percentTotal = parseInt($(this).parents('#eq').attr('total'),10)
						
					}				
					
					//get some variables we will need.	
					var parentId = $(this).parents('#eq').attr('id');
					var activeSlider = 	$(this).attr('id');
					
					var validSliders = $( "#"+parentId+" span[locked='false']" );
					var allSliderIds = new Object();
					var validSliderIds = new Object();
					
				
					//figure out the total of all bars added together. Same as in the change function, to get the total sum we
					//have to use ui.value for the current slider, and $(this).slider("value") for the rest to get accurate values.
					//also we need to populate an object with the id's any any valid sliders that we can try to use to balance our total later.
					var total = ui.value;
					$( "#"+parentId+" span:.slide" ).each(function() {	
						allSliderIds[$(this).attr('id')] = $(this).attr('id');			
						if($(this).attr('id') != activeSlider)
						{
							total += parseInt($(this).slider("value"),10);
						}
					});	
					
					
					//figure out if the bar moved up or down, so we know if we neeed to add or subtract to anothe bar to keep at our target percentTotal				
					var sign = (percentTotal - total) > 0 ? 1 : (percentTotal - total) == 0 ? 0 : -1;
					
					//get the total amount of points we need to distribute among the bars. If the user slide the bar mroe than one integer value,
					//this number will get larger.
					var distributeDelta = Math.abs(percentTotal-total);

					while(distributeDelta > 0)
					{					
						//variable to keep loop going until some bar has been changed to keep balance.						
						var distributed = false;	
						//reset the valid sliders pool to all the potential sliders.
						validSliderIds = allSliderIds;	
						while(!distributed)
						{		
							//if there are no valid sliders left, we have to abandon distribution and stop the bar from sliding, by returning false.
							if(Object.keys( validSliderIds ).length === 0)	
							{
								return false;
							}
							var sliderId = pickRandomProperty(validSliderIds);		    
							var thisSlider = $('#'+sliderId);
							var thisSliderValue = $(thisSlider).slider("value");																					
							delete validSliderIds[sliderId];
							
							//complex conditional that makes sure we arnt' ajusting the bar we are sliding to balance, ensures the bar isn't at or above the max, and isn't at zero, and
							//that it isn't disabled. If all conditons are met, ajust the bar value to keep the balance.																
							if($(thisSlider).attr('id') != activeSlider && ( (sign > 0  && thisSliderValue <=percentTotal) || (sign <= 0  && thisSliderValue > 0)) && $(thisSlider).slider("option", "disabled") == false)
							{
								//set the bar value
								$(thisSlider).slider("value", thisSliderValue+sign);	
								//reduce the amount of points required to be distributed				
								distributeDelta--;	
								//break the loop be setting distributd to true.
								distributed = true;					
							}															
						}								
					}	
								
				}
			});
			
			//craete the locking button for each bar
			$(this).after().append('<button class="lockButton" parent="'+$(this).attr('id')+'" style="width:23px;height:23px;" id="lockButton_'+$(this).parents('#eq').attr('id')+'_'+$(this).attr('id')+'"></button>');
			
			//create the tally space for each bar.
			$(this).after().append('<div class="sliderGroupTally" id="sliderTally_'+$(this).parents('#eq').attr('id')+'_'+$(this).attr('id')+'">'+$(this).slider("value")+'%</div>');
		
			//this has to be added so we se value when the headings are created the first time
			var headingVal = 0;
			$(this).parent().parent().parent().find('.sliderGroupTally').each(function(index, value) {
			  	headingVal = headingVal + parseInt($(value).html());
			})
			$(this).parent().parent().parent().find('.headingValue').html(headingVal + "%");
			var sectionName = $(this).parent().parent().parent().attr('id');
			reqJsonObj.SectionTotals[sectionName] = headingVal;

			//lock any bar that has it's parent span set to disabled.
			if($(this).attr('locked').toLowerCase() == 'true')
			{
				$(this).slider("option", "disabled", true);	
			}
		});
		
		//setup the locking buttons.
		$( ".lockButton" ).button({
            icons: {
                primary: "ui-icon-unlocked"
            },
            text: false
        }).click(function(){
			var parent = $(this).attr('parent');
			if($(this).button( "option", "icons" ).primary == 'ui-icon-locked')
			{
				$(this).button( "option", "icons", {primary:'ui-icon-unlocked'} );
				$('#'+parent).slider("option", "disabled", false);
				$('#'+parent).attr('locked',"false");
			}
			else
			{
				$(this).button( "option", "icons", {primary:'ui-icon-locked'} );	
				$('#'+parent).slider("option", "disabled", true);
				$('#'+parent).attr('locked',"true");
			}
			
		});
//	});
	}
	
	//function for choosing a random property from an object.
	function pickRandomProperty(obj) {
		var result;
		var count = 0;
		for (var prop in obj)
			if (Math.random() < 1/++count)
			   result = prop;
		return result;
	}	
		