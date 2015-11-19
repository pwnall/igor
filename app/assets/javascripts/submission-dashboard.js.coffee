$ ->
  $('.collaborator-form-toggle-button').click ->
    collaboratorForm = $(this).closest('.collaborators-list').
        next('.new-collaborator-form')
    collaboratorForm.toggleClass 'hide'
    $(this).children('button.open-form').toggleClass 'hide'
    $(this).children('button.close-form').toggleClass 'hide'

    tabPanel = $(this).closest('.tabs-panel.is-active')
    tabPanel.css 'height', 'auto'
