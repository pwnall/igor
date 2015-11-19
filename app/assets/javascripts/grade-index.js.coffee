$ ->
  $('.comments-toggle-button').click ->
    gradeList = $(this).closest('.assignment-name').next('.grades-list')
    gradeList.toggleClass 'show-comments'
    if gradeList.hasClass 'show-comments'
      $(this).html('Hide Comments')
    else
      $(this).html('Show Comments')
