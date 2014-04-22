class @Plush
  defaults:
    labelMethod:          'label'
    listItemTemplate:     'plush_list_item'
    optgroupTemplate:     'plush_optgroup_item'
    multiSelectTemplate:  'plush_multi_select_item'
    noResultsTemplate:    'plush_no_results'
    noResultsMessage:     'No results were found for: '
    position:             'bottom'
    url:                  null
    preload:              false
    queryDefault:         'q'

  constructor: (@element, @options={}) ->
    # Hide original and wrap with container
    @element.hide()
    @element.wrap '<div class="plush-container"></div>'
    @container = @element.parent()
    @container.append $.handlebar('plush_input', {placeholder: @element.attr('placeholder')})

    @list =           $('.plush-option-list', @container)
    @inputContainer = $('.plush-input-wrapper', @container)
    @placeholder =    $('.plush-placeholder', @inputContainer)
    @input =          $('input', @inputContainer)
    @initialOption =  @getOption(false, true)

    # Option setting
    @queryData = @getQueryDataFromElement(@element.get(0))
    @queryData = {} unless @queryData?
    @searchWithAjax = @element.data('query')?

    for key, value of @defaults
      @setDefaultOption key, value

    @addClassnames()
    @setPlaceholders()
    @element.attr 'tabindex', -1

    # Fill list
    if @options.url?
      if !@searchWithAjax || (@searchWithAjax && @options.preload)
        @createListFromSource(true)
      else
        @checkInitialOption()
    else
      if $('optgroup', @element).length > 0
        @createListFromGroupedOptions()
      else
        @createListFromOptions()

    @checkResults()
    @setup()
    @setEventHandlers()
    return @

  setPlaceholders: ->
    if $('option[selected]', @element).length > 0
      @placeholder.html $('option[selected]', @element).html()
      @input.val $('option[selected]', @element).html()

  setup: ->
    unless @initialOption.length > 0
      if @element.attr('placeholder')? &&
        @element.prop('selectedIndex', -1)
      else
        @setOptionFor $('li:first-child', @list)

  addClassnames: ->
    @list.addClass @options.listItemTemplate.replace(/\_/g, '-')
    @container.addClass "position-#{@options.position}"

  setDefaultOption: (key, value) ->
    unless @options[key]?
      dataAttrName = key.replace /([A-Z])/g, ($1) -> "-" + $1.toLowerCase()
      @options[key] = @element.data(dataAttrName) || value

  setOptionFor: (listItem) ->
    @setOption listItem.data('label'), listItem.data('value')

  setOption: (label, value) ->
    @placeholder.html label
    if @options.url?
      @element.empty()
      @createOption label, value
    else
      @element.val value

    @hide(true)
    @element.trigger 'change'

  createOption: (label, value, selected = true) ->
    unless @getOption(value).length > 0
      @element.append "<option value=#{value}#{ if selected then ' selected' else ''}>#{label}</option>"

    @element.trigger 'change'

  removeOption: (value) ->
    $("option[value=#{value}]", @element).remove()
    @element.trigger 'change'

  getOption: (value = false, withSelected = false) ->
    selector = [
      (if value != false  then "[value=#{value}]"    else ''),
      (if withSelected    then '[selected]' else '')
    ].join('')
    $option = $(selector, @element)

  focusAnchor: (anchor) ->
    anchor.focus()
    anchor.addClass 'focused'

  blurAnchor: (anchor) ->
    anchor.blur()
    anchor.removeClass 'focused'

  nextAnchor: (anchor) ->
    $li = anchor.parents('li').first()
    next = $('a', $li.next())
    if next && !next.parents('li').first().hasClass('hidden') then next else @nextAnchor(next)

  prevAnchor: (anchor) ->
    $li = anchor.parents('li').first()
    prev = $('a', $li.prev())
    if prev && !prev.parents('li').first().hasClass('hidden') then prev else @prevAnchor(prev)

  nextOrPreviousAnchor: (anchor) ->
    if @nextAnchor(anchor).length > 0
      @nextAnchor(anchor)
    else if @prevAnchor(anchor).length > 0
      @prevAnchor(anchor)

  hasFocus: () ->
    $('*:focus', @container).length > 0

  # --------------------------------------
  # Search methods
  # --------------------------------------

  delayedSearch: ->
    clearTimeout(@timer) if @timer?
    @timer = setTimeout @bind(@createListFromSource), 500

  search: (query) ->
    matcher = new RegExp(query, 'i')
    $('.plush-list-item a', @container).each ->
      $listElement = $(this).parents('.plush-list-item').first()

      if matcher.test($(this).html())
        $listElement.removeClass('hidden') unless $listElement.hasClass('disabled')
      else
        $listElement.addClass('hidden')

    $('.plush-optgroup', @container).each ->
      $element = $(this)
      if $('.plush-list-item:not(.hidden)', $element).length == 0
        $element.hide()
      else
        $element.show()

    @resizeList()
    @checkResults()

  checkResults: ->
    if $('li:not(.hidden)', @list).length == 0
      @showNoResults()
    else
      @hideNoResults()

  # No results message
  showNoResults: ->
    msg = @options.noResultsMessage + @input.val()

    if $('.plush-no-results', @list).length == 0
      @list.append $.handlebar(@options.noResultsTemplate, {message: msg})
    else
      $('.plush-no-results', @list).html(msg)
      $('.plush-no-results', @list).show()

  hideNoResults: ->
    $('.plush-no-results', @list).hide()

  resizeList: ->
    if @options.position == 'top'
      @list.css 'top', "-#{@list.outerHeight(true)}px"

  # Input togglers for autocompletion behaviour
  show: ->
    @placeholder.hide()
    @input.css 'display', 'block'
    @inputContainer.addClass 'opened'
    @list.show()
    @input.focus() unless @input.is(":focus")

  hide: (force = false) ->
    if !@hasFocus() || force
      @showPlaceholder()
      @inputContainer.removeClass 'opened'
      @input.hide()
      @list.hide()

  showPlaceholder: () ->
    @placeholder.show()

  getAttributesFromElement: (element, attr_regexp) ->
    options = {}
    for attr in element.attributes
      options[attr.nodeName.replace(attr_regexp, '')]= attr.nodeValue if attr.nodeName.match(attr_regexp)
    options

  getDataFromElement: (element) ->
    @getAttributesFromElement element, /^data-/

  getQueryDataFromElement: (element) ->
    @getAttributesFromElement element, /^data-query-/

  bind: ( method ) ->
    () =>
      method.apply( @, arguments )

