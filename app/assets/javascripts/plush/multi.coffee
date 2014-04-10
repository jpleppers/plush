class @PlushMulti extends Plush
  constructor: (@element, @options={}) ->
    @defaults.dragDrop = false
    super @element, @options={}

  addClassnames: ->
    @container.addClass "plush-multiple"
    @container.addClass "plush-drag-drop" if @options.dragDrop
    super()

  setPlaceholders: ->
    null

  setup: ->
    selectedOptions = $('option[selected]', @element)
    @element.html('')

    for option in selectedOptions
      $option = $(option)
      @addMultiSelectItem $option.html(), $option.val()

    # Drag drop functionality
    if @options.dragDrop
      @inputContainer.sortable
        items: '> .plush-multi-select-item'
        placeholder: 'plush-drag-placeholder'
        forcePlaceholderSize: true
        stop: (event, ui) =>
          @moveMultiSelectItem(ui.item)

  showPlaceholder: () ->
    if $('.plush-multi-select-item', @inputContainer).length > 0
      @placeholder.hide()
    else
      @placeholder.show()

  setOptionFor: (listItem) ->
    value = listItem.data('value')
    unless @getOption(value).length > 0
      @addMultiSelectItem listItem.data('label'), value
    else
      @getOption(value).attr('selected', 'selected')

    listItem.addClass 'hidden'


  addMultiSelectItem: (label, value) ->
    $item = $.handlebar @options.multiSelectTemplate, {label: label, value: value}
    if $('.plush-multi-select-item', @inputContainer).length > 0
      $('.plush-multi-select-item', @inputContainer).last().after $item
    else
      @inputContainer.prepend $item

    @createOption label, value
    @element.trigger 'change'

  checkResults: () ->
    for listItem in $('li', @list)
      $listItem = $(listItem)
      $listItem.addClass('hidden') if @getOption($listItem.data('value'), true).length > 0
    super()

  # Move item based on previous item, which is altered by jquery sortable
  moveMultiSelectItem: (item) ->
    $option = @getOption item.data('value')

    if item.prev().length > 0
      $prevItem = item.prev()
      $prevOption = $("[value=#{$prevItem.data('value')}]", @element)
      $($prevOption, @element).after($option)
    else
      @element.prepend($option)
    @element.trigger 'change'

  setEventHandlers: () ->
    @inputContainer.on 'click', '.plush-remove', (event) =>
      event.preventDefault()
      optionContainer = $(event.currentTarget).parents('.plush-multi-select-item').first()
      @removeOption optionContainer.data('value')
      optionContainer.remove()
      @showPlaceholder()
    .on 'click', (event) =>
      @show() if $(event.target).hasClass 'plush-input-wrapper'

    super()
