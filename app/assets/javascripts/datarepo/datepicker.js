var datepickerClass = '.datarepo-datepicker';
var datepickerId = 'datarepo-datepicker-';
var datepickerNumber = 0;
var datepickerOpts = {
    changeMonth: true,
    changeYear: true,
    yearRange: '-70:-0'
};

function addDatepicker(mutation) {
    for (var i = 0; i < mutation.addedNodes.length; ++i) {
        var node = $(mutation.addedNodes[i]).find('input.hasDatepicker');
        if (node.length) {
            node.removeClass('hasDatepicker');
            node.attr('id', datepickerId + datepickerNumber);
            datepickerNumber++;
            node.datepicker();
        }
    }
}

Blacklight.onLoad(function() {
    if ($(datepickerClass).length) {
        $.datepicker.setDefaults(datepickerOpts);
        $(datepickerClass).each(function() {
            $(this).datepicker();
            var datepickerObserver = new MutationObserver(function(mutations) {
                mutations.forEach(addDatepicker);
            });
            datepickerObserver.observe($(this).closest('div')[0], {subtree: true, childList: true});
        });
    }
});
