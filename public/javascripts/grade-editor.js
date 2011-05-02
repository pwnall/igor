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

/** Wires event listeners into the DOM. */
GradeEditor.onLoad = function () {
  $('table.grades-table input[type=number]').live('blur', GradeEditor.onBlur);
  $('table.grades-table input[type=number]').live('focus', GradeEditor.onFocus);
  $('table.grades-table form').live('ajax:success', GradeEditor.onAjaxSuccess);
  $('table.grades-table form').live('ajax:error', GradeEditor.onAjaxError);
  $('table.grades-table tbody tr').each(function (index, row) {
    GradeEditor.redoSummary(row);
  });
};

$(GradeEditor.onLoad);
