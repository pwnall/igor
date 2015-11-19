# PwnFx: AJAX sprinkles via unobtrusive JavaScript.
# @author Victor Costan

# The author sorely misses Rails' AJAX helpers such as observe_field. This
# library provides a replacement that adheres to the new philosophy of
# unobtrusive JavaScript triggered by HTML5 data- attributes.


# The class of the singleton instance that tracks all the effects on the page.
class PwnFxClass
  # Creates an instance that isn't aware of any effects.
  #
  # After defining an effect class, call registerEffect on this instance to make
  # it aware of the effect.
  constructor: ->
    @effects = []
    @effectsByName = {}
    @hiddenClassName = null

  # @attribute {String} the default name of the DOM class used to hide
  #     elements; by default, this is set to the data-pwnfx-hidden-class
  #     attribute of the <body> element
  hiddenClassName: null

  # Wires JS to elements with data-pwnfx attributes.
  #
  # @param {Element} root the element whose content is wired; use document at
  #                       load time
  wire: (root) ->
    @hiddenClassName ||=
        document.body.getAttribute('data-pwnfx-hidden-class') || 'hidden'

    for effect in @effects
      attrName = "data-pwnfx-#{effect[0]}"
      effectClass = effect[1]
      scopeAttrName = "#{attrName}-scope"
      doneAttrName = "#{attrName}-done"
      attrSelector = "[#{attrName}]"
      for element in document.querySelectorAll(attrSelector)
        attrValue = element.getAttribute attrName
        continue unless attrValue
        element.removeAttribute attrName
        element.setAttribute doneAttrName, attrValue
        scopeId = element.getAttribute scopeAttrName
        new effectClass element, attrValue, scopeId
    null

  # Registers a PwnFx effect.
  #
  # @param {String} attrName string following data-pwnfx- in the effect's
  #                          attribute names
  # @param klass the class that wraps the effect's implementation
  registerEffect: (attrPrefix, klass) ->
    if @effectsByName[attrPrefix]
      throw new Error("PwnFx effect name {attrPrefix} already registered")
    @effects.push [attrPrefix, klass]

  # Finds a scoping container.
  #
  # @param {String} scopeId the scope ID to look for
  # @param {HTMLElement} element the element where the lookup starts
  # @return {HTMLElement} the closest parent of the given element whose
  #     data-pwnfx-scope matches the scopeId argument; window.document is
  #     returned if no such element exists or if scope is null
  resolveScope: (scopeId, element) ->
    element = null if scopeId is null
    while element isnt null &&
        element.getAttribute('data-pwnfx-scope') isnt scopeId
      element = element.parentElement
    element || document

  # Performs a scoped querySelectAll.
  #
  # @param {HTMLElement} scope the DOM element serving as the search scope
  # @param {String} selector the CSS selector to query
  # @return {NodeList, Array} the elements in the scope that match the CSS
  #     selector; the scope container can belong to the returned array
  queryScope: (scope, selector) ->
    scopeMatches = false
    if scope isnt document
      # TODO: machesSelector is in a W3C spec, but only implemented using
      #       prefixes; the code below should be simplified once browsers
      #       implement it without vendor prefixes
      if scope.matchesSelector
        scopeMatches = scope.matchesSelector selector
      else if scope.webkitMatchesSelector
        scopeMatches = scope.webkitMatchesSelector selector
      else if scope.mozMatchesSelector
        scopeMatches = scope.mozMatchesSelector selector

    if scopeMatches
      matches = Array.prototype.slice.call scope.querySelectorAll(selector)
      matches.push scope
      matches
    else
      scope.querySelectorAll selector

  # Replaces an element's contents with some HTML.
  #
  # The JavaScript inside the HTML's <script> tags will be executed.
  #
  # @param {HTMLElement} element the element whose contents will be replaced
  # @param {String}
  replaceHtml: (element, html) ->
    range = document.createRange()
    range.selectNode document.body
    fragment = range.createContextualFragment html
    element.innerHTML = ''
    element.appendChild fragment
    @wire element

  # The closest form element wrapping a node.
  #
  # @param {HTMLElement} element the element whose parent chain will be searched
  # @return {HTMLFormElement} the element's closest parent form, or null if the
  #     element is not wrapped in a <form>
  parentForm: (element) ->
    while element
      return element if element.nodeName is 'FORM'
      element = element.parentNode
    null

  # Do AJAX.
  #
  # @param {String} url the request URL (e.g., "http://localhost/path/to.html")
  # @param {String} method the request method (e.g., "POST")
  # @param [HTMLFormElement] form the DOM form whose data will be submitted
  # @param [function(data)] onData callback that receives the XHR data, if the
  #                                XHR completes successfully
  xhr: (url, method, form, onData) ->
    xhr = new XMLHttpRequest
    xhr.onload = @_xhr_onload
    xhr.pwnfxOnData = onData
    xhr.open method, url
    xhr.setRequestHeader 'X-Requested-With', 'XMLHttpRequest'
    if form
      xhr.send new FormData(form)
    else
      xhr.send null

  # Called when an XHR request issued by PwnFx.xhr works out.
  _xhr_onload: ->
    if (@status < 200 || @status >= 300) && (@status isnt 304)
      throw new Error(
          "XHR result ignored due to HTTP #{@status}: #{@statusText}")
    @pwnfxOnData @responseText

