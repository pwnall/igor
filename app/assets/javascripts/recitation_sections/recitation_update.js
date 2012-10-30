/* Activating Best In Place */
$(function() {
    $(".best_in_place").best_in_place()
        .bind('ajax:success', function(e) {
            $(this).closest('tr').effect('highlight', {}, 2000);
         })
        .bind('best_in_place:error', function(e, error) {
            var errors = $.parseJSON(error.responseText);
            $('.validation-errors').html("Error: "+errors);
            $(this).closest('tr').effect('highlight', {color: 'red'}, 2000);
         });
});
