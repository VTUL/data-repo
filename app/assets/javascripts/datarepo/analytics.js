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
    $('.itemdownload').click(function(){
      _this.getTracker();
      var itemID = $(event.target).attr('href').replace('/downloads/', '');
      _this.pageTracker._trackEvent('Items','Download', itemID);
    });
  }
}
Blacklight.onLoad(function() {
  AnalyticsHelper.setListeners();
});
