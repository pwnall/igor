class GradeEditor
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

  # Saves a grade via AJAX if it is changed.
  _onDataFieldBlur: (event) ->
    $target = $ event.target
    $td = $target.parents('td').first()
    $td.removeClass 'focused'
    $row = $target.parents('tr').first()
    $row.removeClass 'focused'
    @redoSummary $row

    lastFocusedElement = @lastFocusedElement
    @lastFocusedElement = null

    # Don't post data that hasn't changed.
    if lastFocusedElement is $target[0] and
        @lastFocusedValue is $target.val()
      return

    @uploadFieldData $target, $td, $row
    return

  # Takes note of a grade's current value.
  _onDataFieldFocus: (event) ->
    unless @lastFocusedElement is null
      @_onDataFieldBlur target: @lastFocusedElement
      @lastFocusedElement = null

    $target = $ event.target
    $td = $target.parents('td').first()
    $td.addClass 'focused'
    $row = $target.parents('tr').first()
    $row.addClass 'focused'

    # NOTE: This makes sure that the <textarea> never gets display: none while
    #       the focus shifts from a <td> to the <textarea>.
    #       Details in https://github.com/pwnall/seven/issues/84
    $td.removeClass 'focused-latch'

    @lastFocusedElement = $target[0]
    @lastFocusedValue = $target.val()

    return

  # Tabs to the next grade field if the user presses Enter.
  _onDataFieldKeyDown: (event) ->
    event.preventDefault() if event.which in {13; 67}
    $target = $ event.target

    switch event.which
      when 13  # Enter
        nextField = $target.parents('td').next('td').
            find('input[type=number]')
        if nextField.length is 0
          nextField = $target.parents('tr').
              nextAll('tr:not(.hidden):first').
              find('td.grade:first input[type=number]')
        if nextField.length is 0
          nextField = $target.parents('tbody').
              children('tr:not(.hidden):first').
              find('td.grade:first input[type=number]')
      when 67  # C
        nextField = $target.parents('td').find('textarea')
      else
        return true

    # NOTE: This makes sure that the <textarea> never gets display: none while
    #       the focus shifts from a <td> to the <textarea>.
    #       Details in https://github.com/pwnall/seven/issues/84
    $td = $(nextField).parents('td').first()
    $td.addClass 'focused-latch'

    nextField.focus()
    false

  # Reflects a successful grade save.
  _onAjaxSuccess: ($target, data) ->
    $container = $target.parents('td').first()
    if $container.find(':focus').length == 0
      $container.html data
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-win', 2000
    return

  # Reflects an unsuccessful grade save.
  _onAjaxError: ($target) ->
    $container = $target.parents('td').first()
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-fail', 10000
    return

  # Uploads a grade or a comment.
  uploadFieldData: ($field, $td, $row) ->
    $indicator = $ '.progress-indicator', $td
    @setIndicator $indicator, 'upload-pending', false

    tdIndex = $('td', $row).index $td
    return if tdIndex is -1

    metricId = @metricIds[tdIndex]
    courseId = @metricCourseIds[tdIndex]
    subjectId = $row.attr 'data-subject-id'
    subjectType = $row.attr 'data-subject-type'
    fieldValue = $field.val()

    if $field.prop('tagName') is 'TEXTAREA'
      # Comment field.
      url = "/#{courseId}/grade_comments.html"
      data =
          'comment[subject_id]': subjectId
          'comment[subject_type]': subjectType
          'comment[metric_id]': metricId
          'comment[text]': fieldValue
    else
      # Grade field.
      url = "/#{courseId}/grades.html"
      data =
          'grade[subject_id]': subjectId
          'grade[subject_type]': subjectType
          'grade[metric_id]': metricId
          'grade[score]': fieldValue

    $.ajax url,
      data: data, dataType: 'text', method: 'post',
      success: (data, status, xhr) => @_onAjaxSuccess $field, data
      error: (xhr, status, error) => @_onAjaxError $field

  # Re-computes the summary values for a collection of grades.
  #
  # @param {jQuery} $row the DOM element holding a student's grades
  # @return {GradeEditor} this
  redoSummary: ($row) ->
    sum = 0
    $('input[type=number]', $row).each (index, input) =>
      sum += (parseFloat($(input).val()) or 0) * @metricWeights[index]
    $('span.grade-sum', $row).text sum.toFixed(2)
    @

  # Hides and shows grade rows to reflect searchbox changes
  _onSearchChange: (event) ->
    nameFilter = (@$search.val() or '').toLowerCase()
    if nameFilter is @oldNameFilter
      return
    @oldNameFilter = nameFilter

    if nameFilter is '' or nameFilter.length is 1
      # Fast path for empty queries.
      for row in @subjectRows
        row.removeAttribute 'class'
      return

    for row, index in @subjectRows
      name = @subjectNames[index]
      if name.indexOf(nameFilter) is -1
        row.setAttribute 'class', 'hidden'
      else
        row.removeAttribute 'class'

    return

  # Avoids applying the same name filter twice
  oldNameFilter: null

  # Sets up the grade edtor.
  #
  # @private
  # Called by {GradeEditor.setup}.
  #
  # @param {Element} domRoot the DOM element that is hosts all the control's
  #   elements
  constructor: (@domRoot) ->
    @$domRoot = $ @domRoot
    @$table = @$domRoot
    @lastFocusedElement = null
    @lastFocusedValue = null

    @metricCourseIds = []
    @metricIds = []
    @metricWeights = []
    for th in @domRoot.querySelectorAll('thead th[data-metric-id]')
      @metricCourseIds.push th.getAttribute('data-metric-course-id')
      @metricIds.push th.getAttribute('data-metric-id')
      @metricWeights.push th.getAttribute('data-metric-weight')

    @subjectRows = @domRoot.querySelectorAll 'tbody tr[data-subject-name]'
    @subjectNames = []
    for row in @subjectRows
      @subjectNames.push row.getAttribute('data-subject-name').toLowerCase()
      @redoSummary row

    @oldNameFilter = ''

    # Event handler functions are bound to the instance, Python-style.
    @_onDataFieldBlur = @_onDataFieldBlur.bind @
    @_onDataFieldFocus = @_onDataFieldFocus.bind @
    @_onDataFieldKeyDown = @_onDataFieldKeyDown.bind @
    @_onSearchChange = @_onSearchChange.bind @
    @_onAjaxSuccess = @_onAjaxSuccess.bind @
    @_onAjaxError = @_onAjaxError.bind @

    @$domRoot.
        on('blur', 'input[type=number], textarea', @_onDataFieldBlur).
        on('focus', 'input[type=number], textarea', @_onDataFieldFocus).
        on('keydown', 'input[type=number]', @_onDataFieldKeyDown).
        on('ajax:success', 'form', @_onAjaxSuccess).
        on('ajax:error', 'form', @_onAjaxError)

    @$search = $('input[type=search]', @domRoot).first()
    @$search.
        on('change', @_onSearchChange).
        on('textInput', @_onSearchChange).
        on('input', @_onSearchChange).
        on('keydown', @_onSearchChange)

  # If the page has a grade editor, wires it up to a GradeEditor instance.
  @setup: ->
    domRoot = $('table.grades-table')[0]
    window.gradeEditor = if domRoot
      new GradeEditor domRoot
    else
      null

$(document).ready GradeEditor.setup
window.GradeEditor = GradeEditor
