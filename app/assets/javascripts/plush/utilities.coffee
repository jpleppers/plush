$.extend
  handlebar: (templateName, options={}) ->
    unless Handlebars.templates[templateName]?  
      template = $("script##{templateName}")
      if template.length > 0
        Handlebars.templates[templateName] = Handlebars.compile template.html()
    
    $(Handlebars.templates[templateName](options))

  plushAutocomplete: (element) ->
    $element = $(element)
    $element.data('plush', new PlushAutocomplete($element))

$.fn.extend

  plushAutocomplete: ->
    this.each ->
      $.plushAutocomplete this
