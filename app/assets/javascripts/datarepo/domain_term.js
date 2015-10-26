var domaintermClass = '.datarepo-domainterm';
var domaintermName = 'domainTerm';
function dtAutocompOpts(dtModel, dtTerm) {
  var jsonurl = '../authorities/' + dtModel + '/' + dtTerm + '';
  return {
    minLength: 2,
    source: function(request, response) {
        $.getJSON(jsonurl, {q: request.term}, function(data) {
            response(data);
        });
    },
    select: function(event, ui) {
        event.preventDefault();
        $(this).val(ui.item.label);
        $(this).siblings('input').first().val(ui.item.value);
    }
  };
}

function preventEmpty() {
    var readable = $(this).find('input[name=' + domaintermName + ']').first();
    var hidden = $(this).find('input[name!=' + domaintermName + ']').first();
    if (hidden.val() === '' || readable.val().indexOf(hidden.val()) == -1) {
        hidden.val(readable.val());
    }
}

Blacklight.onLoad(function() {
    if ($(domaintermClass).length) {
        $(domaintermClass).each(function(){
            var clone = $(this).clone();
            clone.attr('name', domaintermName);
            clone.insertBefore($(this));
            var model = clone.data('domaintermModel');
            var term = clone.data('domaintermTerm');
            clone.autocomplete(dtAutocompOpts(model, term));
            $(this).attr('type', 'hidden');
            var creatorObserver = new MutationObserver(function(mutations) {
                mutations.forEach(function(mutation) {
                  for (var i = 0; i < mutation.addedNodes.length; ++i) {
                    var node = $(mutation.addedNodes[i]);
                    node.find('input[name=' + domaintermName + ']').autocomplete(dtAutocompOpts(model, term));
                  }
                });
            });
            creatorObserver.observe($(this).closest('div')[0], {subtree: true, childList: true});
        });

        $(domaintermClass).closest('form').submit(function(event) {
            $(domaintermClass).closest('div').find('li').each(preventEmpty);
            $(domaintermClass + '[name=' + domaintermName + ']').remove();
            $(domaintermClass).attr('type', 'text')
        });
    }
});
