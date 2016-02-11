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

function mapDisplay(){
	var hash_val = $('#map_data').val();
	if (hash_val == ""){
		$("#map, .table, .ticket-header").hide();
		$(".active-ticket-panel").css("margin-top", "30px");
	} else {
		$(".active-ticket-panel").hide();
	}
}

$(function() {
	initPage();
  	mapDisplay();
});

$(window).bind('page:change', function() {
  initPage();
  mapDisplay();
});
function initPage() {
	$("#ticket_property_ids").select2({
		placeholder: "Select Affected Properties, You Can Search By Name or Address Via Typing "
	});
}