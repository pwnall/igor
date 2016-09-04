$ ->
  clipboard = new Clipboard 'button[data-clipboard-target]'
  clipboard.on 'success', (event) ->
    # TODO(pwnall): show some notification
  clipboard.on 'error', (event) ->
    # TODO(pwnall): show some notification
