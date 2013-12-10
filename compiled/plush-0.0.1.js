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
      return $element.data('plush', new Plush($element));
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


  buffer += "<div class='plush-input'>\n  <div class='plush-placeholder'>";
  if (stack1 = helpers.placeholder) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.placeholder); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
  buffer += escapeExpression(stack1)
    + "</div>\n  <input class='' type='text' value='";
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
    + "'>\n  ";
  if (stack1 = helpers.label) { stack1 = stack1.call(depth0, {hash:{},data:data}); }
  else { stack1 = (depth0 && depth0.label); stack1 = typeof stack1 === functionType ? stack1.call(depth0, {hash:{},data:data}) : stack1; }
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
  this.Plush = (function() {
    function Plush(element, options) {
      var defaults, key, value,
        _this = this;
      this.element = element;
      this.options = options != null ? options : {};
      this.element.hide();
      this.element.wrap('<div class="plush-container"></div>');
      this.container = this.element.parent();
      this.container.append($.handlebar('plush_input', {
        placeholder: this.element.attr('placeholder')
      }));
      this.list = $('.plush-option-list', this.container);
      this.inputContainer = $('.plush-input', this.container);
      this.placeholder = $('.plush-placeholder', this.inputContainer);
      this.input = $('input', this.inputContainer);
      this.options.multiple = (this.options.multiple != null) || (this.element.attr('multiple') != null);
      this.searchWithAjax = this.element.data('query') != null;
      this.dataDefaults = {};
      this.queryDefault = 'q';
      defaults = {
        noResults: 'No results found for: ',
        labelMethod: 'label',
        listItemTemplate: 'plush_list_item',
        optgroupTemplate: 'plush_optgroup_item',
        multiSelectTemplate: 'plush_multi_select_item',
        position: 'bottom',
        url: null
      };
      for (key in defaults) {
        value = defaults[key];
        this.setDefaultOption(key, value);
      }
      this.list.addClass(this.options.listItemTemplate.replace(/\_/g, '-'));
      this.container.addClass("position-" + this.options.position);
      this.element.attr('tabindex', -1);
      if ($('option[selected]', this.element).length > 0 && !this.options.multiple) {
        this.placeholder.html($('option[selected]', this.element).html());
        this.input.val($('option[selected]', this.element).html());
      }
      if (this.options.url != null) {
        this.createListFromSource();
      } else {
        if ($('optgroup', this.element).length > 0) {
          this.createListFromGroupedOptions();
        } else {
          this.createListFromOptions();
        }
      }
      if (this.element.attr('placeholder') != null) {
        this.element.prop('selectedIndex', -1);
      } else {
        this.setOptionFor($('li:first-child', this.list));
      }
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
      this.list.on('click', 'a', function(event) {
        event.preventDefault();
        event.stopPropagation();
        if (_this.options.multiple) {
          return _this.addOptionFor($(event.currentTarget).parents('li').first());
        } else {
          _this.setOptionFor($(event.currentTarget).parents('li').first());
          return _this.hide();
        }
      }).on('keydown', 'a', function(event) {
        event.preventDefault();
        return event.stopPropagation();
      }).on('keyup', 'a', function(event) {
        event.preventDefault();
        event.stopPropagation();
        return _this.handleListKeyPress(event);
      });
      this.element.trigger('initialized');
      return this;
    }

    Plush.prototype.handleInputKeyPress = function(event) {
      if (event.keyCode === 38 || event.keyCode === 40) {
        event.preventDefault();
        if (event.keyCode === 38) {
          $('li:not(.hidden):last a', this.list).focus();
        }
        if (event.keyCode === 40) {
          return $('li:not(.hidden):first a', this.list).focus();
        }
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
      if (event.keyCode === 38 || event.keyCode === 40) {
        if (event.keyCode === 38) {
          $link = this.prevAnchor($anchor);
        }
        if (event.keyCode === 40) {
          $link = this.nextAnchor($anchor);
        }
        if (!$link.length > 0) {
          this.input.focus();
        } else {
          $link.focus();
        }
      }
      if (event.keyCode === 27) {
        this.input.focus();
      }
      if (event.keyCode === 13) {
        $anchor = $(event.currentTarget);
        this.setOptionFor($anchor.parents('li').first());
        return $anchor.blur();
      }
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
      this.placeholder.html(listItem.data('label'));
      this.element.val(listItem.data('value'));
      return this.element.trigger('change');
    };

    Plush.prototype.addOptionFor = function(listItem) {
      var $item;
      $item = $.handlebar('plush_multi_select_item', {
        label: listItem.data('label'),
        value: listItem.data('value')
      });
      this.inputContainer.prepend($item);
      return this.element.trigger('change');
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
      options = this.getAttributesFromElement(optionItem);
      options.value = $option.val();
      options.label = $option.html();
      return $.handlebar(this.options.listItemTemplate, options);
    };

    Plush.prototype.createListFromSource = function() {
      var ajaxOptions, dataOptions,
        _this = this;
      this.inputContainer.addClass('loading');
      ajaxOptions = {
        url: this.options.url,
        type: "get",
        dataType: "json"
      };
      dataOptions = this.dataDefaults;
      if (this.searchWithAjax) {
        dataOptions[this.queryDefault] = this.input.val();
      }
      ajaxOptions.data = dataOptions;
      return $.ajax(ajaxOptions).done(function(result, status, xhr) {
        return _this.createListFromJSON(result);
      }).always(function() {
        _this.inputContainer.removeClass('loading');
        return _this.checkResults();
      });
    };

    Plush.prototype.hasFocus = function() {
      return $('*:focus', this.container).length > 0;
    };

    Plush.prototype.createListFromJSON = function(result) {
      var $group, groupName, groupObject, item, _i, _j, _k, _len, _len1, _len2, _ref;
      if (result == null) {
        result = [];
      }
      this.list.empty();
      if ((result != null) && !$.isEmptyObject(result)) {
        if ($.inArray('value', Object.keys(result[0])) >= 0) {
          for (_i = 0, _len = result.length; _i < _len; _i++) {
            item = result[_i];
            if (item['label'] == null) {
              item['label'] = item[this.options.labelMethod];
            }
            this.list.append($.handlebar(this.options.listItemTemplate, item));
            this.element.append("<option value=" + item.value + ">" + item.label + "</option>");
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
              if (item['label'] == null) {
                item['label'] = item[this.options.labelMethod];
              }
              $('ul', $group).append($.handlebar(this.options.listItemTemplate, item));
            }
            this.list.append($group);
          }
        }
        this.input.focus();
        return this.checkResults();
      }
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
        var $element;
        $element = $(this);
        if (matcher.test($element.html())) {
          return $element.parents('.plush-list-item').first().removeClass('hidden');
        } else {
          return $element.parents('.plush-list-item').first().addClass('hidden');
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
      msg = this.options.noResults + this.input.val();
      if ($('.plush-no-results', this.list).length === 0) {
        return this.list.append($("<div class='plush-no-results'>" + msg + "</div>"));
      } else {
        $('.plush-no-results', this.list).html(msg);
        return $('.plush-no-results', this.list).show();
      }
    };

    Plush.prototype.hideNoResults = function() {
      return $('.plush-no-results', this.list).hide();
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

    Plush.prototype.hide = function() {
      if (!this.hasFocus()) {
        if (!this.options.multiple) {
          this.placeholder.show();
          this.input.hide();
        }
        this.inputContainer.removeClass('opened');
        return this.list.hide();
      }
    };

    Plush.prototype.getAttributesFromElement = function(element) {
      var attr, options, _i, _len, _ref;
      options = {};
      _ref = element.attributes;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        attr = _ref[_i];
        if (attr.nodeName.match(/^data-/)) {
          options[attr.nodeName.replace(/^data-/, '')] = attr.nodeValue;
        }
      }
      return options;
    };

    Plush.prototype.bind = function(Method) {
      var _this = this;
      return function() {
        return Method.apply(_this, arguments);
      };
    };

    return Plush;

  })();

  $(function() {
    return $("[data-toggle='plush']").plush();
  });

}).call(this);
(function() {


}).call(this);
