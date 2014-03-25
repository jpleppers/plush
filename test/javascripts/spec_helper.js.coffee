#= require jquery
#= require jquery_ujs
#= require jquery.ui.droppable
#= require handlebars-v1.1.2
#= require sinon-1.7.3
#= require plush

#= require_tree ./templates

$.extend
  renderTemplate: (name) ->
    $template = $(JST["templates/#{name}"]())
    $('body').html $template
    $template

class @Item
  constructor: (@id, @label, @color) ->
    @

  value: -> @id
  description: -> "Hex color: @color"
  image: -> "test#{@id}.png"


class @Items
  constructor: (@items) ->
    @

  randomItem: ->
    @items[Math.floor((Math.random()*@items.length))]


  toJSON: ->
    @items.map (item) ->
      {value: item.value(), label: item.label, description: item.description(), color: item.color }

window.testItems = new Items([
  new Item(1,  'AliceBlue',      '#F0F8FF'),
  new Item(2,  'AntiqueWhite',   '#FAEBD7'),
  new Item(3,  'Aqua',           '#00FFFF'),
  new Item(4,  'Aquamarine',     '#7FFFD4'),
  new Item(5,  'Azure',          '#F0FFFF'),
  new Item(6,  'Beige',          '#F5F5DC'),
  new Item(7,  'Bisque',         '#FFE4C4'),
  new Item(8,  'Black',          '#000000'),
  new Item(9,  'BlanchedAlmond', '#FFEBCD'),
  new Item(10, 'Blue',           '#0000FF')
])

window.testEvents =
  keyArrowUp:   $.Event( "keyup", { which: 38 } )
  keyArrowDown: $.Event( "keyup", { which: 40 } )
  keyEscape:    $.Event( "keyup", { which: 27 } )
  keyEnter:     $.Event( "keyup", { which: 13 } )
