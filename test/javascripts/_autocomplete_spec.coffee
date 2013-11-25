#= require spec_helper

describe 'Autocomplete', ->

  before ->
    @xhr = sinon.useFakeXMLHttpRequest()
    @requests = []
    @xhr.onCreate = (req) => 
      @requests.push(req)

  after ->
    @xhr.restore()

  it 'should add select tag', ->
    $select = $.renderTemplate 'select_tag'
    $select.plushAutocomplete()
    $('.plush-container').length.should.equal 1
    $('.plush-list-item', $select.container).length.should.equal 10
    
  it 'should set correct value', ->
    $select = $.renderTemplate 'select_tag'
    $select.plushAutocomplete()

    $('.plush-option-list li[data-value="4"] a',  $select.container).click()
    $select.val().should.equal '4'
    $select.serialize().should.equal 'test_model=4'

  it 'should create list from json object', ->
    $select = $.renderTemplate 'select_tag'
    autocomplete = new PlushAutocomplete($select)
    autocomplete.createList window.testItems.toJSON()

    $('.plush-list-item',  $select.container).length.should.equal 10

  it 'should make a correct ajax request', ->
    $select = $.renderTemplate 'select_tag'
    $select.data 'source', 'http://localhost:3000/tags'
    $select.plushAutocomplete()

    @requests.length.should.equal 1
    @requests[0].url.should.match /tags/
    @requests[0].requestHeaders.Accept.should.match /json/
    @requests[0].method.should.equal 'GET'
    @requests = []
