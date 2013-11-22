class @PlushAutocomplete
  constructor: (@element, @options={}) ->
    @element.hide()
    @searchWithAjax = @element.data('query')?
    @listTemplate = if @element.data('template')? then @element.data('template') else 'autocomplete_list_item'
    @labelMethod = if @element.data('label')? then @element.data('label') else 'label'

    @container = $.handlebar('autocomplete_container', {placeholder: @element.attr('placeholder')})
    @list = $('.plush-option-list', @container)
    @list.addClass @listTemplate.replace(/\_/g, '-')
    @inputContainer = $('.plush-input', @container)
    @placeholder = $('.plush-placeholder', @inputContainer)
    @input = $('input', @inputContainer)

    if @element.data('source')?
      @createListFromSource()
    else
      @createListFromOptions()

    @inputContainer.on 'click', '.plush-placeholder', (event) =>
      event.preventDefault()
      @showInput()

    @input.on 'focus', =>
      @showList()
    .on 'blur', =>
      setTimeout @bind(@hideList), 50
      @hideInput()
    .on 'keyup', =>
      if @searchWithAjax
        @delayedSearch()
      else
        matcher = new RegExp(@input.val(), 'i')
        $('.plush-list-item a', @container).each ->
          $element = $(this)
          if matcher.test($element.html())
            $element.parents('.plush-list-item').first().show()
          else
            $element.parents('.plush-list-item').first().hide()

    @list.on 'click', 'a', (event) =>
      event.preventDefault()
      $anchor = $(event.currentTarget)
      $listItem = $anchor.parents('li').last()
      @placeholder.html $listItem.data('label')
      @element.val $listItem.data('id')

    @element.after @container

  createListFromOptions: ->
    $('option', @element).each (index, item) =>
      $option = $(item)
      @list.append $.handlebar(@listTemplate, {id: $option.val(), name: $option.html(), label: $option.html()})

  createListFromSource: ->
    @inputContainer.addClass 'loading'
    
    ajaxOptions = 
      url: @element.data('source')
      type: "get"
      dataType: "json"
    ajaxOptions.data = {query: @input.val()} if @searchWithAjax

    $.ajax(ajaxOptions).done (result, status, xhr) =>
      @list.empty()
      if result?
        $.each result, (index, item) =>
          item['label'] = item[@labelMethod] unless item['label']?
          @list.append $.handlebar(@listTemplate, item)

    .always =>
      @inputContainer.removeClass 'loading'

  delayedSearch: ->
    clearTimeout(@timer) if @timer?
    @timer = setTimeout @bind(@createListFromSource), 500

  showInput: ->
    @placeholder.hide()
    @input.css('display', 'block')
    @input.focus()

  hideInput: ->
    @placeholder.show()
    @input.hide()
    # @input.blur()

  showList: ->
    @list.show()
    @inputContainer.addClass('opened')

  hideList: ->
    @list.hide()
    @inputContainer.removeClass('opened')

  bind: ( Method ) ->
    () =>
      Method.apply( @, arguments )

$ ->
  $("[data-toggle='plush-autocomplete']").plushAutocomplete()
    