# Singleton instance.
PwnFx = new PwnFxClass


# Moves an element using data-pwnfx-move.
#
# Attributes:
#   data-pwnfx-move: an identifier connecting the move's target element
#   data-pwnfx-move-target: a space-separated list of identifiers, one of which
#       should match the value of data-pwnfx-move; set on the element that will
#       receive the moved element as its last child
#   data-pwnfx-move-method: 'append' adds the moved as the element as the
#       target's last child, 'replace' clears the target element, then adds the
#       moved element as the target's only child
class PwnFxMove
  constructor: (element, identifier, scopeId) ->
    scope = PwnFx.resolveScope scopeId, element
    method = element.getAttribute('data-pwnfx-move-method') || 'append'
    target = document.querySelector "[data-pwnfx-move-target~=\"#{identifier}\"]"

    switch method
      when 'append'
        target.appendChild element
      when 'replace'
        target.innerHTML = ''
        target.appendChild element
      else
        throw new Error("pwnfx-move-method #{method} not implemented")


PwnFx.registerEffect 'move', PwnFxMove


# Renders the contents of a template into a DOM element.
#
# Attributes:
#   data-pwnfx-render: identifier for the render operation
#   data-pwnfx-render-where: insertAdjacentHTML position argument; can be
#       beforebegin, afterbegin, beforeend, afterend; defaults to beforeend
#   data-pwnfx-render-randomize: regexp pattern whose matches will be replaced
#       with a random string; useful for generating unique IDs
#   data-pwnfx-render-target: a space-separated list of identifiers, one of
#       which should match the value of data-pwnfx-render; set on the element(s)
#       receiving the rendered HTML
#   data-pwnfx-render-source: set to the identifier in data-pwnfx-render, on the
#       <script> tag containing the source HTML
class PwnFxRender
  constructor: (element, identifier, scopeId) ->
    sourceSelector = "script[data-pwnfx-render-source=\"#{identifier}\"]"
    targetSelector = "[data-pwnfx-render-target~=\"#{identifier}\"]"
    insertionPoint = element.getAttribute('data-pwnfx-render-where') ||
                     'beforeend'
    randomizedPatten = element.getAttribute('data-pwnfx-render-randomize')
    if randomizedPatten
      randomizeRegExp = new RegExp(randomizedPatten, 'g')
    else
      randomizeRegExp = null

    onClick = (event) ->
      scope = PwnFx.resolveScope scopeId, element
      source = scope.querySelector sourceSelector
      html = source.innerHTML
      if randomizeRegExp
        # The id has to be completely numerical, otherwise strong_parameters
        # will think it's an attribute and reject it.
        randomId = Date.now() + Math.random().toString().substring(2)
        html = html.replace randomizeRegExp, randomId
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        targetElement.insertAdjacentHTML insertionPoint, html
        PwnFx.wire targetElement
      event.preventDefault()
      false
    element.addEventListener 'click', onClick, false

PwnFx.registerEffect 'render', PwnFxRender


