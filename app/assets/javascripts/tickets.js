function validate(evt) {
	var theEvent = evt || window.event;
	var key = theEvent.keyCode || theEvent.which;
	key = String.fromCharCode( key );
	var regex = /^[0-9b]*$/;
	if( !regex.test(key) ) {
		theEvent.returnValue = false;
		if(theEvent.preventDefault) theEvent.preventDefault();
	}
}

$(function() {
  initPage();
  $('.ticket-submit').attr("disabled", "disabled");
  $('.htn, .additional_notes, .problem_statement').keyup(function() {
        var empty = false;        
        var htn_length = $(".htn").val().length;
        var an_length = $(".additional_notes").val().length;
        var ps_length = $(".problem_statement").val().length;
        var total_length = htn_length + an_length + ps_length;
        if (total_length <= 10) {
            empty = true;
            $('.ticket-submit').prop( "disabled", true );
        } else {
            $('.ticket-submit').prop( "disabled", false );
        }
    });
});
$(window).bind('page:change', function() {
  initPage();
});
function initPage() {
	$("#ticket_property_ids").select2({
	});
}