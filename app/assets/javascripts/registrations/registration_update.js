/* Bind AJAX events to recitation selection for /registrations */
$(function() {
    var updated_registration;
    
    $("#registrations-table").
        bind('ajax:beforeSend', function(e) { 
           updated_registration = e.target;
    }).
        bind('ajax:success', function() {
           $(updated_registration).closest('tr').effect('highlight', {}, 3000);
    });
});
