# --------------------------------------
# <option> based building
# --------------------------------------


Plush::createListFromOptions = ->
  $('option', @element).each (index, item) =>
    @list.append @createListItemFromOption(item)

Plush::createListFromGroupedOptions = ->
  $('optgroup', @element).each (index, optGroup) =>
    $optGroup = $(optGroup)
    $group = $.handlebar 'plush_optgroup_item', {label: $optGroup.attr('label')}

    $('option', $optGroup).each (index, item) =>
      $('.plush-optgroup-list', $group).append(@createListItemFromOption(item))

    @list.append $group

Plush::createListItemFromOption = (optionItem) ->
  $option = $(optionItem)
  options = @getDataFromElement(optionItem)
  options.value = $option.val()
  options.label = $option.html()
  $.handlebar(@options.listItemTemplate, options)


# --------------------------------------
# JSON based building
# --------------------------------------

Plush::createListFromSource = (initial = false) ->
  @inputContainer.addClass 'loading'

  ajaxOptions =
    url: @options.url
    type: "get"
    dataType: "json"

  dataOptions = $.extend {}, @queryData
  dataOptions[@options.queryDefault] = @input.val() if @searchWithAjax
  ajaxOptions.data = dataOptions

  $.ajax(ajaxOptions).done (result, status, xhr) =>
    @createListFromJSON(result, initial)
  .always =>
    @inputContainer.removeClass 'loading'
    @checkResults()

Plush::createListFromJSON = (result = [], initial = false) ->
  @list.empty()
  if result? && !$.isEmptyObject(result)
    # Check if result are grouped
    if $.inArray('value', Object.keys(result[0])) >= 0
      for item in result
        @checkItemLabel(item)
        @list.append @createListItemFromJson(item)
        # @element.append "<option value=#{item.value}>#{item.label}</option>"
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
