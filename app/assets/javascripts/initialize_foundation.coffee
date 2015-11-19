$(document).foundation()
hash = window.location.hash
if hash
  # Open the Foundation tab whose URL matches the requested hash.
  # http://foundation.zurb.com/sites/docs/tabs.html
  $("[data-tabs] [href=\"#{hash}\"]").click()
