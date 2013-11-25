#= require spec_helper

describe "List item template", ->
  before ->
    @item = window.testItems.randomItem()
    @listItem = $.handlebar('autocomplete_list_item', {value: @item.value(), label: @item.label})

  it "should set correct options", ->
    @listItem.data('value').should.equal @item.value()
    @listItem.data('label').should.equal @item.label
    $('a', @listItem).html().should.equal @item.label


describe "Image list item template", ->
  before ->
    @item = window.testItems.randomItem()
    @listItem = $.handlebar('autocomplete_image_list_item', {value: @item.value(), label: @item.label, image: @item.image(), description: @item.description()})

  it "should set correct options", ->
    @listItem.data('value').should.equal @item.value()
    @listItem.data('label').should.equal @item.label
    $('.title', @listItem).html().should.equal @item.label
    $('.description', @listItem).html().should.equal @item.description()
    $('img', @listItem).attr('src').should.equal @item.image()
