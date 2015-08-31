Blacklight.onLoad(function () {
  $('input:radio[name=doi_status]:checked').attr('checked', false);
  $('#doi_status_assigned').click(function() {
    $('#datacite_search_form').show();
    $("#q").val('');
    $('#q').focus(); 
    $('#datacite_search_result').hide();
    $('#new_form_area').hide();
    $('.collection_publisher').show();
  });
  $('#doi_status_unassigned').click(function() {
    $('#datacite_search_form').hide();
    $('#datacite_search_result').hide();
    $('#new_form_area').show();
    $("#new_collection").trigger('reset');
    $(".collection_creator ul li:gt(0)").remove();
    $('input[type=text][readonly]').removeAttr('readonly');
    $("#new_collection span").show();
    $('input[type="checkbox"][name="request_doi"]').show();
    $('label[for="request_doi"]').show();
    $('.collection_publisher').hide();
    $('input[id=collection_publisher]').val("University Libraries, Virginia Tech"); 
  }); 
  $('#direct_fill_form').on('click', function (e) {
    e.preventDefault();
    $('#datacite_search_form').hide();
    $('#datacite_search_result').hide();
    $('#new_form_area').show();
    $("#new_collection").trigger('reset');
    $(".collection_creator ul li:gt(0)").remove();
    $('input[type=text][readonly]').removeAttr('readonly');
    $("#new_collection span").show();
    $('input[type="checkbox"][name="request_doi"]').hide();
    $('label[for="request_doi"]').hide();
    $('.collection_publisher').show(); 
  });

});
