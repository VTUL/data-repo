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
  $("#crossref_button").on('click', function(e) {
    e.preventDefault();
    var reqURL = "https://api.crossref.org/works";
    $.getJSON(reqURL, {
        query : $('#crossref_search_form').find('input[name="query"]').val(),
        rows : $('#crossref_search_form').find('input[name="rows"]').val(),
        offset : $('#crossref_search_form').find('input[name="offset"]').val()
      }, function(data) {
        if (data["status"] == "ok") {

          $.ajax({
            type: "POST",
            url: 'crossref_search',
            data: {results: JSON.stringify(data["message"]["items"])}
          });

        } else {
          $('#crossref_search_result').html('<p>No DOI found. Try again.</p>');
          $('#crossref_search_result').slideDown("fast");
        }
      }
    );
  });
  $('#add_related_url').on('click', function (e) {
    e.preventDefault();
    var the_value = $('#related_url_form').find("input[type='radio'][name='result']:checked").val();
    var count = $(".collection_related_url ul li").length;
    $(".collection_related_url ul li:nth-child(" + count + ") input").val(the_value)
    $('#crossref_search_result').hide();
    $('#add_related_url').hide();

  });

  function getLdapResults(tag) {
    var searchText = $(".ldap-txt." + tag);
    var searchButton = $(".ldap-search." + tag);
    var resultDiv = $(".ldap-results." + tag);
    var addButton = $(".ldap-add." + tag);
    var loadingDiv = $(".ldap-loading." + tag);
    $(searchButton).hide();
    $(resultDiv).hide();
    $(addButton).hide();
    $(loadingDiv).show();
    var urlName = encodeURI($(searchText).val());
    var ldapURL = 'ldap_search?label='+ tag +'&name=' + urlName;
    $(resultDiv).load(ldapURL, function() {
      $(loadingDiv).hide();
      $(searchButton).show();
      $(resultDiv).slideDown("fast");
      if ($(resultDiv).find("[type='radio']").length) {
        $(addButton).show();
      }
    } );
  }

  function addLdapResult(tag) {
    var the_value = $(".ldap-results." + tag).find("input[type='radio'][name='" + tag + "_result']:checked").val();
    var count = $(".collection_" + tag + " ul li").length;
    $(".collection_" + tag + " ul li:nth-child(" + count + ") input").val(the_value);
    $(".ldap-results." + tag).hide();
    $(".ldap-add." + tag).hide();
  }

  $('#ldap-search-creator').on('click', function () {
    getLdapResults('creator');
  });

  $('#ldap-add-creator').on('click', function() {
    addLdapResult('creator');
  });


  $('#ldap-search-contributor').on('click', function () {
    getLdapResults('contributor');
  });

  $('#ldap-add-contributor').on('click', function() {
    addLdapResult('contributor');
  });

});
