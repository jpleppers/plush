class @PlushAutocomplete
  constructor: (@element, @options={}) ->
    @element.hide()
    @searchWithAjax = @options.query? || @element.data('query')?
    @customTemplate = @options.template? || @element.data('template')?
    @noResults = @options.no_results || @element.data('no-results') || 'No results found for: '

    @labelMethod = if (@options.label? || @element.data('label')?) then ( @options.label || @element.data('label')) else 'label'
    @listTemplate = if @customTemplate then (@options.template || @element.data('template')) else 'autocomplete_list_item'

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

    if @element.attr('placeholder')?
      @element.prop('selectedIndex', -1)
    else
      @setOptionFor $('li:first-child', @list)

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
        if $('li:visible', @list).length == 0
          @showNoResults()

    @list.on 'click', 'a', (event) =>
      event.preventDefault()
      @setOptionFor $(event.currentTarget).parents('li').last()
      
    @element.after @container

  createListFromOptions: ->
    $('option', @element).each (index, item) =>
      $option = $(item)
      options = if @customTemplate then @getAttributesFromOption(item) else {}
      options.id = $option.val()
      options.label = $option.html()
      @list.append $.handlebar(@listTemplate, options)

  getAttributesFromOption: (option) ->
    options = {}
    for attrOption in option.attributes    
      options[attrOption.nodeName.replace(/^data-/, '')]= attrOption.nodeValue if attrOption.nodeName.match(/^data-/)
    options

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
          @element.append "<option value=#{item.id}>#{item.label}</option>"

    .always =>
      @inputContainer.removeClass 'loading'

  setOptionFor: (listItem) ->
    @placeholder.html listItem.data('label')
    @element.val listItem.data('id')
    @element.trigger 'change'

  delayedSearch: ->
    clearTimeout(@timer) if @timer?
    @timer = setTimeout @bind(@createListFromSource), 500

  showNoResults: ->
    msg = @noResults + @input.val()

    if $('.plush-no-results', @list).length == 0
      msgElement = $("<div class='plush-no-results'>#{@noResults}</div>")
      @list.append msgElement
    else
      $('.plush-no-results', @list).html(msg)
      $('.plush-no-results', @list).show()


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
    
