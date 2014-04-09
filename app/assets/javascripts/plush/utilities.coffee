$.extend
  handlebar: (templateName, options={}) ->
    unless Handlebars.templates[templateName]?
      template = $("script##{templateName}")
      if template.length > 0
        Handlebars.templates[templateName] = Handlebars.compile template.html()

    $(Handlebars.templates[templateName](options))

  plush: (element) ->
    $element = $(element)
    $element.data 'plush', (if $element.attr('multiple')? then new PlushMulti($element) else new Plush($element))

$.fn.extend
  plush: ->
    this.each ->
      $.plush this
