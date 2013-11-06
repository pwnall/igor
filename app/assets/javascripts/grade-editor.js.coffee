class GradeEditor
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

  # Saves a grade via AJAX if it is changed.
  onBlur: (event) ->
    $target = $ event.target
    $target.parents('tr').first().removeClass 'focused'
    @redoSummary $target.parents('tr').first()

    oldValue = $target.attr 'data-old-value'
    return if $target.val() is oldValue

    $form = $target.parents('form').first()
    $indicator = $ '.progress-indicator', $form
    @setIndicator $indicator, 'upload-pending', false
    $form.submit()
    return

  # Takes note of a grade's current value.
  onFocus: (event) ->
    $target = $ event.target
    $target.attr 'data-old-value', $target.val()
    $target.parents('tr').first().addClass 'focused'
    return

  # Tabs to the next window if the user presses Enter.
  onKeyDown: (event) ->
    if event.which is 13
      event.preventDefault()

      fields = []
      myIndex = null
      # TODO(pwnall): make this O(1)
      $('tr:not(.hidden) input[type=number]').each (index, input) ->
        fields[index] = input
        if event.target is input
          myIndex = index

      # Cycle to the beginning after reaching the last field
      nextField = fields[myIndex + 1] or fields[0]
      $(nextField).focus()
      false
    else
      true

  # Reflects a successful grade save.
  onAjaxSuccess: (event, data, status, xhr) ->
    $container = $(event.target).parent()
    $container.html data
    $indicator = $ '.progress-indicator', $container
    @setIndicator $indicator, 'upload-win', 2000
    return

  # Reflects an unsuccessful grade save.
  onAjaxError: (event, data, status, xhr) ->
    $indicator = $ '.progress-indicator', event.target
    @setIndicator $indicator, 'upload-fail', 10000
    return

  # Re-computes the summary values for a collection of grades.
  #
  # @param {Element} row the DOM element holding a student's grades
  # @return {GradeEditor} this
  redoSummary: (row) ->
    sum = 0
    $('input[type=number]', row).each (index, e) ->
      sum += parseFloat $(e).val() or 0
    $('span.grade-sum', row).text sum.toFixed(2)
    @

  # Hides and shows grade rows to reflect searchbox changes
  onSearchChange: (event) ->
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
  # Called by {GradeEditor.onLoad}.
  #
  # @param {Element} domRoot the DOM element that is hosts all the
  #   control's elements
  constructor: (@domRoot) ->
    @$domRoot = $ @domRoot
    @$table = @$domRoot

    @subjectRows = @domRoot.querySelectorAll 'tbody tr[data-subject-name]'
    @subjectNames = []
    for row, index in @subjectRows
      @subjectNames[index] = row.getAttribute('data-subject-name').toLowerCase()
      @redoSummary row

    @oldNameFilter = ''

    # Event handler functions are bound to the instance, Python-style.
    @onBlur = @onBlur.bind @
    @onFocus = @onFocus.bind @
    @onKeyDown = @onKeyDown.bind @
    @onSearchChange = @onSearchChange.bind @
    @onAjaxSuccess = @onAjaxSuccess.bind @
    @onAjaxError = @onAjaxError.bind @

    @$domRoot.
        on('blur', 'input[type=number]', @onBlur).
        on('focus', 'input[type=number]', @onFocus).
        on('keydown', 'input[type=number]', @onKeyDown).
        on('ajax:success', 'form', @onAjaxSuccess).
        on('ajax:error', 'form', @onAjaxError)

    @$search = $('input[type=search]', @domRoot).first()
    @$search.
        on('change', @onSearchChange).
        on('textInput', @onSearchChange).
        on('input', @onSearchChange).
        on('keydown', @onSearchChange)

  # If the page has a grade editor, wires it up to a GradeEditor instance.
  @setup: ->
    domRoot = $('table.grades-table')[0]
    if domRoot
      window.gradeEditor = new GradeEditor domRoot
    else
      window.gradeEditor = null

$(document).ready GradeEditor.setup
window.GradeEditor = GradeEditor
