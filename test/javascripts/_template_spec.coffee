#= require spec_helper

describe "List item template", ->
  before ->
    @listItem = $.handlebar('autocomplete_list_item', {id: 1, label: 'DarkBlue', name: 'DarkBlue'})

  it "should set correct options", ->
    @listItem.data('id').should.equal 1
    @listItem.data('label').should.equal 'DarkBlue'
    $('a', @listItem).html().should.equal 'DarkBlue'
