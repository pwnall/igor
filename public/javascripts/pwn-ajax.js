/** Namespace. */
var PwnAjax = {};

/** Wires JS to elements with data-pwn attributes. */
PwnAjax.wireAll = function () {
  $('[data-pwn-move]').each(function (_, element) {
    PwnAjax.wireMove(element);
  });

  $('[data-pwn-refresh-url]').each(function (_, element) {
    PwnAjax.wireRefresh(element);
  });
  $('[data-pwn-confirm]').each(function (_, element) {
    PwnAjax.wireConfirm(element);
  });
  $('[data-pwn-reveal]').each(function (_, element) {
    PwnAjax.wireReveal(element);
  });
};

/** Wires JS to an AJAX refresh element that uses data-pwn-refresh-url. */
PwnAjax.wireRefresh = function (element) {
  var jElement = $(element);
  var xhrUrl = jElement.attr('data-pwn-refresh-url');
  var targetSelector = '#' + jElement.attr('data-pwn-refresh-target');
  var refreshInterval = parseInt(jElement.attr('data-pwn-refresh-ms') || '200');
  var xhrMethod = jElement.attr('data-pwn-refresh-method') || 'GET';
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
 * Wires JS to an AJAX confirmation check element using data-pwn-confirm.
 */
PwnAjax.wireConfirm = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-confirm');
  var sourceSelector = '[data-pwn-confirm="' + identifier + '"]'
  var winSelector = '[data-pwn-confirm-win="' + identifier + '"]';
  var failSelector = '[data-pwn-confirm-fail="' + identifier + '"]';
  
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

/** Moves an element using data-pwn-move. */
PwnAjax.wireMove = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-move');
  var targetSelector = '[data-pwn-move-target="' + identifier + '"]';
  var jTarget = $(targetSelector).first();
  jElement.detach();
  jTarget.append(jElement);
};

/** Wires JS to an AJAX show/hide trigger using data-pwn-reveal. */
PwnAjax.wireReveal = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-reveal');
  var trigger = jElement.attr('data-pwn-reveal-trigger') || 'click';
  var showOnCheck = true;
  if (trigger == 'uncheck') {
    trigger = 'check';
    showOnCheck = false;
  } else if (trigger == 'click-hide') {
    trigger = 'click';
    showOnCheck = false;
  }
  var targetSelector = '[data-pwn-reveal-target="' + identifier + '"]';
  
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
$(PwnAjax.wireAll);
