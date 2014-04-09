#= require spec_helper

describe 'PlushMulti', ->
  context 'with multiple select', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag', ''
      @select.attr 'multiple', 'multiple'
      @plush = new PlushMulti @select

      @values = [1,2,3]
      @valueIds = []
      @valueIds.push("test_model=#{i}") for i in @values

    describe '#setOptionFor', ->
      beforeEach ->
        @plush.setOptionFor( $("li[data-value='#{i}']", @plush.list) ) for i in @values

      it 'should set correct values', ->
        @select.serialize().should.equal @valueIds.join('&')

      it 'should set placeholder values and in correct order', ->
        placeholders = []
        $('.plush-multi-select-item span', @plush.inputContainer).each ->
          placeholders.push $(this).html().replace /(\r\n|\n|\r| )/gm, ''

        placeholderValues = ['AliceBlue', 'AntiqueWhite', 'Aqua']
        placeholders[i].should.equal(placeholderValues[i]) for i in [0,1,2]

    describe 'click on list items', ->
      it 'should set correct values on click', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).trigger('mousedown') for i in @values
        @select.serialize().should.equal @valueIds.join('&')

    describe 'click on list items', ->
      it 'should remove option on click on .plush-remove', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).trigger('mousedown') for i in @values
        @select.serialize().should.equal @valueIds.join('&')

        $(".plush-multi-select-item[data-value='2'] .plush-remove",  @plush.inputContainer).click()
        @select.serialize().should.equal "test_model=1&test_model=3"

  context 'with multiple select and drag & drop', ->
    beforeEach ->
      @select = $.renderTemplate 'select_tag', ''
      @select.attr 'multiple', 'multiple'
      @select.data 'drag-drop', true
      @plush = new PlushMulti @select

      @values = [1,2,3,5,7]
      @valueIds = []
      @valueIds.push("test_model=#{i}") for i in @values

    describe 'drag list items', ->
      it 'place item at beginning of list', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).trigger('mousedown') for i in @values
        @select.serialize().should.equal @valueIds.join('&')

        # Mock dragging an item in list after another item
        toDrag = $('.plush-multi-select-item',    @plush.container)[3]          # Item with value 5
        @plush.moveMultiSelectItem new mockMultiSelectItem(toDrag, null)

        newValues = []
        newValues.push("test_model=#{i}") for i in [5,1,2,3,7]
        @select.serialize().should.equal newValues.join('&')

      it 'place item after another item', ->
        $(".plush-option-list li[data-value='#{i}'] a",  @plush.container).trigger('mousedown') for i in @values
        @select.serialize().should.equal @valueIds.join('&')

        # Mock dragging an item in list after another item
        toDrag = $('.plush-multi-select-item',    @plush.container)[3]          # Item with value 5
        dropAfter = $('.plush-multi-select-item', @plush.container)[0]          # Item with value 1
        @plush.moveMultiSelectItem new mockMultiSelectItem(toDrag, dropAfter)

        newValues = []
        newValues.push("test_model=#{i}") for i in [1,5,2,3,7]
        @select.serialize().should.equal newValues.join('&')



