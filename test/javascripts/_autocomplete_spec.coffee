#= require spec_helper

describe "Autocomplete", ->
  it "should add select tag", ->

    $.renderTemplate 'select_tag'

    $('body select').plushAutocomplete()
    