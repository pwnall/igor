/**
 * PwnFx: AJAX sprinkles via unobtrusive JavaScript.
 * @author Victor Costan
 * 
 * The author sorely misses Rails' AJAX helpers such as observe_field. This
 * library provides a replacement that adheres to the new philosophy of
 * unobtrusive JavaScript triggered by HTML5 data- attributes.
 */


/** Namespace. */
var PwnFx = {};

/** Wires JS to elements with data-pwnfx attributes. */
PwnFx.wireAll = function () {
  $('[data-pwnfx-move]').each(function (_, element) {
    PwnFx.wireMove(element);
  });

  $('[data-pwnfx-refresh-url]').each(function (_, element) {
    PwnFx.wireRefresh(element);
  });
  $('[data-pwnfx-confirm]').each(function (_, element) {
    PwnFx.wireConfirm(element);
  });
  $('[data-pwnfx-reveal]').each(function (_, element) {
    PwnFx.wireReveal(element);
  });
};

/** Wires JS to an AJAX refresh element that uses data-pwnfx-refresh-url. */
PwnFx.wireRefresh = function (element) {
  var jElement = $(element);
  var xhrUrl = jElement.attr('data-pwnfx-refresh-url');
  jElement.attr('data-pwnfx-refresh-url-done', xhrUrl);
  jElement.removeAttr('data-pwnfx-refresh-url');
  
  var targetSelector = '#' + jElement.attr('data-pwnfx-refresh-target');
  var refreshInterval =
      parseInt(jElement.attr('data-pwnfx-refresh-ms') || '200');
  var xhrMethod = jElement.attr('data-pwnfx-refresh-method') || 'POST';
  var form = $(jElement.parents('form')[0]);
  var onXhrSuccessFn = function (data) {
    $(targetSelector).html(data);
  };
  var refreshPending = false;
  var refreshOldValue = null;
  var ajaxRefreshFn = function () {
    refreshPending = false;
    $.ajax({
      data: form.serialize(), success: onXhrSuccessFn,
      dataType: 'html', type: xhrMethod, url: xhrUrl
    });
  };
  var onChangeFn = function () {
    var value = jElement.val();
    if (value == refreshOldValue) {
      return;
    } else {
      refreshOldValue = value;
    }
    if (refreshPending) {
      return;
    } else {
      refreshPending = true;
      setTimeout(ajaxRefreshFn, refreshInterval);
    }
  };
  
  jElement.bind('change', onChangeFn);
  jElement.bind('keydown', onChangeFn);
  jElement.bind('keyup', onChangeFn);
  onChangeFn();
};

/**
 * Wires JS to an AJAX confirmation check element using data-pwnfx-confirm.
 */
PwnFx.wireConfirm = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwnfx-confirm');
  var sourceSelector = '[data-pwnfx-confirm="' + identifier + '"]'
  var winSelector = '[data-pwnfx-confirm-win="' + identifier + '"]';
  var failSelector = '[data-pwnfx-confirm-fail="' + identifier + '"]';
  
  var onChangeFn = function () {
    var value = null;
    var matching = true;
    $(sourceSelector).each(function (index, element) {
      var val = $(element).val();
      value = value || val;
      if (value != val) {
        matching = false;
      }
      if (matching) {
        $(winSelector).removeClass('hidden');
        $(failSelector).addClass('hidden');
      } else {
        $(winSelector).addClass('hidden');
        $(failSelector).removeClass('hidden');
      }
    });
  };
  jElement.bind('change', onChangeFn);
  jElement.bind('keydown', onChangeFn);
  jElement.bind('keyup', onChangeFn);
  onChangeFn();
};

/** Moves an element using data-pwnfx-move. */
PwnFx.wireMove = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwnfx-move');
  jElement.attr('data-pwnfx-move-done', identifier);
  jElement.removeAttr('data-pwnfx-move');

  var targetSelector = '[data-pwnfx-move-target="' + identifier + '"]';
  var jTarget = $(targetSelector).first();
  jElement.detach();
  jTarget.append(jElement);
};

/** Wires JS to an AJAX show/hide trigger using data-pwnfx-reveal. */
PwnFx.wireReveal = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwnfx-reveal');
  jElement.attr('data-pwnfx-reveal-done', identifier);
  jElement.removeAttr('data-pwnfx-reveal');

  var trigger = jElement.attr('data-pwnfx-reveal-trigger') || 'click';
  var showOnCheck = true;
  if (trigger == 'uncheck') {
    trigger = 'check';
    showOnCheck = false;
  } else if (trigger == 'click-hide') {
    trigger = 'click';
    showOnCheck = false;
  }
  var targetSelector = '[data-pwnfx-reveal-target="' + identifier + '"]';
  
  var onChangeFn = function () {
    var checked = (trigger == 'click') || jElement.is(':checked');
    var willShow = (checked == showOnCheck);
    if (willShow) {
      $(targetSelector).removeClass('hidden');
    } else {
      $(targetSelector).addClass('hidden');
    }
  };
  
  if (trigger == 'click') {
    jElement.bind('click', onChangeFn);
  } else if (trigger = 'check') {
    jElement.bind('change', onChangeFn);
    onChangeFn();
  }
};

// Wire JS to elements when the document is loaded.
$(PwnFx.wireAll);
