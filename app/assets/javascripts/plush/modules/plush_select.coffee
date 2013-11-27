class @Plush
  constructor: (@element, @options={}) ->
    # Hide original and wrap with container
    @element.hide()
    @element.wrap('<div class="plush-container"></div>')
    @container = @element.parent()
    @container.append $.handlebar('plush_input', {placeholder: @element.attr('placeholder')})  

    @list = $('.plush-option-list', @container)
    @inputContainer = $('.plush-input', @container)
    @placeholder = $('.plush-placeholder', @inputContainer)
    @input = $('input', @inputContainer)
    @options.multiple = @options.multiple? || @element.attr('multiple')?

    # Option setting
    @dataDefaults = {}
    @queryDefault = 'q'

    defaults =
      noResults:           'No results found for: '
      labelMethod:         'label'
      listItemTemplate:    'plush_list_item'
      optgroupTemplate:    'plush_optgroup_item'
      multiSelectTemplate: 'plush_multi_select_item'
      position:            'bottom'

    for key, value of defaults
      @setDefaultOption key, value
      
    @list.addClass @options.listItemTemplate.replace(/\_/g, '-')
    @container.addClass "position-#{@options.position}"
    @element.attr 'tabindex', -1

    # See if is <option> based or needs to get some JSON data
    if @element.data('url')?
      @createListFromSource()
    else
      if $('optgroup', @element).length > 0 
        @createListFromGroupedOptions()
      else
        @createListFromOptions()

    # Add placeholder to select if data attribute
    if @element.attr('placeholder')?
      @element.prop('selectedIndex', -1)
    else
      @setOptionFor $('li:first-child', @list)

    @inputContainer.on 'click', '.plush-placeholder', (event) =>
      event.preventDefault()
      @showInput()

    # User event behaviour
    @input.on 'focus', =>
      @showList()
    .on 'blur', =>
      setTimeout @bind(@hideList), 200
      @hideInput() unless @options.multiple
    .on 'keyup', =>
      if @searchWithAjax
        @delayedSearch()
      else
        matcher = new RegExp(@input.val(), 'i')
        $('.plush-list-item a', @container).each ->
          $element = $(this)
          if matcher.test($element.html())
            $element.parents('.plush-list-item').first().removeClass('hidden')
          else
            $element.parents('.plush-list-item').first().addClass('hidden')

        $('.plush-optgroup', @container).each ->
          $element = $(this)
          if $('.plush-list-item:not(.hidden)', $element).length == 0
            $element.hide()
          else 
            $element.show()

        if $('li:visible', @list).length == 0
          @showNoResults()
        else
          @hideNoResults()

    @list.on 'click', 'a', (event) =>
      event.preventDefault()
      if @options.multiple
        @addOptionFor $(event.currentTarget).parents('li').first()
      else
        @setOptionFor $(event.currentTarget).parents('li').first()
        @hideList()
        @hideInput() unless @options.multiple

    return @

  setDefaultOption: (key, value) ->
    unless @options[key]?
      dataAttrName = key.replace /([A-Z])/g, ($1) -> "-" + $1.toLowerCase()
      @options[key] = @element.data(dataAttrName) || value

  setOptionFor: (listItem) ->
    @placeholder.html listItem.data('label')
    @element.val listItem.data('value')
    @element.trigger 'change'

  addOptionFor: (listItem) ->
    $item = $.handlebar 'plush_multi_select_item', {label: listItem.data('label'), value: listItem.data('value')}
    @inputContainer.prepend $item
    @element.trigger 'change'

  # <option> based building
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
    options = @getAttributesFromElement(optionItem)
    options.value = $option.val()
    options.label = $option.html()
    $.handlebar(@options.listItemTemplate, options)

  # JSON based building
  createListFromSource: ->
    @inputContainer.addClass 'loading'
    
    ajaxOptions = 
      url: @element.data('url')
      type: "get"
      dataType: "json"

    dataOptions = @dataDefaults
    dataOptions[@queryDefault] = @input.val() if @searchWithAjax
    ajaxOptions.data = dataOptions

    $.ajax(ajaxOptions).done (result, status, xhr) =>
      @createListFromJSON(result)

    .always =>
      @inputContainer.removeClass 'loading'
      @checkResults()

  createListFromJSON: (result = []) ->
    @list.empty()
    if result? && !$.isEmptyObject(result)
      if $.inArray('value', Object.keys(result[0])) >= 0
        for item in result
          item['label'] = item[@options.labelMethod] unless item['label']?
          @list.append $.handlebar(@options.listItemTemplate, item)
          @element.append "<option value=#{item.value}>#{item.label}</option>"
      else
        for groupObject in result
          groupName = Object.keys(groupObject)[0]
          $group = $.handlebar(@options.optgroupTemplate, {label: groupName})

          for item in groupObject[groupName]
            item['label'] = item[@options.labelMethod] unless item['label']?
            $('ul', $group).append $.handlebar(@options.listItemTemplate, item)

          @list.append $group
      @checkResults()

  delayedSearch: ->
    clearTimeout(@timer) if @timer?
    @timer = setTimeout @bind(@createListFromSource), 500

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

  # Input togglers for autocompletion behaviour
  showInput: ->
    @placeholder.hide()
    @input.css 'display', 'block'
    @input.focus()

  hideInput: ->
    @placeholder.show()
    @input.hide()

  # List togglers 
  showList: ->
    @list.show()
    @inputContainer.addClass 'opened'

  hideList: ->
    @list.hide()
    @inputContainer.removeClass 'opened'

  # Utilities
  getAttributesFromElement: (element) ->
    options = {}
    for attr in element.attributes
      options[attr.nodeName.replace(/^data-/, '')]= attr.nodeValue if attr.nodeName.match(/^data-/)
    options

  bind: ( Method ) ->
    () =>
      Method.apply( @, arguments )

$ ->
  $("[data-toggle='plush']").plush()
    
