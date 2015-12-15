class AttendanceRoster
  # Toggles DOM classes in an indicator container to reflect an event.
  #
  # @param {jQuery} $indicator DOM element that hosts the indicator image
  # @param {String} activeClass the indicator that will be shown
  # @param {Number, Boolean} temporary if not false, the indicator will be
  #   hidden after the number of milliseconds in this argument
  # @return {GradeEditor} this
  setIndicator: ($indicator, activeClass, temporary) ->
    if activeClass.length is 0
      $indicator.attr 'class', 'progress-indicator'
    else
      $indicator.attr 'class', 'progress-indicator ' + activeClass

    if temporary isnt false
      remove = =>
        @setIndicator $indicator, '', false
      setTimeout remove, temporary
    @

  # Confirms/unconfirms attendance via AJAX if it is changed.
  _onDataFieldChange: (event) ->
    $target = $ event.target
    $td = $target.parents('td').first()
    $row = $target.parents('tr').first()

    @uploadFieldData $target, $td, $row
    return

  # Tabs to the next confirmation field or name search field.
  _onDataFieldKeyDown: (event) ->
    return true unless event.which is 9
    $target = $ event.target

    nextRow = $target.closest('tr').next('tr:not(.hide)')
    if nextRow.length is 0
      nextField = @$search
    else
      nextField = nextRow.find('td.attendance input[type=checkbox]')

    nextField.focus()
    return false

  # Reflects a successful confirmation status save.
  _onAjaxSuccess: ($target, data) ->
    $container = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-win', 2000
    return

  # Reflects an unsuccessful confirmation status save.
  _onAjaxError: ($target) ->
    $container = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-fail', 10000
    return

  # Uploads an attendance confirmation status.
  uploadFieldData: ($field, $td, $row) ->
    $indicator = $ '.progress-indicator', $td
    @setIndicator $indicator, 'upload-pending', false

    trIndex = @$rows.index $row
    return if trIndex is -1

    attendanceId = $row.attr 'data-attendance-id'
    fieldValue = $field[0].checked

    url = "/#{@courseNumber}/attendances/#{attendanceId}.html"
    data =
        'attendance[confirmed]': fieldValue

    $.ajax url,
      data: data, dataType: 'text', method: 'patch',
      success: (data, status, xhr) => @_onAjaxSuccess $field, data
      error: (xhr, status, error) => @_onAjaxError $field

  # Hides and shows attendance rows to reflect searchbox changes
  _onSearchChange: (event) ->
    nameFilter = (@$search.val() or '').toLowerCase()
    if nameFilter is @oldNameFilter
      return
    @oldNameFilter = nameFilter

    if nameFilter is '' or nameFilter.length is 1
      # Fast path for empty queries.
      for row in @$rows
        row.removeAttribute 'class'
      return

    for row, index in @$rows
      name = @studentNames[index]
      if name.indexOf(nameFilter) is -1
        row.setAttribute 'class', 'hide'
      else
        row.removeAttribute 'class'

    return

  # Avoids applying the same name filter twice
  oldNameFilter: null

  # Sets up the attendance confirmation roster.
  #
  # @private
  # Called by {GradeEditor.setup}.
  #
  # @param {Element} domRoot the DOM element that is hosts all the control's
  #   elements
  constructor: (@domRoot) ->
    @$table = $ @domRoot

    @studentNames = []
    @$rows = $ 'tbody tr[data-student-name]', @$table
    for row in @$rows
      @studentNames.push row.getAttribute('data-student-name').toLowerCase()
    @courseNumber = @$table[0].getAttribute('data-course-number')

    @oldNameFilter = ''

    # Event handler functions are bound to the instance, Python-style.
    @_onDataFieldChange = @_onDataFieldChange.bind @
    @_onDataFieldKeyDown = @_onDataFieldKeyDown.bind @
    @_onSearchChange = @_onSearchChange.bind @
    @_onAjaxSuccess = @_onAjaxSuccess.bind @
    @_onAjaxError = @_onAjaxError.bind @

    @$table.
        on('change', 'input[type=checkbox]', @_onDataFieldChange).
        on('keydown', 'input[type=checkbox]', @_onDataFieldKeyDown).
        on('ajax:success', 'form', @_onAjaxSuccess).
        on('ajax:error', 'form', @_onAjaxError)

    @$search = $('input[type=search]', @$table).first()
    @$search.
        on('change', @_onSearchChange).
        on('textInput', @_onSearchChange).
        on('input', @_onSearchChange).
        on('keydown', @_onSearchChange)

  # If the page has a roster, wires it up to a AttendanceRoster instance.
  @setup: ->
    domRoot = $('table#attendances-table')[0]
    window.attendanceRoster = if domRoot
      new AttendanceRoster domRoot
    else
      null

$(document).ready AttendanceRoster.setup
window.AttendanceRoster = AttendanceRoster