# Loads some content after the main page load via an AJAX request.
#
# The text / HTML returned by the request is placed in another element. Scripts
# in <script> tags are executed.
#
# Element attributes:
#   data-pwnfx-delayed: identifier connecting the AJAX data receiver
#   data-pwnfx-delayed-url: URL to perform an AJAX request to
#   data-pwnfx-delayed-method: the HTTP method of AJAX request (default: POST)
#   data-pwnfx-delayed-ms: the delay between the page load and the issuing of
#                          the AJAX request (default: 1000ms)
#   data-pwnfx-delayed-target: a space-separated list of identifiers, one of
#       which should match the value of data-pwnfx-delayed; set on the element
#       populated with the AJAX response
class PwnFxDelayed
  constructor: (element, identifier, scopeId) ->
    targetSelector = "[data-pwnfx-delayed-target~=\"#{identifier}\"]"
    xhrUrl = element.getAttribute('data-pwnfx-delayed-url')
    xhrMethod = element.getAttribute('data-pwnfx-delayed-method') || 'POST'
    xhrForm = PwnFx.parentForm element
    delay = parseInt(
        element.getAttribute('data-pwnfx-delayed-ms') || '1000');

    ajaxLoad = ->
      PwnFx.xhr xhrUrl, xhrMethod, xhrForm, (data) ->
        scope = PwnFx.resolveScope scopeId, element
        for targetElement in PwnFx.queryScope(scope, targetSelector)
          PwnFx.replaceHtml targetElement, data

    window.setTimeout ajaxLoad, delay

PwnFx.registerEffect 'delayed', PwnFxDelayed


# Fires off an AJAX request (almost) every time when an element changes.
#
# The text / HTML returned by the request is placed in another element. Scripts
# in <script> tags are executed.
#
# Element attributes:
#   data-pwnfx-refresh: identifier connecting the AJAX data receiver
#   data-pwnfx-refresh-url: URL to perform an AJAX request to
#   data-pwnfx-refresh-method: the HTTP method of AJAX request (default: POST)
#   data-pwnfx-refresh-ms: delay between a change on the source element and
#                          AJAX refresh requests (default: 200ms)
#   data-pwnfx-refresh-target: a space-separated list of identifiers, one of
#       which should match the value of data-pwnfx-refresh; set on the element
#       populated with the AJAX response
class PwnFxRefresh
  constructor: (element, identifier, scopeId) ->
    targetSelector = "[data-pwnfx-refresh-target~=\"#{identifier}\"]"
    xhrUrl = element.getAttribute('data-pwnfx-refresh-url')
    xhrMethod = element.getAttribute('data-pwnfx-refresh-method') || 'POST'
    xhrForm = PwnFx.parentForm element
    refreshDelay = parseInt(
        element.getAttribute('data-pwnfx-refresh-ms') || '200');

    onXhrData = (data) ->
      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        PwnFx.replaceHtml targetElement, data

    changeTimeout = null
    refreshOldValue = null
    ajaxRefresh = ->
      changeTimeout = null
      PwnFx.xhr xhrUrl, xhrMethod, xhrForm, onXhrData

    onChange = ->
      value = element.value
      return true if value is refreshOldValue
      refreshOldValue = value

      window.clearTimeout changeTimeout if changeTimeout isnt null
      changeTimeout = window.setTimeout ajaxRefresh, refreshDelay
      true

    element.addEventListener 'change', onChange, false
    element.addEventListener 'keydown', onChange, false
    element.addEventListener 'keyup', onChange, false

PwnFx.registerEffect 'refresh', PwnFxRefresh


