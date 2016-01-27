$(document).ready(function(){
	$('.submit-subscription').attr('disabled', 'disabled');
	$('.check_box').change(function() {
	    if ($('.check_box:checked').length) {
	        $('.submit-subscription').removeAttr('disabled');
	    } else {
	        $('.submit-subscription').attr('disabled', 'disabled');
	    }
	});	
})
