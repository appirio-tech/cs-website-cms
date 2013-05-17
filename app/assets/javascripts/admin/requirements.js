var reqJsonText='';
var fullJsonText;
var reqJsonObj;
var ajaxReqJsonObj;

$(document).ready(function(){

	setupCollapsibles(); 
	
	$('#newRequirementBtn').unbind("click").click(function(){
		var title = $('#reqTitle').val();
		var section = $('#reqSection').val();
		var type = $('#reqType').val();
		var description = $('#reqDescription').val();
	//	alert("title: "+title+" section : "+section+" type: "+type+" description : "+description);
		
		if(reqJsonText != ''){
			reqJsonText = reqJsonText + ', ';
		}
		reqJsonText = reqJsonText + '{ "Title" : "'+title+'", "Section" : "'+section+'", "Type" : "'+type+'", "Description" : "'+description+'", "Rating" : "" }';
		//alert(reqJsonText);
		createReqJsonObject();
		$('#add-requirement-modal').modal('hide');
	});

	//Add save and new button for quick adding of Requirements. I copied the top code for easier understading which changes were mine.
	//The same method should be extraced in one shared method and called from $('#reqForm').submit and $('#saveAndNew').click.
	$('#saveAndNew').click(function(){
		var title = $('#reqTitle').val();
		var section = $('#reqSection').val();
		var type = $('#reqType').val();
		var description = $('#reqDescription').val();
	
		if(reqJsonText != ''){
			reqJsonText = reqJsonText + ', ';
		}
		reqJsonText = reqJsonText + '{ "Title" : "'+title+'", "Section" : "'+section+'", "Type" : "'+type+'", "Description" : "'+description+'", "Rating" : ""}';
		//alert(reqJsonText);
		createReqJsonObject();

		//we delete the Title and the Description
		$('#reqTitle').val("");
		$('#reqDescription').val("");
	});

	//we have to add this because we added/changed buttons in form dialog for adding requirements. 
	//We have to remove our button and show the original one.
	$('#add-requirement-modal button.close').click(function(){
		$("#addRequirement").show();
		$("#editRequirement").remove();
	});	
	
	$('#post-json').click(function(){
		if(reqJsonObj == null){
			alert("No data to post");
			return;
		}
		postJson();
	});
	
});



function setupCollapsibles(){
	$(".collapse").collapse({
		toggle : false
	});
			
	$(".sectionheading").click(function(){
		$(this).next().collapse('toggle');
	});
	$(".reqheading").click(function(){
		$(this).next().collapse('toggle');
	});
}

function createReqJsonObject(jsontext){
	
	if(jsontext != undefined && jsontext != ''){
		fullJsonText = jsontext;
	}else{
		fullJsonText = '{ "Requirements" : [ '+reqJsonText+' ] }'
	}
	reqJsonObj = JSON.parse(fullJsonText);
	reqJsonObj.SectionTotals = {}; 	
	renderRequirements();
}

function renderRequirements(){
	var title;
	var section;
	var type;
	var description;
	var rating;
	
	$('#eq').html('');
	
	$.each(reqJsonObj.Requirements,function(i,data){
		var reqHtml = '';
		title = data.Title;
		section = data.Section;
		type = data.Type;
		description = data.Description;
		rating = data.Rating;
		
		
		//added for Challenge 2200 --> we added two links --> delete & edit
		if($('#'+section.toLowerCase()).html() == null){
			reqHtml = '<div id="'+section.toLowerCase()+'" > <div class="sectionheading">Section: '+section+'<div class="headingValue"></div></div><div class="collapse sectionbody"><div class="reqheading">'+title+' <a id ="'+i+'" class="editLink" href="#add-requirement-modal" data-toggle="modal">Edit</a> <a id ="'+i+'" class="deleteLink">Delete</a><span id="col'+(i+1)+'" class="slide">'+rating+'</span></div><div class="collapse reqbody">'+description+'</div></div></div>';
			$('#eq').append(reqHtml);
		}else{
			reqHtml = '<div class="reqheading">'+title+' <a id ="'+i+'" class="editLink" href="#add-requirement-modal" data-toggle="modal">Edit</a> <a id ="'+i+'" class="deleteLink">Delete</a><span id="col'+(i+1)+'" class="slide"></span></div><div class="collapse reqbody">'+description+'</div>';
			$('#'+section.toLowerCase()+' .sectionbody').append(reqHtml);
		}
	});	
		setSliderValues();
		setupCollapsibles();
		createSliders();

		//added for Challenge 2200
		$(".editLink").click(function() {
		  updateModalBody($(this));
		});

		//added for Challenge 2200
		$(".deleteLink").click(function() {
		  deleteRequirement($(this));
		});

}