# Shows elements conditionally, depending on whether some inputs' values match.
#
# Element attributes:
#   data-pwnfx-confirm: all elements with the same value for this attribute
#       belong to the same confirmation group; their values have to match to
#       trigger the "win" condition
#   data-pwnfx-confirm-class: the CSS class that is added to hidden elements;
#       by default, this is {PwnFx.hiddenClassName}, which gets its value from
#       the data-pwnfx-hidden-class attribute on <body>
#   data-pwnfx-confirm-win: CSS selector identifying the elements to be shown
#       when the "win" condition is triggered, and hidden otherwise
#   data-pwnfx-confirm-fail: CSS selector identifying the elements to be hidden
#       when the "win" condition is triggered, and shown otherwise
class PwnFxConfirm
  constructor: (element, identifier, scopeId) ->
    hiddenClass = element.getAttribute('data-pwnfx-confirm-class') ||
                  PwnFx.hiddenClassName
    sourceSelector = "[data-pwnfx-confirm-done=\"#{identifier}\"]"
    winSelector = "[data-pwnfx-confirm-win=\"#{identifier}\"]"
    failSelector = "[data-pwnfx-confirm-fail=\"#{identifier}\"]"

    onChange = ->
      scope = PwnFx.resolveScope scopeId, element
      value = null
      matching = true
      for sourceElement, index in PwnFx.queryScope(scope, sourceSelector)
        if index is 0
          value = sourceElement.value
        else if sourceElement.value isnt value
          matching = false
          break

      hideSelector = if matching then failSelector else winSelector
      showSelector = if matching then winSelector else failSelector
      for targetElement in PwnFx.queryScope(scope, showSelector)
        targetElement.classList.remove hiddenClass
      for targetElement in PwnFx.queryScope(scope, hideSelector)
        targetElement.classList.add hiddenClass
      true
    onChange()

    element.addEventListener 'change', onChange, false
    element.addEventListener 'keydown', onChange, false
    element.addEventListener 'keyup', onChange, false

PwnFx.registerEffect 'confirm', PwnFxConfirm


# Shows / hides elements when an element is clicked or checked / unchecked.
#
# Attributes:
#   data-pwnfx-hide: a name for the events caused by this element's triggering
#   data-pwnfx-hide-trigger: "click" means events are triggered when the
#       element is clicked, "checked" means events are triggered when the
#       element is checked; (default: click)
#   data-pwnfx-hide-class: the CSS class that is added to hidden elements;
#       by default, this is {PwnFx.hiddenClassName}, which gets its value from
#       the data-pwnfx-hidden-class attribute on <body>
#   data-pwnfx-hide-positive: set to the same value as data-pwnfx-hide on
#       elements that will be hidden when a positive event (click / check) is
#       triggered, and shown when a negative event (uncheck) is triggered
#   data-pwnfx-hide-negative: set to the same value as data-pwnfx-hide on
#       elements that will be shown when a positive event (click / check) is
#       triggered, and hidden when a negative event (uncheck) is triggered
class PwnFxHide
  constructor: (element, identifier, scopeId) ->
    trigger = element.getAttribute('data-pwnfx-hide-trigger') || 'click'
    hiddenClass = element.getAttribute('data-pwnfx-hide-class') ||
                  PwnFx.hiddenClassName
    positiveSelector = "[data-pwnfx-hide-positive=\"#{identifier}\"]"
    negativeSelector = "[data-pwnfx-hide-negative=\"#{identifier}\"]"
    onChange = (event) ->
      positive = (trigger is 'click') || element.checked
      hideSelector = if positive then positiveSelector else negativeSelector
      showSelector = if positive then negativeSelector else positiveSelector

      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, hideSelector)
        targetElement.classList.add hiddenClass
      for targetElement in PwnFx.queryScope(scope, showSelector)
        targetElement.classList.remove hiddenClass
      if trigger is 'click'
        event.preventDefault()
        false
      else
        true

    if trigger is 'click'
      element.addEventListener 'click', onChange, false
    else if trigger is 'checked'
      element.addEventListener 'change', onChange, false
      onChange()
    else
      throw new Error("Unimplemented pwnfx-hide trigger #{trigger}")

PwnFx.registerEffect 'hide', PwnFxHide

