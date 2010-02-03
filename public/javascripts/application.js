// application.js

function show_div_on_checkbox_setting(div_id, checkbox_id, value_for_shown){
	var checkbox = $(checkbox_id);
	var div_element = $(div_id); 
	if(checkbox.checked != value_for_shown)
		div_element.hide();
	checkbox.observe('change', function(event) {
		if(checkbox.checked != value_for_shown)
			div_element.fade();
		else
			div_element.appear();
	})
}

function grades_compute_total(target_id, field_ids) {
	var total = 0;
	for(var i = 0; i < field_ids.length; i++) {
		var fval = $(field_ids[i]).value;
		if(fval != "")
			total += parseInt(fval);				
	}
	$(target_id).update(total + '')
}	

function submission_validation_update_visiblity(id_suffix) {
	var vtype = $('deliverable_validation_type_' + id_suffix).value;
	var v_rpkg = $('deliverable_validation_rpkg_' + id_suffix);
	var v_upkg = $('deliverable_validation_upkg_' + id_suffix);
	var v_rupkg = $('deliverable_validation_rupkg_' + id_suffix);
	var v_bin = $('deliverable_validation_bin_' + id_suffix);
	
	v_rpkg.hide();
	v_upkg.hide();
	v_rupkg.hide();
	v_bin.hide();
	if(vtype == 'RemoteScriptValidation') {
		v_rpkg.show();
		v_rupkg.show();
	}
	else if(vtype == 'UploadedScriptValidation') {
		v_upkg.show();
		v_rupkg.show();
	}
	else if(vtype == 'ProcValidation') {
		v_bin.show();
	}
}

function submission_packager_update_fe(target_elem, base, prefix_elem, suffix_elem) {
	var fprefix = $(prefix_elem).value;
	var fsuffix = $(suffix_elem).value;
	$(target_elem).update(fprefix + base + fsuffix);
}
