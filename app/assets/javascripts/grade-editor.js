/** Namespace. */
var GradeEditor = {};

/**
 * Toggles DOM classes in an indicator container to reflect an event.
 * 
 * @param indicators DOM element containing the indicator images
 * @param activeClass the indicator class that will be shown
 * @param temporary if true, the indicator will be hidden after a bit of time
 */
GradeEditor.setIndicator = function (indicators, activeClass, temporary) {
  $('img', indicators).each(function (index, e) {
    var element = $(e);
    if(element.hasClass(activeClass)) {
      element.removeClass('hidden');
    } else {
      element.addClass('hidden');
    }
  });
  if (temporary) {
    setTimeout(function () {
      GradeEditor.setIndicator(indicators, '-', false);
    }, temporary);
  }
};

/** Saves a grade via AJAX if it changed. */
GradeEditor.onBlur = function (event) {
  var target = $(event.target);
  target.parents('tr').first().removeClass('focused');

  var value = target.val();
  var oldValue = target.attr('data-old-value');
  if (value === oldValue) { return; }

  var form = target.parents('form').first();
  var indicators = $('.progress-indicators', form);
  GradeEditor.setIndicator(indicators, 'upload-pending', false);
  form.submit();
};

/** Takes note of a grade's current value. */
GradeEditor.onFocus = function (event) {
  var target = $(event.target);
  target.attr('data-old-value', target.val());
  
  target.parents('tr').first().addClass('focused');
};

/** Tabs to the next window if the user presses Enter. */
GradeEditor.onKeyDown = function (event) {
  if (event.which === 13) {
    event.preventDefault();
    
    var table = $(event.target).parents('table').first();
    var fields = [];
    var myIndex = null;
    $('tr:not(.hidden) input[type=number]').each(function (index, e) {
      fields[index] = e;
      if (event.target === e) {
        myIndex = index;
      }
    });
    // Cycle to the beginning after reaching the last field.
    var nextField = fields[myIndex + 1] || fields[0];
    $(nextField).focus();
    return false;
  }
};

/** Reflects a successful grade save. */
GradeEditor.onAjaxSuccess = function (event, data, status, xhr) {
  var container = $(event.target).parent();
  container.html(data);
  var indicators = $('.progress-indicators', container);
  GradeEditor.setIndicator(indicators, 'upload-win', 1000);
};

/** Reflects an unsuccessful grade save. */
GradeEditor.onAjaxError = function (event, xhr, status, error) {
  var indicators = $('.progress-indicators', event.target);
  GradeEditor.setIndicator(indicators, 'upload-fail', 5000);
};

/** Re-computes the summary values for a collection of grades. */
GradeEditor.redoSummary = function(row) {
  var sum = 0;
  $('input[type=number]', row).each(function (index, e) {
    sum += parseFloat($(e).val() || 0);
  });
  $('span.grade-sum', row).text(sum.toFixed(2));
};

/** Hides and shows grade rows to reflect searchbox changes. */
GradeEditor.onSearchChange = function(event) {
  var search = $(event.target);
  var nameFilter = (search.val() || '').toLowerCase();
  if (nameFilter == GradeEditor.onSearchChange.oldNameFilter) {
    return;
  }
  GradeEditor.onSearchChange.oldNameFilter = nameFilter;
  
  var table = search.parents('table').first();
  $('tr[data-subject-name]', table).each(function (index, e) {
    var element = $(e);
    var name = $(e).attr('data-subject-name');
    if (nameFilter === '' || name.toLowerCase().indexOf(nameFilter) != -1) {
      element.removeClass('hidden');
    } else {
      element.addClass('hidden');
    }
  });
};
/** Avoids applying the same name filter twice. */
GradeEditor.onSearchChange.oldNameFilter = "";

/** Wires event listeners into the DOM. */
GradeEditor.onLoad = function () {
  $('table.grades-table input[type=number]').live('blur', GradeEditor.onBlur);
  $('table.grades-table input[type=number]').live('focus', GradeEditor.onFocus);
  $('table.grades-table input[type=number]').live('keydown',
                                                  GradeEditor.onKeyDown);
  $('table.grades-table input[type=search]').bind('change',
                                                  GradeEditor.onSearchChange);
  $('table.grades-table input[type=search]').bind('textInput',
                                                  GradeEditor.onSearchChange);
  $('table.grades-table input[type=search]').bind('input',
                                                  GradeEditor.onSearchChange);
  $('table.grades-table input[type=search]').bind('keydown',
                                                  GradeEditor.onSearchChange);
  $('table.grades-table form').live('ajax:success', GradeEditor.onAjaxSuccess);
  $('table.grades-table form').live('ajax:error', GradeEditor.onAjaxError);
  $('table.grades-table tbody tr').each(function (index, row) {
    GradeEditor.redoSummary(row);
  });
};

$(GradeEditor.onLoad);
