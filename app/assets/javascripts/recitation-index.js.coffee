class RegistrationIndex
  # Toggles DOM classes in an indicator container to reflect an event.
  #
  # @param {Element} indicator DOM element that hosts the indicator image
  # @param {String} activeClass the indicator that will be shown
  # @param {Number, Boolean} temporary if not false, the indicator will be
  #   hidden after the number of milliseconds in this argument
  # @return {GradeEditor} this
  setIndicator: (indicator, activeClass, temporary) ->
    if activeClass.length is 0
      $(indicator).attr 'class', 'progress-indicator'
    else
      $(indicator).attr 'class', 'progress-indicator ' + activeClass

    if temporary isnt false
      remove = =>
        @setIndicator indicator, '', false
      setTimeout remove, temporary
    @

  # Saves a recitation via AJAX.
  onChange: (event) ->
    $target = $ event.target
    $td = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $td
    @setIndicator $indicator, 'upload-pending', false

    $form = $td.find('form')
    $.ajax $form.attr('action'),
      data: $form.serialize(),
      dataType: 'text'
      method: 'post'
      success: (data, status, xhr) => @onAjaxSuccess $target, data
      error: (xhr, status, error) => @onAjaxError $target

    return

  # Reflects a successful recitation section save.
  onAjaxSuccess: ($target, data) ->
    $container = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-win', 2000
    return

  # Reflects an unsuccessful recitation section save.
  onAjaxError: ($target) ->
    $container = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-fail', 10000
    return

  # Sets up the recitation index.
  #
  # @private
  # Called by {GradeEditor.setup}.
  #
  # @param {Element} domRoot the DOM element that is hosts all the control's
  #   elements
  constructor: (@domRoot) ->
    @$domRoot = $ @domRoot

    # Event handler functions are bound to the instance, Python-style.
    @onChange = @onChange.bind @
    @onAjaxSuccess = @onAjaxSuccess.bind @
    @onAjaxError = @onAjaxError.bind @

    @$domRoot.
        on('change', 'select', @onChange).
        on('ajax:success', 'form', @onAjaxSuccess).
        on('ajax:error', 'form', @onAjaxError)

  # If the page has a recitations table, wires it up to a RegistrationIndex.
  @setup: ->
    domRoot = $('table.registrations-table')[0]
    window.registrationIndex = if domRoot
      new RegistrationIndex domRoot
    else
      null

$(document).ready RegistrationIndex.setup
window.RegistrationIndex = RegistrationIndex