//added for Challenge 2200
//function deletes specific requirement
function deleteRequirement(jqueryObject)
{
	var jsonPositionIndex = jqueryObject.attr('id');		//we get our id so we can access JSON
	reqJsonObj.Requirements.splice(jsonPositionIndex,1);	//remove the requirement from the JSON
	reqJsonObj.SectionTotals = {}; 							//we remove the sectionTotals which are later addd in groupedSliders.js
	fullJsonText = JSON.stringify(reqJsonObj);				//we have to do this because of the previous challenge solver which used this text string for storing data
	reqJsonText = JSON.stringify(reqJsonObj.Requirements);	//we have to do this because of the previous challenge solver which used this text string for storing data
	reqJsonText = reqJsonText.substring(1, reqJsonText.length);
	reqJsonText = reqJsonText.substring(0, reqJsonText.length-1);
	jqueryObject.parent().remove();		//remove the HTML element
	renderRequirements();				//rerender requirements
	//let's check if there is no more requirements left and let's clear the JSON if that is true
	if(reqJsonObj.Requirements.length < 1)
	{
		fullJsonText = "";
		reqJsonText="";
		reqJsonObj=undefined;
	}
}

//added for Challenge 2200
//function updates form values for specific requirement
function updateModalBody(jqueryObject)
{
	//first we set all the form values to specific requirement
	var jsonPositionIndex = jqueryObject.attr('id');
	$('#reqTitle').val(reqJsonObj.Requirements[jsonPositionIndex].Title);
	$('#reqSection').val(reqJsonObj.Requirements[jsonPositionIndex].Section);
	$('#reqType').val(reqJsonObj.Requirements[jsonPositionIndex].Type);
	$('#reqDescription').val(reqJsonObj.Requirements[jsonPositionIndex].Description);
	$("#addRequirement").hide();
	$("#addRequirement").parent().prepend('<button type="button" onclick="updateRequirement('+jsonPositionIndex+')" id="editRequirement" class="btn">Save Requirement</button>');
}

//added for Challenge 2200
//function updates specific requirement
function updateRequirement(jsonPositionIndex)
{
	//we get all the data from the form
	var title = $('#reqTitle').val();
	var section = $('#reqSection').val();
	var type = $('#reqType').val();
	var description = $('#reqDescription').val();

	//we update the JSON
	reqJsonObj.Requirements[jsonPositionIndex].Title  = title;
	reqJsonObj.Requirements[jsonPositionIndex].Section  = section;
	reqJsonObj.Requirements[jsonPositionIndex].Type  = type;
	reqJsonObj.Requirements[jsonPositionIndex].Description  = description;

	//we have to do this because of the previous challenge solver which used this text string for storing data
	fullJsonText = JSON.stringify(reqJsonObj);
	reqJsonText = JSON.stringify(reqJsonObj.Requirements);
	reqJsonText = reqJsonText.substring(1, reqJsonText.length);
	reqJsonText = reqJsonText.substring(0, reqJsonText.length-1);
	renderRequirements();	//rerender requirements
	$('#add-requirement-modal').modal('hide');	//hide the form
	$("#addRequirement").show();	//put back original button to the form
	$("#editRequirement").remove();		//remove edit button
}

function setSliderValues(){
	var eachSliderValue = 0;
	var lastSliderValue = 0;
	var rem = 0;
	var sliderArray = $('#eq span:.slide');
	var len = sliderArray.length;
	var total = parseInt($('#eq').attr("total"),10);
	
	eachSliderValue = Math.floor(total/len);
	rem = total%len;
	lastSliderValue = eachSliderValue + rem;
		
	$('#eq span:.slide').each(function(i){
		if(i == (len-1)){
			$(this).append(lastSliderValue);
		}else{
			$(this).append(eachSliderValue);
		}
	});
}

function postJson(){
	updateRatings();
	var jsonText = JSON.stringify(reqJsonObj, null ,2);
	
	$.ajax({
		type : 'Post',
		url : 'http://requestb.in/1cmua3i1',
		data : jsonText
	});
	alert("JSON Successfully posted to Request bin. Please check out : http://requestb.in/1cmua3i1");

	//There was a problem with holding ratings in JSON and groupedSliders so I just removed it for the temp. it is still normaly sent over the network.
	clearRatings();	
}

function updateRatings(){
	var sliderArray = $('#eq span:.slide .sliderGroupTally');
	var reqArray = reqJsonObj.Requirements;
	for(var i=0; i < sliderArray.length; i++){
		var value = $(sliderArray[i]).text();
		if(value.indexOf("") > -1){
			value = value.replace("%","");
		}
		reqArray[i].Rating = value;
	}
}	

//added for Challenge 2200
function clearRatings(){
	var sliderArray = $('#eq span:.slide .sliderGroupTally');
	var reqArray = reqJsonObj.Requirements;
	for(var i=0; i < sliderArray.length; i++){
		reqArray[i].Rating = "";
	}
}	


/*
The below function will be used in case the edit functionality needs to be implemented in future which will take json from a url. That json will contain full details of the requirements so that the user need not require to use add button to add any requirements. Just create a new button called as Populate From Ajax and call this function on click of that button. Refer the readme given to know the desired JSON structure to render it.
*/

/*
function populateFromAjax(){

	$.ajax({
		type :'GET',
		url : '<url having json for the requirements>',
		dataType : 'json',
		success : function(data){
			createReqJsonObject(data);
		}
	})
}
*/
	