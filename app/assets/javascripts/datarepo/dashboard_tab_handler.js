var TabHandler = {
  run: function() {
    if(window.location.hash) {
      $('ul#upload_tabs').find('a').each(function() {
        if($(this).attr('href') == window.location.hash) {
          $(this).click();
        }
      })
    }
  }
}
