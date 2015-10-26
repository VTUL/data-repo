// function to hide or show the batch update buttons based on how may items are checked
function toggleMintButton(){
  var n = $(".doi_request_selector:checked").length;
  if (n > 0) {
    $('.doi_request_select_all').removeClass('hidden');
  } else {
    $('.doi_request_select_all').addClass('hidden');
  }
}

// check all the check boxes on the page
function check_all_requests(e) {
  // get the check box state
  var checked = $("#check_all_requests")[0]['checked'];
  // check each individual box
  $("input[type='checkbox'].doi_request_selector").each(function(index, value) {
    if (!value['disabled']) {
      value['checked'] = checked;
    }
  });
  toggleMintButton();    
}

Blacklight.onLoad(function() {
  // check all check boxes
  $("#check_all_requests").bind('click', check_all_requests);

  // toggle button on or off based on boxes being clicked  
  $(".doi_request_selector").bind('click', function(e) {
    toggleMintButton();
    
    // count the check boxes currently checked
    var selectedCount = $(".doi_request_selector:checked").length;

    // toggle the check all check box
    $("#check_all_requests").prop('checked', (selectedCount == $("#doi_requests_count").val()));
    
  });
  
});
