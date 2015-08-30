var funderClass = '.datarepo-funder';

Blacklight.onLoad(function() {

  $(funderClass).each( function(index, value) {
    xmlDoc = $.parseXML( value.value ),
    $xml = $( xmlDoc ),
      $fundername = $xml.find( "fundername" );
      $awardnumber = $xml.find( "awardnumber" );
      if ($fundername.length > 0 ) {
        newstring = $fundername.text() + ":" + $awardnumber.text();
        $(funderClass)[index].value = newstring;
      }
  });
$.validator.addMethod(
	"datarepoFunder",
	function(value, element, regexp) {
	    var re = new RegExp(regexp);
	    return this.optional(element) || re.test(value);
	},
	"Please enter correct funding Information format. (funder name: award number)"
);

$(".simple_form").validate({
	errorPlacement: function(error, element){		
		if (element.parent().hasClass("input-group") )		
			error.insertAfter( element.parent() );
		else
			error.insertAfter( element );
	}
});
$(funderClass).rules("add", {datarepoFunder: ".*:.*"});

});
