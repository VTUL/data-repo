Blacklight.onLoad(function() {
    // This should not be needed, but w/o this the next button is not working
    $(".right.carousel-control, .right.carousel-control > span").click(function() {
        $("#homepage-carousel").carousel('next');
    });
});
