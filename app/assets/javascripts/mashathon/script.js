/*
 * SuperAwesome Cloud API Mashathon Virtual Spinner JavaScript file
 */

$(document).ready(function(){
	// Define min and max time the wheel can spin in ms
	var MIN_TIME = 5000;
	var MAX_TIME = 10000;
	
	// Define spinner items names and colors
	var items =  [
			{ "name":"AWS" , 
			"resultName":"AWS" ,
			"mainColor":"ED1E79" , 
			"borderColor":"520833",
			"shadowColor":"520833" ,
			"activeStop1":"ED1E79" ,
			"activeStop2":"8C005D" }, 
			{ "name":"Google" , 
			"resultName":"Google" , 
			"mainColor":"93278F" , 
			"borderColor":"470C44", 
			"shadowColor":"470C44" , 
			"activeStop1":"93278F" , 
			"activeStop2":"470C44" }, 
			{ "name":"Yelp" , 
			"resultName":"Yelp" , 
			"mainColor":"662D91" , 
			"borderColor":"470C44", 
			"shadowColor":"2D0E45" , 
			"activeStop1":"9C4DD6" , 
			"activeStop2":"57267D" }, 
			{ "name":"Facebook" , 
			"resultName":"Facebook" , 
			"mainColor":"0071BC" , 
			"borderColor":"0B4770",
			"shadowColor":"2E3192" , 
			"activeStop1":"30ABFC" , 
			"activeStop2":"005A96" }, 
			{ "name":"Smartsheet" ,
			"resultName":"Smartsheet" , 
			"mainColor":"29ABE2" ,
			"borderColor":"0C6D96",
			"shadowColor":"0C6D96" ,
			"activeStop1":"70D6FF" , 
			"activeStop2":"1592C9" }, 
			{ "name":"Docusign" , 
			"resultName":"Docusign" , 
			"mainColor":"39B54A" , 
			"borderColor":"166922", 
			"shadowColor":"166922" , 
			"activeStop1":"50F265" , 
			"activeStop2":"219E31" }, 
			{ "name":"Twitter" , 
			"resultName":"Twitter" ,
			"mainColor":"8CC63F" , 
			"borderColor":"517A1B", 
			"shadowColor":"517A1B" ,
			"activeStop1":"B6ED6D" ,
			"activeStop2":"68A11D" }, 
			{ "name":"CS / TC" , 
			"resultName":"CS / TC" ,
			"mainColor":"D9E021" , 
			"borderColor":"8E9407", 
			"shadowColor":"8E9407" , 
			"activeStop1":"D9E021" , 
			"activeStop2":"8E9407" }, 
			{ "name":"Pick One" , 
			"resultName":"Pick One" , 
			"mainColor":"FBB03B" , 
			"borderColor":"AF7418", 
			"shadowColor":"AF7418" , 
			"activeStop1":"FBDF78" , 
			"activeStop2":"FBA621" }, 
			{ "name":"FinancialForce" , 
			"resultName":"FinancialForce" , 
			"mainColor":"FF0000" , 
			"borderColor":"B31212",
			"shadowColor":"B31212" , 
			"activeStop1":"FF0000" , 
			"activeStop2":"B31212" }, 
		];
	// Current selected item index
	var currentIndex = 0; 
	// List of items
	var list;
	// Timer id
	var timer = -1;
	// Current angle of rotation
	var currentAngle = 0;
	var pickedApi = null;

	init();
	// Initialize spinner elements
	function init(){
		for (var i=0;i<10;i++){
			var el = $(".item").first().clone();
			
			$(".item").last().after(el);	
			var item = items[i];
			el.find(".item-name").text(item.name).arctext({radius: 200});
			el.data("index", i);
			el.data("result", false);
			el.find(".shadow").attr("fill", "#"+item.shadowColor);
			el.find(".main").attr("fill", "#"+item.mainColor);
			el.find(".activeGradient .stop1").attr("stop-color", "#" + item.activeStop1);
			el.find(".activeGradient .stop2").attr("stop-color", "#" + item.activeStop2);
			el.find(".activeGradient").attr("id", "SVGID_1_" + i);
			el.find(".border").attr("fill", "#"+item.borderColor);

			if (i == 0){
				el.addClass("active");
				el.find(".shadow").hide();
				el.find(".main").attr("fill", "url(#SVGID_1_" + i + ")");
				el.find(".name").attr("transform", "translate(0,0)");
				el.find(".nameShadow").attr("transform", "translate(0,1)");
			}
		}
		$(".item").first().remove();
		list = $(".item");
		updateSpin(0);
	}
	
	// Updates spinning wheel with passed angle
	function updateSpin(angle){
		var radius = 228;
		var transformExtensions = ["transform","-webkit-transform", "-moz-transform", "-ms-transform"];
		var deg = angle;
		for (var i=0;i<10;i++){
			var el = list.eq(i);
			var r = radius;
			if (el.data("index") == currentIndex){
				r -= 6;
			}
			var a = r * Math.sin(deg*Math.PI/180) + radius + 1;
			var b = r * -Math.cos(deg*Math.PI/180) + radius;
			
			for (var j=0;j<transformExtensions.length;j++){
				el.css(transformExtensions[j], "translate(" + (a-14) + "px," + (b+4) + "px) rotate(" + deg + "deg)");
			}
			deg += 36
		}
	}
	
	// Starts to spin wheel
	function spin(){
		startWheel();

	  $.ajax({
	    type: 'POST',
	    url: '/mashathon/pick',
		  beforeSend: function(xhr) {
		    xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
			},
	    success: function(results) { 
	    	if(results.api) {
	    		pickedApi = results.api;
	    	}
	    	else {
	    		alert("Could not pick API...sorry");
	    		stopWheel();
	    	}
					
	    },
	    failure: function(results) { 
	    	$('.spinner-wrap .spin-btn').removeClass("disabled");
	    	stopWheel();
	      alert('There was an error in picking API. Please contact support.');
	    }      
	  });
	}
	
	// Easing function for animation
	function easeFunction (t, b, c, d) {
		t /= d;
		t--;
		return -c * (t*t*t*t - 1) + b;
	};
	
	// Start button click handler
	$(document).on('click','.spinner-wrap .intro .start-btn',function(){
		$(".spinner-wrap .intro").fadeOut();
		$(".overlay").fadeOut();
	});
	
	// Start button mouseenter
	$(document).on('mouseenter','.spinner-wrap .intro .start-btn-wrap',function(){
		$(this).switchClass("", "active", 100);
	});
	
	// Start button mouseleave
	$(document).on('mouseleave','.spinner-wrap .intro .start-btn-wrap',function(){
		$(this).switchClass("active", "", 100);
	});
	
	
	// Spin button click handler
	$(document).on('click','.spinner-wrap .spin-btn',function(){
		if ($(this).hasClass("disabled"))
			return;
		spin();
	});
	
	// Window resize event
	$( window ).resize(function() {
		updateLayout();
	});
	
	updateLayout();
	// Updates vertical centering
	function updateLayout(){
		var height = $(window).height();
		var spinner = $(".spinner-wrap .spinner");
		var margin = (height / 2) - (spinner.height() / 2);
		if (margin < 0)
			margin = 0;
		spinner.css("marginTop", margin);
	}

	updateProgress();
	function updateProgress() {
		if(isStarted()) {
			$(".spinner-wrap .intro").fadeOut();
			$(".overlay").fadeOut();					
		}
		if(isFinished()) {
			$('.spinner-wrap .spin-btn').addClass("disabled");
			$('.spinner-wrap .intro-text').hide();
			$('.spinner-wrap .end-text').show();
		}
	}

	function isStarted() {
		return $('.spinner-wrap .buttons li:not(.result)').length < 3;
	}

	function isFinished() {
		return $('.spinner-wrap .buttons li:not(.result)').length == 0;	
	}

	function startWheel() {
		$('.spinner-wrap .spin-btn').addClass("disabled");		

		var group = $(".spinner .group");
		var time = 0;
		var delay = 50;
		var spinTime = 7250 + 300 * Math.random();
		var speed = spinTime / 10;
		var value = 0;
		var isEasing = false;

		timer = self.setInterval(function(){
			if(isEasing) time += delay;

			var index = 10 - Math.floor( (currentAngle+18) / 36);
			if (index == 10)
				index = 0;
			if (currentIndex != index){
				list.eq(currentIndex).find(".shadow").show();
				list.eq(currentIndex).find(".main").attr("fill", "#"+items[currentIndex].mainColor);
				list.eq(currentIndex).removeClass("active");
				currentIndex = index;
				list.eq(currentIndex).find(".shadow").hide();
				list.eq(currentIndex).find(".main").attr("fill", "url(#SVGID_1_" + currentIndex + ")");
				list.eq(currentIndex).addClass("active");
			}
			
			if (time > spinTime){
				// Time end, display result and clear interval
				clearInterval(timer);
				timer = -1;

				// display the result on the button
				var buttons = $('.spinner-wrap .buttons li:not(.result)');
				buttons.eq(0).addClass("result").find(".text").text(pickedApi).addClass("result").hide().fadeIn("fast", function() {
					// finalize if finished
					if(isFinished()) {
						$('.spinner-wrap .spin-btn').addClass("disabled");
						$('.spinner-wrap .intro-text').hide();
						$('.spinner-wrap .end-text').show();				
					}			
					else {
						$('.spinner-wrap .spin-btn').removeClass("disabled");
					}

				});

				pickedApi = null;				
				
			} else {				
				if(isEasing) {
					var v = easeFunction(time,speed,speed,7000);
					if(value > 0) {
						currentAngle += v - value;
					}

					value = v;					
				}
				else if(pickedApi && !isEasing) {
					var angle = 360;
					for(var index=0; index<items.length; index++) {
						var item = items[index];
						if(item.name === pickedApi) {
							break;
						}
						angle -= 360/items.length;
					}

					currentAngle = angle;
					isEasing = true;
				}
				else {
					currentAngle += 60;
				}
				
				if (currentAngle >= 360)
					currentAngle -= 360;

				// Spin wheel and update currentAngle
				updateSpin(currentAngle);

			}
		},delay);
	}

	function stopWheel() {
		clearInterval(timer);
		timer = -1;
		$('.spinner-wrap .spin-btn').removeClass("disabled");
	}
});