Blacklight.onLoad(function() {
  var popOversOpen = {};

  $("a[rel=popover]").click(function(event) {
    var clicked = this;
    var clickedID = $(clicked).attr('id');
    if(!popOversOpen.hasOwnProperty(clickedID)) {
      popOversOpen[clickedID] = true;
    }
    else {
      delete popOversOpen[clickedID]
    }
  });

  $(window).click(function() {
    if(Object.keys(popOversOpen).length > 0) {
      var clicked = this;
      if(event.target.className != 'help-icon' && $(clicked).attr('rel') != 'popover') {
        var openArray = [];
        $.each(popOversOpen, function(key, val) {
          $("#" + key).trigger('click');
          openArray.push(key);
        });
        for(i = 0; i < openArray.length; i++) {
          delete popOversOpen[openArray[i]];
        }
      }
    }
  });
});

