/** Namespace. */
var PwnAjax = {};

/** Wires JS to elements with data-pwn attributes. */
PwnAjax.wireAll = function () {
  $('[data-pwn-move-source]').each(function (_, element) {
    PwnAjax.wireMove(element);
  });

  $('[data-pwn-refresh-url]').each(function (_, element) {
    PwnAjax.wireRefresh(element);
  });
  $('[data-pwn-confirm-source]').each(function (_, element) {
    PwnAjax.wireConfirm(element);
  });
  $('[data-pwn-reveal-trigger]').each(function (_, element) {
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
 * Wires JS to an AJAX confirmation check element using data-pwn-confirm-source.
 */
PwnAjax.wireConfirm = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-confirm-source');
  var sourceSelector = '[data-pwn-confirm-source="' + identifier + '"]'
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

/** Moves an element using data-pwn-move-source. */
PwnAjax.wireMove = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-move-source');
  var targetSelector = '[data-pwn-move-target="' + identifier + '"]';
  var jTarget = $(targetSelector).first();
  jElement.detach();
  jTarget.append(jElement);
};

/** Wires JS to an AJAX show/hide trigger using data-pwn-reveal-trigger. */
PwnAjax.wireReveal = function (element) {
  var jElement = $(element);
  var identifier = jElement.attr('data-pwn-reveal-trigger');
  var showOnCheck = (jElement.attr('data-pwn-reveal-oncheck') || 'true') !=
                    'false';
  var targetSelector = '[data-pwn-reveal-target="' + identifier + '"]';
  
  var onChangeFn = function () {
    var checked = jElement.is(':checked');
    var willShow = (checked == showOnCheck);
    console.log([checked, willShow, targetSelector]);
    if (willShow) {
      $(targetSelector).removeClass('hidden');
    } else {
      $(targetSelector).addClass('hidden');
    }
  };
  jElement.bind('change', onChangeFn);
  onChangeFn();
};

// Wire JS to elements when the document is loaded.
$(PwnAjax.wireAll);
