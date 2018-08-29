Blacklight.onLoad(function() {
  $('.itemdownload').click(function(){
    event.preventDefault();
    var itemID = $(event.target).attr('href').replace('/downloads/', '');
  }); 
});
