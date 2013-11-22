#= require jquery
#= require jquery_ujs
#= require jquery.ui.droppable
#= require handlebars-v1.1.2
#= require plush

#= require_tree ./templates

$.extend
  renderTemplate: (name) ->
    $('body').html JST["templates/#{name}"]()