Plush::setEventHandlers = ->
  @inputContainer.on 'click', '.plush-placeholder, .plush-caret', (event) =>
    event.preventDefault()
    @show()

  # User event behaviour
  @container.on 'blur', 'input, a', =>
    setTimeout @bind(@hide), 100

  # input element events
  @input.on 'focus', =>
    @show() unless @inputContainer.hasClass 'opened'
  .on 'keyup', (event) =>
    event.stopPropagation()
    @handleInputKeyPress(event)

  # Dropdown list events
  @list.on 'mousedown keydown keyup', 'a', (event) =>
    event.preventDefault()
    event.stopPropagation()
  .on 'mousedown', 'a', (event) =>
    @setOptionFor $(event.currentTarget).parents('li').first()
  .on 'click', 'a', (event) =>
    event.preventDefault()
  .on 'keyup', 'a', (event) =>
    @handleListKeyPress(event)
  .on 'blur', 'a', (event) ->
    $(this).removeClass 'focused'

  @element.trigger 'initialized'

Plush::handleInputKeyPress = (event) ->
  if event.which == 38 || event.which == 40 # Up & Down keys
    event.preventDefault()
    @focusAnchor($('li:not(.hidden):last a', @list))  if event.which == 38
    @focusAnchor($('li:not(.hidden):first a', @list)) if event.which == 40
  else if event.which == 27 # Escape key
    @input.blur()
  else
    if @searchWithAjax
      @delayedSearch()
    else
      @search @input.val()

Plush::handleListKeyPress= (event) ->
  $anchor = $(event.currentTarget)

  # Up / Down key
  if event.which == 38 || event.which == 40
    $link = @prevAnchor($anchor) if event.which == 38
    $link = @nextAnchor($anchor) if event.which == 40
    if !$link.length > 0 then @input.focus() else @focusAnchor($link)

  # Escape key
  if event.which == 27
    @input.focus()

  # Enter key
  if event.which == 13
    $anchor = $(event.currentTarget)
    $item = $anchor.parents('li').first()
    @setOptionFor $item
    @blurAnchor $anchor