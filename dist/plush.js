(function() {
  $.extend({
    handlebar: function(templateName, options) {
      var template;
      if (options == null) {
        options = {};
      }
      if (Handlebars.templates[templateName] == null) {
        template = $("script#" + templateName);
        if (template.length > 0) {
          Handlebars.templates[templateName] = Handlebars.compile(template.html());
        }
      }
      return $(Handlebars.templates[templateName](options));
    },
    plush: function(element) {
      var $element;
      $element = $(element);
      return $element.data('plush', ($element.attr('multiple') != null ? new PlushMulti($element) : new Plush($element)));
    }
  });

  $.fn.extend({
    plush: function() {
      return this.each(function() {
        return $.plush(this);
      });
    }
  });

}).call(this);
(function() {
  this.Plush = (function() {
    Plush.prototype.defaults = {
      labelMethod: 'label',
      listItemTemplate: 'plush_list_item',
      optgroupTemplate: 'plush_optgroup_item',
      multiSelectTemplate: 'plush_multi_select_item',
      noResultsTemplate: 'plush_no_results',
      noResultsMessage: 'No results were found for: ',
      position: 'bottom',
      url: null,
      preload: false,
      queryDefault: 'q'
    };

    function Plush(element, options) {
      var key, value, _ref;
      this.element = element;
      this.options = options != null ? options : {};
      this.element.hide();
      this.element.wrap('<div class="plush-container"></div>');
      this.container = this.element.parent();
      this.container.append($.handlebar('plush_input', {
        placeholder: this.element.attr('placeholder')
      }));
      this.list = $('.plush-option-list', this.container);
      this.inputContainer = $('.plush-input-wrapper', this.container);
      this.placeholder = $('.plush-placeholder', this.inputContainer);
      this.input = $('input', this.inputContainer);
      this.initialOption = this.getOption(false, true);
      this.queryData = this.getQueryDataFromElement(this.element.get(0));
      if (this.queryData == null) {
        this.queryData = {};
      }
      this.searchWithAjax = this.element.data('query') != null;
      _ref = this.defaults;
      for (key in _ref) {
        value = _ref[key];
        this.setDefaultOption(key, value);
      }
      this.addClassnames();
      this.setPlaceholders();
      this.element.attr('tabindex', -1);
      if (this.options.url != null) {
        if (!this.searchWithAjax || (this.searchWithAjax && this.options.preload)) {
          this.createListFromSource(true);
        } else {
          this.checkInitialOption();
        }
      } else {
        if ($('optgroup', this.element).length > 0) {
          this.createListFromGroupedOptions();
        } else {
          this.createListFromOptions();
        }
      }
      this.checkResults();
      this.setup();
      this.setEventHandlers();
      return this;
    }

    Plush.prototype.setPlaceholders = function() {
      if ($('option[selected]', this.element).length > 0) {
        this.placeholder.html($('option[selected]', this.element).html());
        return this.input.val($('option[selected]', this.element).html());
      }
    };

    Plush.prototype.setup = function() {
      if (!(this.initialOption.length > 0)) {
        if ((this.element.attr('placeholder') != null) && this.element.prop('selectedIndex', -1)) {

        } else {
          return this.setOptionFor($('li:first-child', this.list));
        }
      }
    };

    Plush.prototype.addClassnames = function() {
      this.list.addClass(this.options.listItemTemplate.replace(/\_/g, '-'));
      return this.container.addClass("position-" + this.options.position);
    };

    Plush.prototype.setDefaultOption = function(key, value) {
      var dataAttrName;
      if (this.options[key] == null) {
        dataAttrName = key.replace(/([A-Z])/g, function($1) {
          return "-" + $1.toLowerCase();
        });
        return this.options[key] = this.element.data(dataAttrName) || value;
      }
    };

    Plush.prototype.setOptionFor = function(listItem) {
      return this.setOption(listItem.data('label'), listItem.data('value'));
    };

    Plush.prototype.setOption = function(label, value) {
      this.placeholder.html(label);
      if (this.options.url != null) {
        this.element.empty();
        this.createOption(label, value);
      } else {
        this.element.val(value);
      }
      this.hide(true);
      return this.element.trigger('change');
    };

    Plush.prototype.createOption = function(label, value, selected) {
      if (selected == null) {
        selected = true;
      }
      if (!(this.getOption(value).length > 0)) {
        this.element.append("<option value=" + value + (selected ? ' selected' : '') + ">" + label + "</option>");
      }
      return this.element.trigger('change');
    };

    Plush.prototype.removeOption = function(value) {
      $("option[value=" + value + "]", this.element).remove();
      return this.element.trigger('change');
    };

    Plush.prototype.getOption = function(value, withSelected) {
      var $option, selector;
      if (value == null) {
        value = false;
      }
      if (withSelected == null) {
        withSelected = false;
      }
      selector = [(value !== false ? "[value=" + value + "]" : ''), (withSelected ? '[selected]' : '')].join('');
      return $option = $(selector, this.element);
    };

    Plush.prototype.focusAnchor = function(anchor) {
      anchor.focus();
      return anchor.addClass('focused');
    };

    Plush.prototype.blurAnchor = function(anchor) {
      anchor.blur();
      return anchor.removeClass('focused');
    };

    Plush.prototype.nextAnchor = function(anchor) {
      var $li, next;
      $li = anchor.parents('li').first();
      next = $('a', $li.next());
      if (next && !next.parents('li').first().hasClass('hidden')) {
        return next;
      } else {
        return this.nextAnchor(next);
      }
    };

    Plush.prototype.prevAnchor = function(anchor) {
      var $li, prev;
      $li = anchor.parents('li').first();
      prev = $('a', $li.prev());
      if (prev && !prev.parents('li').first().hasClass('hidden')) {
        return prev;
      } else {
        return this.prevAnchor(prev);
      }
    };

    Plush.prototype.nextOrPreviousAnchor = function(anchor) {
      if (this.nextAnchor(anchor).length > 0) {
        return this.nextAnchor(anchor);
      } else if (this.prevAnchor(anchor).length > 0) {
        return this.prevAnchor(anchor);
      }
    };

    Plush.prototype.hasFocus = function() {
      return $('*:focus', this.container).length > 0;
    };

    Plush.prototype.delayedSearch = function() {
      if (this.timer != null) {
        clearTimeout(this.timer);
      }
      return this.timer = setTimeout(this.bind(this.createListFromSource), 500);
    };

    Plush.prototype.search = function(query) {
      var matcher;
      matcher = new RegExp(query, 'i');
      $('.plush-list-item a', this.container).each(function() {
        var $listElement;
        $listElement = $(this).parents('.plush-list-item').first();
        if (matcher.test($(this).html())) {
          if (!$listElement.hasClass('disabled')) {
            return $listElement.removeClass('hidden');
          }
        } else {
          return $listElement.addClass('hidden');
        }
      });
      $('.plush-optgroup', this.container).each(function() {
        var $element;
        $element = $(this);
        if ($('.plush-list-item:not(.hidden)', $element).length === 0) {
          return $element.hide();
        } else {
          return $element.show();
        }
      });
      this.resizeList();
      return this.checkResults();
    };

    Plush.prototype.checkResults = function() {
      if ($('li:not(.hidden)', this.list).length === 0) {
        return this.showNoResults();
      } else {
        return this.hideNoResults();
      }
    };

    Plush.prototype.showNoResults = function() {
      var msg;
      msg = this.options.noResultsMessage + this.input.val();
      if ($('.plush-no-results', this.list).length === 0) {
        return this.list.append($.handlebar(this.options.noResultsTemplate, {
          message: msg
        }));
      } else {
        $('.plush-no-results', this.list).html(msg);
        return $('.plush-no-results', this.list).show();
      }
    };

    Plush.prototype.hideNoResults = function() {
      return $('.plush-no-results', this.list).hide();
    };

    Plush.prototype.resizeList = function() {
      if (this.options.position === 'top') {
        return this.list.css('top', "-" + (this.list.outerHeight(true)) + "px");
      }
    };

    Plush.prototype.show = function() {
      this.placeholder.hide();
      this.input.css('display', 'block');
      this.inputContainer.addClass('opened');
      this.list.show();
      if (!this.input.is(":focus")) {
        return this.input.focus();
      }
    };

    Plush.prototype.hide = function(force) {
      if (force == null) {
        force = false;
      }
      if (!this.hasFocus() || force) {
        this.showPlaceholder();
        this.inputContainer.removeClass('opened');
        this.input.hide();
        return this.list.hide();
      }
    };

    Plush.prototype.showPlaceholder = function() {
      return this.placeholder.show();
    };

    Plush.prototype.getAttributesFromElement = function(element, attr_regexp) {
      var attr, options, _i, _len, _ref;
      options = {};
      _ref = element.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (attr.nodeName.match(attr_regexp)) {
          options[attr.nodeName.replace(attr_regexp, '')] = attr.nodeValue;
        }
      }
      return options;
    };

    Plush.prototype.getDataFromElement = function(element) {
      return this.getAttributesFromElement(element, /^data-/);
    };

    Plush.prototype.getQueryDataFromElement = function(element) {
      return this.getAttributesFromElement(element, /^data-query-/);
    };

    Plush.prototype.bind = function(method) {
      var _this = this;
      return function() {
        return method.apply(_this, arguments);
      };
    };

    return Plush;

  })();

}).call(this);
(function() {
  Plush.prototype.setEventHandlers = function() {
    var _this = this;
    this.inputContainer.on('click', '.plush-placeholder, .plush-caret', function(event) {
      event.preventDefault();
      return _this.show();
    });
    this.container.on('blur', 'input, a', function() {
      return setTimeout(_this.bind(_this.hide), 100);
    });
    this.input.on('focus', function() {
      if (!_this.inputContainer.hasClass('opened')) {
        return _this.show();
      }
    }).on('keyup', function(event) {
      event.stopPropagation();
      return _this.handleInputKeyPress(event);
    });
    this.list.on('mousedown keydown keyup', 'a', function(event) {
      event.preventDefault();
      return event.stopPropagation();
    }).on('mousedown', 'a', function(event) {
      return _this.setOptionFor($(event.currentTarget).parents('li').first());
    }).on('click', 'a', function(event) {
      return event.preventDefault();
    }).on('keyup', 'a', function(event) {
      return _this.handleListKeyPress(event);
    }).on('blur', 'a', function(event) {
      return $(this).removeClass('focused');
    });
    return this.element.trigger('initialized');
  };

  Plush.prototype.handleInputKeyPress = function(event) {
    if (event.which === 38 || event.which === 40) {
      event.preventDefault();
      if (event.which === 38) {
        this.focusAnchor($('li:not(.hidden):last a', this.list));
      }
      if (event.which === 40) {
        return this.focusAnchor($('li:not(.hidden):first a', this.list));
      }
    } else if (event.which === 27) {
      return this.input.blur();
    } else {
      if (this.searchWithAjax) {
        return this.delayedSearch();
      } else {
        return this.search(this.input.val());
      }
    }
  };

  Plush.prototype.handleListKeyPress = function(event) {
    var $anchor, $link;
    $anchor = $(event.currentTarget);
    if (event.which === 38 || event.which === 40) {
      if (event.which === 38) {
        $link = this.prevAnchor($anchor);
      }
      if (event.which === 40) {
        $link = this.nextAnchor($anchor);
      }
      if (!$link.length > 0) {
        this.input.focus();
      } else {
        this.focusAnchor($link);
      }
    }
    if (event.which === 27) {
      this.input.focus();
    }
    if (event.which === 13) {
      return this.handleEnterOnListAnchor($(event.currentTarget));
    }
  };

  Plush.prototype.handleEnterOnListAnchor = function(anchor) {
    var $item;
    $item = anchor.parents('li').first();
    this.setOptionFor($item);
    return this.blurAnchor(anchor);
  };

}).call(this);
(function() {
  Plush.prototype.createListFromOptions = function() {
    var _this = this;
    return $('option', this.element).each(function(index, item) {
      return _this.list.append(_this.createListItemFromOption(item));
    });
  };

  Plush.prototype.createListFromGroupedOptions = function() {
    var _this = this;
    return $('optgroup', this.element).each(function(index, optGroup) {
      var $group, $optGroup;
      $optGroup = $(optGroup);
      $group = $.handlebar('plush_optgroup_item', {
        label: $optGroup.attr('label')
      });
      $('option', $optGroup).each(function(index, item) {
        return $('.plush-optgroup-list', $group).append(_this.createListItemFromOption(item));
      });
      return _this.list.append($group);
    });
  };

  Plush.prototype.createListItemFromOption = function(optionItem) {
    var $option, options;
    $option = $(optionItem);
    options = this.getDataFromElement(optionItem);
    options.value = $option.val();
    options.label = $option.html();
    return $.handlebar(this.options.listItemTemplate, options);
  };

  Plush.prototype.createListFromSource = function(initial) {
    var ajaxOptions, dataOptions,
      _this = this;
    if (initial == null) {
      initial = false;
    }
    this.inputContainer.addClass('loading');
    ajaxOptions = {
      url: this.options.url,
      type: "get",
      dataType: "json"
    };
    dataOptions = $.extend({}, this.queryData);
    if (this.searchWithAjax) {
      dataOptions[this.options.queryDefault] = this.input.val();
    }
    ajaxOptions.data = dataOptions;
    return $.ajax(ajaxOptions).done(function(result, status, xhr) {
      return _this.createListFromJSON(result, initial);
    }).always(function() {
      _this.inputContainer.removeClass('loading');
      return _this.checkResults();
    });
  };

  Plush.prototype.createListFromJSON = function(result, initial) {
    var $group, groupName, groupObject, item, _i, _j, _k, _len, _len1, _len2, _ref;
    if (result == null) {
      result = [];
    }
    if (initial == null) {
      initial = false;
    }
    this.list.empty();
    if ((result != null) && !$.isEmptyObject(result)) {
      if ($.inArray('value', Object.keys(result[0])) >= 0) {
        for (_i = 0, _len = result.length; _i < _len; _i++) {
          item = result[_i];
          this.checkItemLabel(item);
          this.list.append(this.createListItemFromJson(item));
        }
      } else {
        for (_j = 0, _len1 = result.length; _j < _len1; _j++) {
          groupObject = result[_j];
          groupName = Object.keys(groupObject)[0];
          $group = $.handlebar(this.options.optgroupTemplate, {
            label: groupName
          });
          _ref = groupObject[groupName];
          for (_k = 0, _len2 = _ref.length; _k < _len2; _k++) {
            item = _ref[_k];
            this.checkItemLabel(item);
            $('ul', $group).append(this.createListItemFromJson(item));
          }
          this.list.append($group);
        }
      }
      this.checkInitialOption();
      if (!initial) {
        this.input.focus();
      }
      return this.checkResults();
    }
  };

  Plush.prototype.checkInitialOption = function() {
    if (this.initialOption.length > 0) {
      return this.setOption(this.initialOption.html(), this.initialOption.val());
    }
  };

  Plush.prototype.createListItemFromJson = function(item) {
    return $.handlebar(this.options.listItemTemplate, item);
  };

  Plush.prototype.checkItemLabel = function(item) {
    if (item['label'] == null) {
      return item['label'] = item[this.options.labelMethod];
    }
  };

}).call(this);
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.PlushMulti = (function(_super) {
    __extends(PlushMulti, _super);

    function PlushMulti(element, options) {
      this.element = element;
      this.options = options != null ? options : {};
      this.defaults.dragDrop = false;
      PlushMulti.__super__.constructor.call(this, this.element, this.options = {});
    }

    PlushMulti.prototype.addClassnames = function() {
      this.container.addClass("plush-multiple");
      if (this.options.dragDrop) {
        this.container.addClass("plush-drag-drop");
      }
      return PlushMulti.__super__.addClassnames.call(this);
    };

    PlushMulti.prototype.setPlaceholders = function() {
      return null;
    };

    PlushMulti.prototype.setup = function() {
      var $option, option, selectedOptions, _i, _len,
        _this = this;
      selectedOptions = $('option[selected]', this.element);
      this.element.html('');
      for (_i = 0, _len = selectedOptions.length; _i < _len; _i++) {
        option = selectedOptions[_i];
        $option = $(option);
        this.addMultiSelectItem($option.html(), $option.val());
      }
      if (this.options.dragDrop) {
        return this.inputContainer.sortable({
          items: '> .plush-multi-select-item',
          placeholder: 'plush-drag-placeholder',
          forcePlaceholderSize: true,
          stop: function(event, ui) {
            return _this.moveMultiSelectItem(ui.item);
          }
        });
      }
    };

    PlushMulti.prototype.showPlaceholder = function() {
      if ($('.plush-multi-select-item', this.inputContainer).length > 0) {
        return this.placeholder.hide();
      } else {
        return this.placeholder.show();
      }
    };

    PlushMulti.prototype.setOptionFor = function(listItem) {
      var value;
      value = listItem.data('value');
      if (!(this.getOption(value).length > 0)) {
        this.addMultiSelectItem(listItem.data('label'), value);
      } else {
        this.getOption(value).attr('selected', 'selected');
      }
      return listItem.addClass('hidden');
    };

    PlushMulti.prototype.addMultiSelectItem = function(label, value) {
      var $item;
      $item = $.handlebar(this.options.multiSelectTemplate, {
        label: label,
        value: value
      });
      if ($('.plush-multi-select-item', this.inputContainer).length > 0) {
        $('.plush-multi-select-item', this.inputContainer).last().after($item);
      } else {
        this.inputContainer.prepend($item);
      }
      this.createOption(label, value);
      return this.element.trigger('change');
    };

    PlushMulti.prototype.checkResults = function() {
      var $listItem, listItem, _i, _len, _ref;
      _ref = $('li', this.list);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        listItem = _ref[_i];
        $listItem = $(listItem);
        if (this.getOption($listItem.data('value'), true).length > 0) {
          $listItem.addClass('hidden');
        }
      }
      return PlushMulti.__super__.checkResults.call(this);
    };

    PlushMulti.prototype.moveMultiSelectItem = function(item) {
      var $option, $prevItem, $prevOption;
      $option = this.getOption(item.data('value'));
      if (item.prev().length > 0) {
        $prevItem = item.prev();
        $prevOption = $("[value=" + ($prevItem.data('value')) + "]", this.element);
        $($prevOption, this.element).after($option);
      } else {
        this.element.prepend($option);
      }
      return this.element.trigger('change');
    };

    PlushMulti.prototype.setEventHandlers = function() {
      var _this = this;
      this.inputContainer.on('click', '.plush-remove', function(event) {
        var optionContainer;
        event.preventDefault();
        optionContainer = $(event.currentTarget).parents('.plush-multi-select-item').first();
        _this.removeOption(optionContainer.data('value'));
        optionContainer.remove();
        _this.showPlaceholder();
        return _this.checkResults();
      }).on('click', function(event) {
        if ($(event.target).hasClass('plush-input-wrapper')) {
          return _this.show();
        }
      });
      return PlushMulti.__super__.setEventHandlers.call(this);
    };

    PlushMulti.prototype.handleEnterOnListAnchor = function(anchor) {
      var $item, nextAnchor;
      $item = anchor.parents('li').first();
      this.setOptionFor($item);
      this.blurAnchor(anchor);
      nextAnchor = this.nextOrPreviousAnchor(anchor);
      if (nextAnchor != null) {
        return this.focusAnchor(nextAnchor);
      }
    };

    return PlushMulti;

  })(Plush);

}).call(this);
(function() {
  $(function() {
    return $("[data-toggle='plush']").plush();
  });

}).call(this);
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_image_list_item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<li class='plush-list-item plush-imagebox' data-label='";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "' data-value='";
  if (stack1 = helpers.value) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.value); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "'>\n  <a href='#'>\n    <img src='";
  if (stack1 = helpers.image) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.image); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "'>\n    <span class='title'>";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</span>\n    <span class='description'>";
  if (stack1 = helpers.description) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.description); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</span>\n  </a>\n</li>\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_input'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class='plush-input-wrapper'>\n  <div class='plush-placeholder'>";
  if (stack1 = helpers.placeholder) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.placeholder); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</div>\n  <input class='plush-input' type='text' value='";
  if (stack1 = helpers.value) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.value); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "'>\n  <div class='plush-caret'></div>\n</div>\n<ul class='plush-option-list'></ul>\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_list_item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function";


  buffer += "<li class='plush-list-item' data-label='";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "' data-value='";
  if (stack1 = helpers.value) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.value); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "'>\n  <a href='#'>";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "</a>\n</li>\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_multi_select_item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class='plush-multi-select-item' data-value='";
  if (stack1 = helpers.value) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.value); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "'>\n  <span>";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</span>\n  <a class='plush-remove'></a>\n</div>\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_no_results'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function", escapeExpression=this.escapeExpression;


  buffer += "<div class='plush-no-results'>\n  ";
  if (stack1 = helpers.message) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.message); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "\n</div>\n";
  return buffer;
  });
})();
(function() {
  var template = Handlebars.template, templates = Handlebars.templates = Handlebars.templates || {};
templates['plush_optgroup_item'] = template(function (Handlebars,depth0,helpers,partials,data) {
  this.compilerInfo = [4,'>= 1.0.0'];
helpers = this.merge(helpers, Handlebars.helpers); data = data || {};
  var buffer = "", stack1, functionType="function";


  buffer += "<li class='plush-optgroup'>\n  <div class='plush-optgroup-label'>";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  if(stack1 || stack1 === 0) { buffer += stack1; }
  buffer += "</div>\n  <ul class='plush-optgroup-list'></ul>\n</li>\n";
  return buffer;
  });
})();
(function() {


}).call(this);
