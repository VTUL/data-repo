var datepickerClass = '.datarepo-datepicker';
var collectionCreatedId = 'collection_date_created-';
var datepickerNumber = 0;
var datepickerOpts = {
    changeMonth: true,
    changeYear: true,
    yearRange: '-70:-0'
};

function addDatepicker(mutation) {
    for (var i = 0; i < mutation.addedNodes.length; ++i) {
	var node = $(mutation.addedNodes[i]).find('.hasDatepicker');
	node.removeClass('hasDatepicker');
	++datepickerNumber;
	node.attr('id', collectionCreatedId + datepickerNumber);
	node.datepicker();
    }
}

Blacklight.onLoad(function() {
    if ($(datepickerClass).length) {
        $.datepicker.setDefaults(datepickerOpts);
        $(datepickerClass).each(function() {
            $(this).attr('id', collectionCreatedId + datepickerNumber); // where is the id set originally?
	    $(this).datepicker();
            var datepickerObserver = new MutationObserver(function(mutations) {
                mutations.forEach(addDatepicker);
            });
            datepickerObserver.observe($(this).closest('div')[0], {subtree: true, childList: true});
        });
    }
});
