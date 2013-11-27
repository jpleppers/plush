#= require spec_helper

describe 'Plush', ->

  before ->
    @xhr = sinon.useFakeXMLHttpRequest()
    @requests = []
    @xhr.onCreate = (req) => 
      @requests.push(req)

  after ->
    @xhr.restore()

  it 'should add select tag', ->
    $select = $.renderTemplate 'select_tag'
    $select.plush()
    $('.plush-container').length.should.equal 1
    $('li.plush-list-item', $select.container).length.should.equal 10
    
  it 'should set correct value', ->
    $select = $.renderTemplate 'select_tag'
    $select.plush()

    $('.plush-option-list li[data-value="4"] a',  $select.container).click()
    $select.val().should.equal '4'
    $select.serialize().should.equal 'test_model=4'

  it 'should create list from json object', ->
    $select = $.renderTemplate 'select_tag'
    plush = new Plush($select)
    plush.createListFromJSON window.testItems.toJSON()

    $('li.plush-list-item',  $select.container).length.should.equal 10

  it 'should make a correct ajax request', ->
    $select = $.renderTemplate 'select_tag'
    $select.data 'url', 'http://localhost:3000/tags'
    $select.plush()

    @requests.length.should.equal 1
    @requests[0].url.should.match /tags/
    @requests[0].requestHeaders.Accept.should.match /json/
    @requests[0].method.should.equal 'GET'
    @requests = []
