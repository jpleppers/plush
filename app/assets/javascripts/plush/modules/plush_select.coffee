class @Plush
  constructor: (@element, @options={}) ->
    # Hide original and wrap with container
    @element.hide()
    @element.wrap('<div class="plush-container"></div>')
    @container = @element.parent()

    # Option setting
    @searchWithAjax = @options.query? || @element.data('query')?
    @customTemplate = @options.template? || @element.data('template')?
    @customGroupTemplate = @options.groupTemplate? || @element.data('group-template')?
    @noResults = @options.no_results || @element.data('no-results') || 'No results found for: '

    @labelMethod = if (@options.label? || @element.data('label')?) then ( @options.label || @element.data('label')) else 'label'
    @listTemplate = if @customTemplate then (@options.template || @element.data('template')) else 'plush_list_item'
    @groupTemplate = if @customGroupTemplate then (@options.groupTemplate || @element.data('group-template')) else 'plush_optgroup_item'

    @container.append $.handlebar('plush_input', {placeholder: @element.attr('placeholder')})

    @list = $('.plush-option-list', @container)
    @list.addClass @listTemplate.replace(/\_/g, '-')
    position = @element.data('position')
    @container.addClass("position-#{position}") if position == 'top' || position == 'bottom'

    @inputContainer = $('.plush-input', @container)
    @placeholder = $('.plush-placeholder', @inputContainer)
    @input = $('input', @inputContainer)

    @element.attr('tabindex', -1)

    # See if is <option> based or needs to get some JSON data
    if @element.data('source')?
      @createListFromSource()
    else
      if $('optgroup', @element).length > 0 
        @createListFromGroupedOptions()
      else
        @createListFromOptions()

    # Add placeholder to select if data attrbute
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
      @hideInput()
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

    @list.on 'click', 'a', (event) =>
      event.preventDefault()
      console.log event.currentTarget
      @setOptionFor $(event.currentTarget).parents('.plush-list-item').first()
      @hideList()
      @hideInput()

    return @

  setOptionFor: (listItem) ->
    @placeholder.html listItem.data('label')
    @element.val listItem.data('value')
    @element.trigger 'change'

  # <option> based building
  createListFromOptions: ->
    $('option', @element).each (index, item) =>
      @list.append @createListItemFromOption(item)

  createListFromGroupedOptions: ->
    $('optgroup', @element).each (index, optGroup) =>
      $optGroup = $(optGroup)
      $group = $.handlebar('plush_optgroup_item', {label: $optGroup.attr('label')})
      
      $('option', $optGroup).each (index, item) =>
        $('.plush-optgroup-list', $group).append(@createListItemFromOption(item))
      
      @list.append $group

  createListItemFromOption: (optionItem) ->
    $option = $(optionItem)
    options = if @customTemplate then @getAttributesFromElement(optionItem) else {}
    options.value = $option.val()
    options.label = $option.html()
    $.handlebar(@listTemplate, options)

  # JSON based building
  createListFromSource: ->
    @inputContainer.addClass 'loading'
    
    ajaxOptions = 
      url: @element.data('source')
      type: "get"
      dataType: "json"
    ajaxOptions.data = {query: @input.val()} if @searchWithAjax

    $.ajax(ajaxOptions).done (result, status, xhr) =>
      @createListFromJSON(result)

    .always =>
      @inputContainer.removeClass 'loading'

  createListFromJSON: (result = []) ->
    @list.empty()
    if result? && !$.isEmptyObject(result)
      if $.inArray('value', Object.keys(result[0])) >= 0
        for item in result
          item['label'] = item[@labelMethod] unless item['label']?
          @list.append $.handlebar(@listTemplate, item)
          @element.append "<option value=#{item.value}>#{item.label}</option>"
      else
        for groupObject in result
          groupName = Object.keys(groupObject)[0]
          $group = $.handlebar('plush_optgroup_item', {label: groupName})

          for item in groupObject[groupName]
            item['label'] = item[@labelMethod] unless item['label']?
            $('.plush-optgroup-list', $group).append $.handlebar(@listTemplate, item)

          @list.append $group



  delayedSearch: ->
    clearTimeout(@timer) if @timer?
    @timer = setTimeout @bind(@createListFromSource), 500

  # No results message 
  showNoResults: ->
    msg = @noResults + @input.val()

    if $('.plush-no-results', @list).length == 0
      msgElement = $("<div class='plush-no-results'>#{@noResults}</div>")
      @list.append msgElement
    else
      $('.plush-no-results', @list).html(msg)
      $('.plush-no-results', @list).show()

  # Input togglers for autocompletion behaviour
  showInput: ->
    @placeholder.hide()
    @input.css('display', 'block')
    @input.focus()

  hideInput: ->
    @placeholder.show()
    @input.hide()

  # List togglers 
  showList: ->
    @list.show()
    @inputContainer.addClass('opened')

  hideList: ->
    @list.hide()
    @inputContainer.removeClass('opened')

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
    
