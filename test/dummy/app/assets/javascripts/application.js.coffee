#= require jquery
#= require jquery-ui-1.10.4.custom
#= require handlebars-v1.1.2
#= require plush

$.showValues = ->
  $('body select').each ->
    $this = $(this)
    $('pre', $this.parents('.columns')).html $this.serialize()

$ ->
  $.showValues()

  selectCounter = 1
  $('body select').each ->
    $this = $(this)
    $this.attr 'id', "select-#{selectCounter}"
    selectCounter += 1

    $this.on 'change', (event) ->
      $('pre', $this.parents('.columns')).html $this.serialize()