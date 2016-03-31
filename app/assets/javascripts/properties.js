$(document).ready(function(){
	$('.property-name, .property-address').keyup(function(){
    	$(this).val($(this).val().toUpperCase());
	});
});