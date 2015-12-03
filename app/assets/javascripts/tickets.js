$(document).ready(function(){
	
	$('#ticket_property_ids').change(function() {
        var category = $(this).val();
        console.log(category);
        $('#ticket').val(category);
    });
})