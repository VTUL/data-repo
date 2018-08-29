AnalyticsHelper = {
  pageTracker: null,
  analyticsID: null,
  
  init: function(analyticsID) {
    this.analyticsID = analyticsID;
  },

  getTracker: function() {
    if(this.pageTracker == null) {
      this.pageTracker = _gat._getTracker(this.analyticsID);
    }
  },
  
  setListeners: function() {
    var _this = this;

    // Items
    $('.itemdownload').click(function(){
      var itemID = $(event.target).attr('href').replace('/downloads/', '');
      _this.trackDownload('Item', itemID);
    });

    $('a#file_download').click(function(){
      if($(event.target).attr('id') == 'file_download') {
      	var target_link = event.target;
      }
      else {
        var target_link = $(event.target).parents('a#file_download');
      }
      var itemID = $(target_link).attr('href').replace('/downloads/', '');
      console.log(itemID);
      _this.trackDownload('Item', itemID);
    });

    // Datasets
    $('a#dataset_export_button').click(function(){
      var itemID = $(event.target).attr('collection_id');
      _this.trackDownload('Dataset', itemID);
    });
  },

  trackDownload: function(model, id) {
    this.getTracker();
    this.pageTracker._trackEvent(model,'Download', id);
  }
}
Blacklight.onLoad(function() {
  AnalyticsHelper.setListeners();
});
