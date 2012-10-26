/* Bind AJAX events to recitation selection for /registrations */
$(document).ready(function() {
    // TODO: Remove this global--suggestions? 
    var updated_registration;
    
    jQuery("#registrations-table")
        .bind('ajax:beforeSend', function(e, xhr, settings) {
            update_registration = e.target;
        })
        .bind('ajax:success', function(xhr, data, status) {
            $(update_registration).closest('tr').effect('highlight', {}, 3000);
         });
});