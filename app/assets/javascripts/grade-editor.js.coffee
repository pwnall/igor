# Namespace #
window.GradeEditor = {}

#
# Toggles DOM classes in an indicator container to reflect an event
# 
# @param indicators DOM element containing the indicator images
# @param activeClass the indicator class that will be shown
# @param temporary if true, the indicator will be hidden after a bit of time
#
GradeEditor.setIndicator = (indicators, activeClass, temporary) ->
  $('img', indicators).each ->
    element = $ @
    if element.hasClass activeClass
      element.removeClass 'hidden'
    else
      element.addClass 'hidden'
  
  if temporary
    remove = ->
      GradeEditor.setIndicator indicators, '-', false
    setTimeout remove, temporary

# Saves a grade via AJAX if it is changed
GradeEditor.onBlur = (event) ->
  target = $ event.target
  target.parents('tr').first().removeClass 'focused'
  GradeEditor.redoSummary target.parents('tr').first()

  oldValue = target.attr 'data-old-value'
  return if target.val() is oldValue

  form = target.parents('form').first()
  indicators = $ '.progress-indicators', form
  GradeEditor.setIndicator indicators, 'upload-pending', false
  form.submit()

# Takes note of a grade's current value
GradeEditor.onFocus = (event) ->
  target = $ event.target
  target.attr 'data-old-value', target.val()
  target.parents('tr').first().addClass 'focused'

# Tabs to the next window if the user presses Enter
GradeEditor.onKeyDown = (event) ->
  if event.which is 13
    event.preventDefault()

    # table = $(event.target).parents('table').first()
    fields = []
    myIndex = null
    $('tr:not(.hidden) input[type=number]').each (index, e) ->
      fields[index] = e
      if event.target is e
        myIndex = index
    
    # Cycle to the beginning after reaching the last field
    nextField = fields[myIndex + 1] or fields[0]
    $(nextField).focus()
    return false

# Reflects a successful grade save
GradeEditor.onAjaxSuccess = (event, data, status, xhr) ->
  container = $(event.target).parent()
  container.html data
  input = container.find "input[type=number]"
  # hacky thing
  input.on('blur', GradeEditor.onBlur)
    .on('focus', GradeEditor.onFocus)
    .on('keydown', GradeEditor.onKeyDown)
  indicators = $ '.progress-indicators', container
  GradeEditor.setIndicator indicators, 'upload-win', 1000

# Reflects an unsuccessful grade save
GradeEditor.onAjaxError = (event, data, status, xhr) ->
  indicators = $ '.progress-indicators', event.target
  GradeEditor.setIndicator indicators, 'upload-fail', 5000

# Re-computes the summary values for a collection of grades
GradeEditor.redoSummary = (row) ->
  sum = 0
  $('input[type=number]', row).each (index, e) ->
    sum += parseFloat $(e).val() or 0
  $('span.grade-sum', row).text sum.toFixed(2)

# Hides and shows grade rows to reflect searchbox changes
GradeEditor.onSearchChange = (event) ->
  search = $ event.target
  nameFilter = (search.val() or '').toLowerCase()
  if nameFilter is GradeEditor.onSearchChange.oldNameFilter
    return
  GradeEditor.onSearchChange.oldNameFilter = nameFilter

  table = search.parents('table').first()
  $('tr[data-subject-name]', table).each ->
    e = $ @
    name = e.attr 'data-subject-name'
    if nameFilter is '' or name.toLowerCase().indexOf(nameFilter) isnt -1
      e.removeClass 'hidden'
    else
      e.addClass 'hidden'

# Avoids applying the same name filter twice
GradeEditor.onSearchChange.oldNameFilter = ""

# Wires event listeners into the DOM
GradeEditor.onLoad = ->
  $('table.grades-table input[type=number]')
    .on('blur', GradeEditor.onBlur)
    .on('focus', GradeEditor.onFocus)
    .on('keydown', GradeEditor.onKeyDown)
  $('table.grades-table input[type=search]')
    .on('change', GradeEditor.onSearchChange)
    .on('textInput', GradeEditor.onSearchChange)
    .on('input', GradeEditor.onSearchChange)
    .on('keydown', GradeEditor.onSearchChange)
  $('table.grades-table form')
    .on('ajax:success', GradeEditor.onAjaxSuccess)
    .on('ajax:error', GradeEditor.onAjaxError)
  $('table.grades-table tbody tr').each (index, row) ->
    GradeEditor.redoSummary row

$ GradeEditor.onLoad
