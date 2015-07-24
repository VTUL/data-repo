var autocompClass = '.datarepo-autocomplete';
var autocompName = 'autocomplete';
var autocompOpts = {
    minLength: 2,
    source: function(request, response) {
        $.getJSON('/users.json', {uq: request.term}, function(data) {
            response(data.map(function(item) {
                return {'value': item.id, 'label': item.text};
            }));
        });
    },
    select: function(event, ui) {
        event.preventDefault();
        $(this).val(ui.item.label);
        $(this).siblings('input').first().val(ui.item.value);
    }
};

function addAutocomplete(mutation) {
    for (var i = 0; i < mutation.addedNodes.length; ++i) {
        var node = $(mutation.addedNodes[i]);
        node.find('input[name=' + autocompName + ']').autocomplete(autocompOpts);
    }
}

function preventEmpty() {
    var readable = $(this).find('input[name=' + autocompName + ']').first();
    var hidden = $(this).find('input[name!=' + autocompName + ']').first();
    if (hidden.val() === '' || readable.val().indexOf(hidden.val()) == -1) {
        hidden.val(readable.val());
    }
}

Blacklight.onLoad(function() {
    if ($(autocompClass).length) {
        $(autocompClass).each(function(){
            var clone = $(this).clone();
            clone.attr('name', autocompName);
            clone.insertBefore($(this));
            clone.autocomplete(autocompOpts);
            $(this).attr('type', 'hidden');

            var creatorObserver = new MutationObserver(function(mutations) {
                mutations.forEach(addAutocomplete);
            });
            creatorObserver.observe($(this).closest('div')[0], {subtree: true, childList: true});
        });

        $(autocompClass).closest('form').submit(function(event) {
            $(autocompClass).closest('div').find('li').each(preventEmpty);
            $(autocompClass + '[name=' + autocompName + ']').remove();
            $(autocompClass).attr('type', 'text')
        });
    }
});
