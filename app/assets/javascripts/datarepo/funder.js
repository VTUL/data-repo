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

  $('#create_submit, #update_submit').click(function( event ) {
    $check = false;
    $(funderClass).each( function(index, value) {
      if ((value.value.indexOf(":") == -1) && value.value.length > 0) {
        $check = true;
      }
    });

    if ( $check && ( $( "p.fundermessage" ).text().length <=0 )  ) {
      $( "<p style='color:red' class='fundermessage'>Please enter correct funding Information format. (funder name:award number)</p>" ).insertBefore( ".form-group.collection_funder" );
      event.preventDefault();
    } else if ($check) {
      $( "p.fundermessage" ).show();
      event.preventDefault();
    } else {
      $( "p.fundermessage" ).hide();
      return;
    }
  });

});