# Disables / enables elements when an element is clicked or checked / unchecked.
#
# Attributes:
#   data-pwnfx-disable: a name for the events caused by this element's triggering
#   data-pwnfx-disable-trigger: "click" means events are triggered when the
#       element is clicked, "checked" means events are triggered when the
#       element is checked; (default: click)
#   data-pwnfx-disable-positive: set to the same value as data-pwnfx-disable on
#       elements that will be disabled when a positive event (click / check) is
#       triggered, and enabled when a negative event (uncheck) is triggered
#   data-pwnfx-disable-negative: set to the same value as data-pwnfx-disable on
#       elements that will be enabled when a positive event (click / check) is
#       triggered, and disabled when a negative event (uncheck) is triggered
class PwnFxDisable
  constructor: (element, identifier, scopeId) ->
    trigger = element.getAttribute('data-pwnfx-disable-trigger') || 'click'
    positiveSelector = "[data-pwnfx-disable-positive=\"#{identifier}\"]"
    negativeSelector = "[data-pwnfx-disable-negative=\"#{identifier}\"]"
    onChange = (event) ->
      positive = (trigger is 'click') || element.checked
      disableSelector = if positive then positiveSelector else negativeSelector
      enableSelector = if positive then negativeSelector else positiveSelector

      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, disableSelector)
        targetElement.disabled = true
      for targetElement in PwnFx.queryScope(scope, enableSelector)
        targetElement.disabled = false
      if trigger is 'click'
        event.preventDefault()
        false
      else
        true

    if trigger is 'click'
      element.addEventListener 'click', onChange, false
    else if trigger is 'checked'
      element.addEventListener 'change', onChange, false
      onChange()
    else
      throw new Error("Unimplemented pwnfx-disable trigger #{trigger}")

PwnFx.registerEffect 'disable', PwnFxDisable


# Shows / hides elements in a DOM depending on an input's value.
#
# Attributes:
#   data-pwnfx-showif: an identifier that connects the source <input>
#   data-pwnfx-showif-replace: the name of a tag that will be used to replace
#       the hidden element (default: don't replace the hidden element)
#   data-pwnfx-showif-class: the CSS class that is added to hidden elements;
#       by default, this is {PwnFx.hiddenClassName}, which gets its value from
#       the data-pwnfx-hidden-class attribute on <body>
#   data-pwnfx-showif-is: the value that the <input> has to match for this
#       element to be shown
#   data-pwnfx-showif-source: set to the identifier in data-pwnfx-showif
#       on the <input> whose value determines if this element is shown or not
class PwnFxShowIf
  constructor: (element, identifier, scopeId) ->
    hiddenClass = element.getAttribute('data-pwnfx-showif-class') ||
                  PwnFx.hiddenClassName
    showValue = element.getAttribute 'data-pwnfx-showif-is'
    sourceSelector = "[data-pwnfx-showif-source=\"#{identifier}\"]"

    replacementTag = element.getAttribute 'data-pwnfx-showif-replace'
    if replacementTag
      replacement = document.createElement replacementTag
      replacement.setAttribute 'class', hiddenClass
    else
      replacement = null

    isHidden = false
    onChange = (event) ->
      value = event.target.value
      willHide = value isnt showValue
      return if isHidden is willHide
      isHidden = willHide

      if replacement
        if willHide
          element.parentElement.replaceChild replacement, element
        else
          replacement.parentElement.replaceChild element, replacement
      else
        if willHide
          element.classList.add hiddenClass
        else
          element.classList.remove hiddenClass
      true

    scope = PwnFx.resolveScope scopeId, element
    for sourceElement in PwnFx.queryScope(scope, sourceSelector)
      sourceElement.addEventListener 'change', onChange, false
      sourceElement.addEventListener 'keydown', onChange, false
      sourceElement.addEventListener 'keyup', onChange, false
      onChange target: sourceElement

PwnFx.registerEffect 'showif', PwnFxShowIf


# Removes elements from the DOM when an element is clicked.
#
# Attributes:
#   data-pwnfx-remove: an identifier connecting the elements to be removed
#   data-pwnfx-remove-target: a space-separated list of identifiers, one of
#       which should match the value of data-pwnfx-remove; set on elements that
#       will be removed when the element is clicked
class PwnFxRemove
  constructor: (element, identifier, scopeId) ->
    targetSelector = "[data-pwnfx-remove-target~=\"#{identifier}\"]"

    onClick = (event) ->
      scope = PwnFx.resolveScope scopeId, element
      for targetElement in PwnFx.queryScope(scope, targetSelector)
        targetElement.parentNode.removeChild targetElement
      event.preventDefault()
      false
    element.addEventListener 'click', onClick, false

PwnFx.registerEffect 'remove', PwnFxRemove


# Export the PwnFx instance.
window.PwnFx = PwnFx

# Wire up the entire DOM after the document is loaded.
if document.readyState is 'loading'
  loaded = false
  document.addEventListener 'readystatechange', ->
    return if loaded
    if document.readyState isnt 'loading'
      PwnFx.wire(document)
      loaded = true
else
  PwnFx.wire document
