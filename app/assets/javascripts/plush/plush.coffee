class @Plush
  constructor: (@element, @options={}) ->
    # Hide original and wrap with container
    @element.hide()
    @element.wrap('<div class="plush-container"></div>')
    @container = @element.parent()
    @container.append $.handlebar('plush_input', {placeholder: @element.attr('placeholder')})

    @list = $('.plush-option-list', @container)
    @inputContainer = $('.plush-input-wrapper', @container)
    @placeholder = $('.plush-placeholder', @inputContainer)
    @input = $('input', @inputContainer)
    @options.multiple = @options.multiple? || @element.attr('multiple')?
    @searchWithAjax = @element.data('query')?

    # Option setting
    @setQueryDataOptions()
    @queryData = {} unless @queryData?
    @queryDefault = 'q'

    defaults =
      noResults:           'No results found for: '
      labelMethod:         'label'
      listItemTemplate:    'plush_list_item'
      optgroupTemplate:    'plush_optgroup_item'
      multiSelectTemplate: 'plush_multi_select_item'
      position:            'bottom'
      url:                 null

    for key, value of defaults
      @setDefaultOption key, value

    @list.addClass @options.listItemTemplate.replace(/\_/g, '-')
    @container.addClass "position-#{@options.position}"
    @container.addClass "plush-multiple" if @options.multiple?

    @element.attr 'tabindex', -1

    if $('option[selected]', @element).length > 0 && !@options.multiple
      @placeholder.html $('option[selected]', @element).html()
      @input.val $('option[selected]', @element).html()

    # See if is <option> based or needs to get some JSON data
    if @options.url?
      @createListFromSource(true)
    unless @options.url?
      if $('optgroup', @element).length > 0
        @createListFromGroupedOptions()
      else
        @createListFromOptions()

    if @options.multiple
      selectedOptions = $('option[selected]', @element)
      @element.html('')

      for option in selectedOptions
        $option = $(option)
        @addMultiSelectItem $option.html(), $option.val()

    # Add placeholder to select if data attribute
    unless @options.multiple
      if @element.attr('placeholder')?
        @element.prop('selectedIndex', -1)
      else
        @setOptionFor $('li:first-child', @list)

    @inputContainer.on 'click', '.plush-placeholder, .plush-caret', (event) =>
      event.preventDefault()
      @show()
    .on 'click', (event) =>
      @show() if @options.multiple
    .on 'click', '.plush-remove', (event) =>
      event.preventDefault()
      optionContainer = $(event.currentTarget).parents('.plush-multi-select-item').first()
      @removeOption optionContainer.data('value')
      optionContainer.remove()

    # User event behaviour
    @container.on 'blur', 'input, a', =>
      setTimeout @bind(@hide), 100

    @input.on 'focus', =>
      @show() unless @inputContainer.hasClass 'opened'
    .on 'keyup', (event) =>
      event.stopPropagation()
      @handleInputKeyPress(event)

    @list.on 'mousedown', 'a', (event) =>
      event.preventDefault()
      event.stopPropagation()
      $item = $(event.currentTarget).parents('li').first()
      if @options.multiple
        @addOptionFor $item
      else
        @setOptionFor $item
        @hide(true)
    .on 'click', 'a', (event) =>
      event.preventDefault()
    .on 'keydown', 'a', (event) =>
      event.preventDefault()
      event.stopPropagation()
    .on 'keyup', 'a', (event) =>
      event.preventDefault()
      event.stopPropagation()
      @handleListKeyPress(event)
    .on 'blur', 'a', (event) ->
      $(this).removeClass 'focused'

    @element.trigger 'initialized'
    return @

  handleInputKeyPress: (event) ->
    if event.which == 38 || event.which == 40
      event.preventDefault()
      @focusAnchor($('li:not(.hidden):last a', @list))  if event.which == 38
      @focusAnchor($('li:not(.hidden):first a', @list)) if event.which == 40
    else
      if @searchWithAjax
        @delayedSearch()
      else
        @search @input.val()

  handleListKeyPress: (event) ->
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
      if @options.multiple? && @options.multiple
        @addOptionFor $item
      else
        @setOptionFor $item
        @blurAnchor($anchor)

  setDefaultOption: (key, value) ->
    unless @options[key]?
      dataAttrName = key.replace /([A-Z])/g, ($1) -> "-" + $1.toLowerCase()
      @options[key] = @element.data(dataAttrName) || value

  setQueryDataOptions: ->
    @queryData = @getQueryDataFromElement(@element.get(0))

  setOptionFor: (listItem) ->
    @placeholder.html listItem.data('label')
    @element.val listItem.data('value')
    @element.trigger 'change'

  addOptionFor: (listItem) ->
    value = listItem.data('value')

    if $("option[value='#{value}']", @element).length == 0
      @addMultiSelectItem listItem.data('label'), value

  addMultiSelectItem: (label, value) ->
    $item = $.handlebar @options.multiSelectTemplate, {label: label, value: value}
    if $('.plush-multi-select-item', @inputContainer).length > 0
        $('.plush-multi-select-item', @inputContainer).last().after $item
      else
        @inputContainer.prepend $item

      @element.append "<option value=#{value} selected>#{label}</option>"
      @element.trigger 'change'

  removeOption: (value) ->
    $("option[value=#{value}]", @element).removeAttr('selected')

    if @options.multiple
      $("option[value=#{value}]", @element).remove()

    @element.trigger 'change'

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


  # --------------------------------------
  # <option> based building
  # --------------------------------------

  createListFromOptions: ->
    $('option', @element).each (index, item) =>
      @list.append @createListItemFromOption(item)

  createListFromGroupedOptions: ->
    $('optgroup', @element).each (index, optGroup) =>
      $optGroup = $(optGroup)
      $group = $.handlebar 'plush_optgroup_item', {label: $optGroup.attr('label')}

      $('option', $optGroup).each (index, item) =>
        $('.plush-optgroup-list', $group).append(@createListItemFromOption(item))

      @list.append $group

  createListItemFromOption: (optionItem) ->
    $option = $(optionItem)
    options = @getDataFromElement(optionItem)
    options.value = $option.val()
    options.label = $option.html()
    $.handlebar(@options.listItemTemplate, options)


  # --------------------------------------
  # JSON based building
  # --------------------------------------

  createListFromSource: (initial = false)->
    @inputContainer.addClass 'loading'

    ajaxOptions =
      url: @options.url
      type: "get"
      dataType: "json"

    dataOptions = $.extend {}, @queryData
    dataOptions[@queryDefault] = @input.val() if @searchWithAjax
    ajaxOptions.data = dataOptions

    $.ajax(ajaxOptions).done (result, status, xhr) =>
      @createListFromJSON(result, initial)

    .always =>
      @inputContainer.removeClass 'loading'
      @checkResults()

  hasFocus: () ->
    $('*:focus', @container).length > 0

  createListFromJSON: (result = [], initial = false) ->
    @list.empty()
    if result? && !$.isEmptyObject(result)
      # Check if result are grouped
      if $.inArray('value', Object.keys(result[0])) >= 0
        for item in result
          @checkItemLabel(item)
          @list.append @createListItemFromJson(item)
          @element.append "<option value=#{item.value}>#{item.label}</option>"
      else
        for groupObject in result
          groupName = Object.keys(groupObject)[0]
          $group = $.handlebar(@options.optgroupTemplate, {label: groupName})

          for item in groupObject[groupName]
            @checkItemLabel(item)
            $('ul', $group).append @createListItemFromJson(item)

          @list.append $group

      @input.focus() unless initial
      @checkResults()

  checkItemLabel: (item) ->
    item['label'] = item[@options.labelMethod] unless item['label']?

  createListItemFromJson: (item) ->
    $.handlebar(@options.listItemTemplate, item)


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
    msg = @options.noResults + @input.val()

    if $('.plush-no-results', @list).length == 0
      @list.append $("<div class='plush-no-results'>#{msg}</div>")
    else
      $('.plush-no-results', @list).html(msg)
      $('.plush-no-results', @list).show()

  hideNoResults: ->
    $('.plush-no-results', @list).hide()

  # Dynamic dimensions
  resizeInput: ->

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
      unless @options.multiple
        @placeholder.show()
        @input.hide()

      @inputContainer.removeClass 'opened'
      @list.hide()

  # Utilities
  getAttributesFromElement: (element, attr_regexp) ->
    options = {}
    for attr in element.attributes
      options[attr.nodeName.replace(attr_regexp, '')]= attr.nodeValue if attr.nodeName.match(attr_regexp)
    options

  getDataFromElement: (element) ->
    @getAttributesFromElement element, /^data-/

  getQueryDataFromElement: (element) ->
    @getAttributesFromElement element, /^data-query-/

  bind: ( Method ) ->
    () =>
      Method.apply( @, arguments )

$ ->
  $("[data-toggle='plush']").plush()


