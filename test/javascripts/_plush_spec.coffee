#= require spec_helper

describe 'Plush', ->
  describe '#setDefaultOption', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag'
      @plush = new Plush @select

    it 'should set default option', ->
      @plush.setDefaultOption 'foo', 'bar'
      @plush.options.foo.should.equal 'bar'

    it 'should set default option for passed options', ->
      @plush =  new Plush @select, { foo: 'baz'}
      @plush.setDefaultOption 'foo', 'bar'
      @plush.options.foo.should.equal 'baz'

    it 'should set default option for data attribute', ->
      @select.data 'foo', 'baz'
      @plush.setDefaultOption 'foo', 'bar'
      @plush.options.foo.should.equal 'baz'

    it 'should set default data attributes for ajax call', ->
      Object.keys(@plush.queryData).should.have.length(2)
      @plush.queryData.should.have.property('foo')
      @plush.queryData.should.have.property('baz')
      @plush.queryData.foo.should.equal('bar')
      @plush.queryData.baz.should.equal('qux')


  context 'with default options', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag'
      @plush = new Plush @select

    describe '#createListFromOptions', ->
      it 'should add select tag', ->
        $('.plush-container').length.should.equal 1
        $('li.plush-list-item', @select.container).length.should.equal 10

    describe '#createListFromJSON', ->
      before ->
        @xhr = sinon.useFakeXMLHttpRequest()
        @requests = []
        @xhr.onCreate = (req) =>
          @requests.push(req)

      after -> @xhr.restore()

      it 'should create list from json object', ->
        @plush.createListFromJSON window.testItems.toJSON()
        $('li.plush-list-item',  @select.container).length.should.equal 10
        $('li[data-value=4] a',  @select.container).first().html().should.equal 'Aquamarine'

      it 'should make a correct ajax request', ->
        @select = $.renderTemplate 'select_tag'
        @select.data 'url', 'http://localhost:3000/tags'
        @select.plush()

        @requests.length.should.equal 1
        @requests[0].url.should.match /tags/
        @requests[0].url.should.match /foo=bar&baz=qux/
        @requests[0].requestHeaders.Accept.should.match /json/
        @requests[0].method.should.equal 'GET'
        @requests = []

      it 'should set initial value if present', ->
        @select = $.renderTemplate 'select_tag_with_single_value'
        @select.data 'url', 'http://localhost:3000/tags'
        @select.plush()
        @select.val().should.equal '9'

    describe '#search', ->
      it 'should match items based on a query', ->
        @plush.search 'bl'
        $('li:not(.hidden)', @plush.list).length.should.equal 4
        @plush.search 'black'
        $('li:not(.hidden)', @plush.list).length.should.equal 1

    describe '#setOptionFor', ->
      it 'should set correct value', ->
        @plush.setOptionFor $('li[data-value="6"]', @plush.list)
        @select.serialize().should.equal 'test_model=6'

      it 'should set correct value on click', ->
        $('.plush-option-list li[data-value="4"] a',  @plush.container).trigger 'mousedown'
        @select.val().should.equal '4'
        @select.serialize().should.equal 'test_model=4'

      it 'should set correct value on enter', ->
        $('.plush-option-list li[data-value="4"] a',  @plush.container).trigger window.testEvents.keyEnter
        @select.val().should.equal '4'
        @select.serialize().should.equal 'test_model=4'

    describe '#nextAnchor', ->
      it 'should select next anchor', ->
        anchor = $('li:first-child a', @plush.list)
        @plush.nextAnchor(anchor).html().should.equal 'AntiqueWhite'

      it 'should select next anchor whith filtered results', ->
        @plush.search 'bl'
        anchor = $('li:first-child:not(.hidden) a', @plush.list)
        @plush.nextAnchor(anchor).html().should.equal 'Black'

      it 'should return null when no suitable next anchor is present', ->
        @plush.search 'azure'
        anchor = $('li:first-child a', @plush.list)
        @plush.prevAnchor(anchor).length.should.equal 0

      it 'should select next anchor on down arrow button press', ->
        anchor = $('li:first-child a', @plush.list)
        anchor.trigger window.testEvents.keyArrowDown
        $('a.focused', @plush.list).html().should.equal 'AntiqueWhite'

      it 'should select correct next or previous anchor', ->
        anchor = $('li:first-child a', @plush.list)
        @plush.nextOrPreviousAnchor(anchor).html().should.equal 'AntiqueWhite'

        anchor = $($('li a', @plush.list)[1])
        @plush.nextOrPreviousAnchor(anchor).html().should.equal 'Aqua'

        anchor = $('li:last-child a', @plush.list)
        @plush.nextOrPreviousAnchor(anchor).html().should.equal 'BlanchedAlmond'


    describe '#prevAnchor', ->
      it 'should select previous anchor', ->
        anchor = $('li:last-child a', @plush.list)
        @plush.prevAnchor(anchor).html().should.equal 'BlanchedAlmond'

      it 'should select next anchor whith filtered results', ->
        @plush.search 'bl'
        anchor = $('li[data-value="8"] a', @plush.list)
        @plush.prevAnchor(anchor).html().should.equal 'AliceBlue'

      it 'should return null when no suitable previous anchor is present', ->
        @plush.search 'azure'
        anchor = $('li:first-child a', @plush.list)
        @plush.prevAnchor(anchor).length.should.equal 0

      it 'should select previous anchor on up arrow button press', ->
        anchor = $('li:last-child a', @plush.list)
        anchor.trigger window.testEvents.keyArrowUp
        $('a.focused', @plush.list).html().should.equal 'BlanchedAlmond'


    describe '#checkResults', ->
      it 'should show no results message', ->
        @plush.show()
        @plush.search 'xyz'
        $('.plush-no-results:visible', @plush.list).length.should.equal 1

      it 'should hide no results message', ->
        @plush.show()
        @plush.search 'blue'
        $('.plush-no-results:visible', @plush.list).length.should.equal 0

        @plush.search ''
        $('.plush-no-results:visible', @plush.list).length.should.equal 0

  context 'with custom list item template', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag', ''
      @plush = new Plush @select, {listItemTemplate: 'plush_image_list_item'}

    it 'should have correct list item template option', ->
      @plush.options.listItemTemplate = 'plush_image_list_item'

    it 'should use custom template for list rendering', ->
      $('li', @plush.list).filter('.plush-imagebox').length.should.equal 10

    describe '#setOptionFor', ->
      it 'should set correct value', ->
        @plush.setOptionFor $('li[data-value="6"]', @plush.list)
        @select.serialize().should.equal 'test_model=6'

      it 'should set correct value on click', ->
        $('.plush-option-list li[data-value="4"] a',  @plush.container).trigger 'mousedown'
        @select.val().should.equal '4'

  context 'with optgroups', ->
    beforeEach ->
      @select = $.renderTemplate 'select_with_optgroups', ''
      @plush = new Plush @select

    it 'should render group listings', ->
      $('.plush-optgroup', @plush.list).length.should.equal 3
      $('.plush-optgroup:first-child .plush-list-item', @plush.list).length.should.equal 14

    describe '#setOptionFor', ->
      it 'should set correct value', ->
        @plush.setOptionFor $('li[data-value="137"]', @plush.list)
        @select.serialize().should.equal 'color=137'

      it 'should set correct value on click', ->
        $('.plush-option-list li[data-value="137"] a',  @plush.container).trigger 'mousedown'
        @select.val().should.equal '137'

