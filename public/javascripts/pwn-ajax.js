/** Namespace. */
var PwnAjax = {};

/** Wires JS to elements with data-pwn attributes. */
PwnAjax.wireAll = function () {
  $('[data-pwn-refresh-url]').each(function (_, element) {
    PwnAjax.wireRefresh(element);
  });
  $('[data-pwn-confirm-source]').each(function (_, element) {
    PwnAjax.wireConfirm(element);
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
 * Wires JS to an AJAX confirmation check element using data-pwn-confirm-source.
 */
PwnAjax.wireConfirm = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-confirm-source');
  var sourceSelector = '[data-pwn-confirm-source=' + identifier + ']'
  var winSelector = '[data-pwn-confirm-win=' + identifier + ']';
  var failSelector = '[data-pwn-confirm-fail=' + identifier + ']';
  
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

// Wire JS to elements when the document is loaded.
$(PwnAjax.wireAll);
