// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function show_div_on_checkbox_setting(div_id, checkbox_id, value_for_shown){
	var checkbox = $(checkbox_id);
	var div_element = $(div_id);
	if (checkbox.checked != value_for_shown) {
		div_element.hide();
	}
	checkbox.observe('change', function(event) {
		if (checkbox.checked != value_for_shown)
			div_element.fade();
		else
			div_element.appear();
	})
}

function grades_compute_total(target_id, field_ids) {
	var total = 0;
	for (var i = 0; i < field_ids.length; i++) {
		var fval = $(field_ids[i]).value;
		if (fval != "") {
			total += parseFloat(fval);
		}
	}
	$(target_id).update(total + '')
}	

function submission_checker_update_visiblity(id_suffix) {
	var vtype = $('submission_checker_type_' + id_suffix).value;
	var v_rpkg = $('submission_checker_rpkg_' + id_suffix);
	var v_upkg = $('submission_checker_upkg_' + id_suffix);
	var v_rupkg = $('submission_checker_rupkg_' + id_suffix);
	var v_bin = $('submission_checker_bin_' + id_suffix);
	
	v_rpkg.hide();
	v_upkg.hide();
	v_rupkg.hide();
	v_bin.hide();
	if (vtype == 'ScriptValidation') {
		v_upkg.show();
		v_rupkg.show();
	}
	else if (vtype == 'ProcValidation') {
		v_bin.show();
	}
}

function submission_packager_update_fe(target_elem, base, prefix_elem, suffix_elem) {
	var fprefix = $(prefix_elem).value;
	var fsuffix = $(suffix_elem).value;
	$(target_elem).update(fprefix + base + fsuffix);
}

// Windows renders custom fonts very badly, so we disable them.
if (/win/i.test(navigator.platform)) {
  Event.observe(window, 'load', function() {
    if (!document.styleSheets) { return; }
    
    for (var i = 0; i < document.styleSheets.length; i++) {
      var sheet = document.styleSheets[i];
      var rules = sheet.cssRules || sheet.rules;
      var fontRules = [];
      for (var j = 0; j < rules.length; j++) {
        var rule = rules[j];
        if (rule.type == 5) {  // @font-face rule
          fontRules.push(j);
        }
      }
      for (var j = fontRules.length - 1; j >= 0; j--) {
        if (sheet.deleteRule) {
          sheet.deleteRule(fontRules[j]);
        } else if (sheet.removeRule) {
          sheet.removeRule(fontRules[j]);
        }
      }
    }  
  });  
}
