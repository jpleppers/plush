#= require jquery
#= require jquery-ui-1.10.4.custom
#= require handlebars-v1.1.2
#= require plush

$ ->
  $('body select').each ->
    $this = $(this)
    $('pre', $this.parents('.columns')).html $this.serialize()

    $this.on 'change', (event) ->
      $('pre', $this.parents('.columns')).html $this.serialize()