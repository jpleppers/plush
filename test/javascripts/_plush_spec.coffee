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
        @requests[0].requestHeaders.Accept.should.match /json/
        @requests[0].method.should.equal 'GET'
        @requests = []

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
        $('.plush-option-list li[data-value="4"] a',  @plush.container).click()
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
        $('.plush-option-list li[data-value="4"] a',  @plush.container).click()
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
        $('.plush-option-list li[data-value="137"] a',  @plush.container).click()
        @select.val().should.equal '137'

  context 'with multiple select', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag', ''
      @select.attr 'multiple', 'multiple'
      @plush = new Plush @select

      @values = []
      @values.push("test_model=#{i}") for i in [1,2,3]

    describe '#addOptionFor', ->
      beforeEach ->
        @plush.addOptionFor( $("li[data-value='#{i}']", @plush.list) ) for i in [1,2,3]

      it 'should set correct values', ->        
        @select.serialize().should.equal @values.join('&')

      it 'should set placeholder values and in correct order', ->
        placeholders = []
        $('.plush-multi-select-item span', @plush.inputContainer).each -> 
          placeholders.push $(this).html().replace /(\r\n|\n|\r| )/gm, ''

        placeholderValues = ['AliceBlue', 'AntiqueWhite', 'Aqua']
        placeholders[i].should.equal(placeholderValues[i]) for i in [0,1,2]

    describe 'click on list items', ->
      it 'should set correct values on click', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).click() for i in [1,2,3]
        @select.serialize().should.equal @values.join('&')

    describe 'click on list items', ->
      it 'should remove option on click on .plush-remove', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).click() for i in [1,2,3]
        @select.serialize().should.equal @values.join('&')

        $(".plush-multi-select-item[data-value='2'] .plush-remove",  @plush.inputContainer).click()
        @select.serialize().should.equal "test_model=1&test_model=3"









