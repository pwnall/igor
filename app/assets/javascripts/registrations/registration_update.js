/* Bind AJAX events to recitation selection for /registrations */
$(function() {
    var updated_registration;
 
    $(document)
        .ajaxSend(function(e) {
            updated_registration = e.target.activeElement.id;
        })
        .ajaxSuccess(function() {
            $('#'+updated_registration).closest('tr').effect('highlight', {}, 3000);
        });
});
