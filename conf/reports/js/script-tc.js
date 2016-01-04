$(window).load(function() {
	var slider = $('.slides').bxSlider({
		mode: 'fade',
		captions: true
	});
	
	$(document).keypress(function(k) { 
		//alert(k.keyCode);
		if(k.keyCode == 39) { //left
			slider.goToNextSlide();
		}
		
		if(k.keyCode == 37) { //right
			slider.goToPrevSlide();
		}
	});
});
