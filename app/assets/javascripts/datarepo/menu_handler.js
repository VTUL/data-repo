Blacklight.onLoad(function() {
  var $linkLi = $('#vt_main_nav li.dropdown.nav-item')
  $linkLi.hover(function(){
    $(this).find('a.dropdown-toggle').addClass('open');
    $(this).find('.vt_subnav1_block').addClass('open');
  },function(){
    $(this).find('a.dropdown-toggle').removeClass('open');
    $(this).find('.vt_subnav1_block').removeClass('open');
  });
});
