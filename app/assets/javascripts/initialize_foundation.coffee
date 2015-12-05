$(document).foundation()

$(document).on 'change.zf.tabs', (event) ->
  if href = $('.is-active a', event.target).attr 'href'
    if window.location.hash != href
      window.history.pushState null, '', href
  true

onHashChange = ->
  hash = window.location.hash
  if hash
    # Open the Foundation tab whose URL matches the requested hash.
    # http://foundation.zurb.com/sites/docs/tabs.html
    $("[data-tabs] [href=\"#{hash}\"]").click()
  true
$(window).on 'hashchange', onHashChange
onHashChange()
