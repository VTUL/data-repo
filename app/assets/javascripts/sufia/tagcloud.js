Blacklight.onLoad(function () {
    /*
     *  Tag cloud(s), overrides the same file in Sufia.
     */
    $(".tagcloud").blacklightTagCloud({
            size: {start: 0.9, end: 2.5, unit: 'em'},
            cssHooks: {granularity: 15},
            color: {start: '#B47A1F', end: '#993300'}
        });
});
