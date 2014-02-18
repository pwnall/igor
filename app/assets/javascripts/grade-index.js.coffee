$ ->
  $('#comments-toggle-button').click ->
    gradeDiv = $(this).parent('h3').next('div.grades')
    gradeDiv.toggleClass 'show-comments'
    if gradeDiv.hasClass 'show-comments'
      $(this).html('Hide Comments')
    else
      $(this).html('Show Comments')
