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
  $('.htn, .additional_notes, .problem_statement').keyup(function(){
        if( ($('.htn').val().length >= 7) && ($('.additional_notes').val().length !=0) && ($('.problem_statement').val().length !=0) ) {
          $('.ticket-submit').prop( "disabled", false );
        } else {
          $('.ticket-submit').prop( "disabled", true );
        }
    });

});
$(window).bind('page:change', function() {
  initPage();
});
function initPage() {
	$("#ticket_property_ids").select2({
		placeholder: "Select Affected Properties, You Can Search By Name or Address Via Typing "
	});
}