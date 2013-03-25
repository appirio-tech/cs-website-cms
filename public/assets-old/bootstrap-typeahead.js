
!
function ($) {

  'use strict';

  var _defaults = {
      sources: [],
      maxResults: 8,
      minLength: 1,
      menu: '<ul class="typeahead dropdown-menu"></ul>',
      item: '<li><a href="#" class="standard"></a></li>',
      display: 'name',
      queryName: "query",
      val: 'id',
      itemSelected: function () { }
    },

    _keyCodes = {
      DOWN: 40,
      ENTER: 13 || 108,
      ESCAPE: 27,
      TAB: 9,
      UP: 38
    },

    Typeahead = function (element, options) {
      this.$element = $(element);
      this.options = $.extend(true, {}, $.fn.typeahead.defaults, options);
      this.$menu = $(this.options.menu).appendTo('body');
      this.sorter = this.options.sorter || this.sorter;
      this.highlighter = this.options.highlighter || this.highlighter;
      this.shown = false;
      this.initSource();
      this.listen();
    }

  Typeahead.prototype = {

      constructor: Typeahead,

      initSource: function() {
        var that = this;

        $.each(this.options.sources, function() {
          this.display = this.display || that.options.display;
          this.queryName = this.queryName || that.options.queryName;
          this.val = this.val || that.options.val;
          this.tmpl = this.tmpl || that.options.tmpl;
        });
      },

      eventSupported: function(eventName) {
        var isSupported = (eventName in this.$element);

        if (!isSupported) {
          this.$element.setAttribute(eventName, 'return;');
          isSupported = typeof this.$element[eventName] === 'function';
        }

        return isSupported;
      },

      lookup: function (event) {
        var that = this,
            items;

        this.query = this.$element.val();
        if (!this.query || this.query.length < this.options.minLength) {
          return this.shown ? this.hide() : this;
        }

        this.isFirstRender = true;
        $.each(this.options.sources, function() {
          var source = this;
          if(source.type === "remote") {
            $.proxy(that.loadItemsFromRemote(source), that)
          }
          else if(source.type === "jsonp") {
            $.proxy(that.loadItemsWithJSONP(source), that) 
          }
          else if(source.type === "localStorage") {
            source.data = JSON.parse(localStorage.getItem(this.key));
            $.proxy(that.filter(source), that);
          }
          else {
            $.proxy(that.filter(source), that);
          }
        })
      },

      loadItemsWithJSONP: function(source) {
        if (source.xhr) source.xhr.abort();

        var that = this;
        var params = {};
        params[source.queryName] = this.query;

        source.xhr = $.getJSON(source.url + "?callback=?", params, function(json) {
          source.data = json.response || json;
          $.proxy(that.filter(source), that)
        });
      },

      loadItemsFromRemote: function(source) {
        if (source.xhr) source.xhr.abort();

        var that = this;
        var params = {};
        params[source.queryName] = this.query;
        source.xhr = $.ajax(
          $.extend({}, source.ajaxSettings, {
            url: source.url,
            data: params,
            success: function(data) {
              source.data = json.response || json;
              $.proxy(that.filter(source), that)
            }
          })
        );

      },

      filter: function(source) {
        var that = this,
            items;

        items = $.grep(source.data, function (item) {
          return ~item[source.display].toLowerCase().indexOf(that.query.toLowerCase());
        });

        source.items = items.slice(0, this.options.maxResults);

        this.sortItems(source);

        return this.appendItem(source);
      },

      sortItems: function (source) {
        var that = this,
            beginswith = [],
            caseSensitive = [],
            caseInsensitive = [],
            item;

        while (item = source.items.shift()) {
          if (!item[source.display].toLowerCase().indexOf(this.query.toLowerCase())) {
            beginswith.push(item);
          } else if (~item[source.display].indexOf(this.query)) {
            caseSensitive.push(item);
          } else {
            caseInsensitive.push(item);
          }
        }

        source.items = beginswith.concat(caseSensitive, caseInsensitive);
      },

      show: function () {
        var pos = $.extend({}, this.$element.offset(), {
            height: this.$element[0].offsetHeight
        });

        this.$menu.css({
            top: pos.top + pos.height,
            left: pos.left
        });

        this.$menu.show();
        this.shown = true;
        return this;
      },

      hide: function () {
        this.$menu.hide();
        this.shown = false;
        return this;
      },

      highlighter: function (text) {
        var query = this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g, '\\$&');
        return text.replace(new RegExp('(' + query + ')', 'ig'), function ($1, match) {
          return '<strong>' + match + '</strong>';
        });
      },

      appendItem: function(source) {
        var that = this,
            html,
            $standardItem;

        var items = $(source.items).map(function (i, item) {
          if (source.tmpl) {
            i = $(source.tmpl(item));
          } else {
            i = $(that.options.item);
          }

          if (typeof source.val === 'string') {
            i.data('value', item[source.val]);
          } else {
            i.data('value', $.extend({}, source.val, item))
          }

          $standardItem = i.find('a.standard');
          if ($standardItem.length) {
            var sourceEle = source.sourceTmpl ? source.sourceTmpl(item) : source.name;
            var nameEle = source.nameTmpl ? source.nameTmpl(item, that) : that.highlighter(item[source.display]);

            $standardItem
              .append($("<span class='source'>").append(sourceEle))
              .append($("<span class='name'>").append(nameEle))
          }

          return i[0];
        });

        if(this.isFirstRender) {
          items.first().addClass('active');
          this.isFirstRender = false;
          this.$menu.html(items);
        }
        else {
          that.$menu.append(items);
        }

        this.showOrHide();
        return this;

      },
      showOrHide: function() {
        if(this.$menu.find("li").length > 0) {
          this.show();
        }
        else {
          this.hide();
        }
      },

      select: function () {
        var $selectedItem = this.$menu.find('.active');
        this.$element.val($selectedItem.find(".name").text()).change();
        this.options.itemSelected($selectedItem.data('value'));
        return this.hide();
      },

      next: function (event) {
        var active = this.$menu.find('.active').removeClass('active');
        var next = active.next();

        if (!next.length) {
          next = $(this.$menu.find('li')[0]);
        }

        next.addClass('active');
      },

      prev: function (event) {
        var active = this.$menu.find('.active').removeClass('active');
        var prev = active.prev();

        if (!prev.length) {
          prev = this.$menu.find('li').last();
        }

        prev.addClass('active');
      },

      listen: function () {
          this.$element
            .on('blur', $.proxy(this.blur, this))
            .on('focus', $.proxy(this.focus, this))
            .on('keyup', $.proxy(this.keyup, this));

          if (this.eventSupported('keydown')) {
            this.$element.on('keydown', $.proxy(this.keypress, this));
          } else {
            this.$element.on('keypress', $.proxy(this.keypress, this));
          }

          this.$menu
            .on('click', $.proxy(this.click, this))
            .on('mouseenter', 'li', $.proxy(this.mouseenter, this));
      },

      keyup: function (e) {
        e.stopPropagation();
        e.preventDefault();

        switch (e.keyCode) {
          case _keyCodes.DOWN:
          case _keyCodes.UP:
             break;
          case _keyCodes.TAB:
          case _keyCodes.ENTER:
            if (!this.shown) return;
            this.select();
            break;
          case _keyCodes.ESCAPE:
            this.hide();
            break;
          default:
            this.lookup();
        }
      },

      keypress: function (e) {
        e.stopPropagation();

        if (!this.shown) return;

        switch (e.keyCode) {
          case _keyCodes.TAB:
          case _keyCodes.ESCAPE:
          case _keyCodes.ENTER:
            e.preventDefault();
            break;
          case _keyCodes.UP:
            e.preventDefault();
            this.prev();
            break;
          case _keyCodes.DOWN:
            e.preventDefault();
            this.next();
            break;
        }
      },

      blur: function (e) {
        var that = this;
        e.stopPropagation();
        e.preventDefault();
        setTimeout(function () {
          if (!that.$menu.is(':focus')) {
            that.hide();
          }
        }, 150);
      },
      focus: function(e) {
        e.stopPropagation();
        e.preventDefault();
        this.showOrHide();
      },

      click: function (e) {
        e.stopPropagation();
        e.preventDefault();
        this.select();
      },

      mouseenter: function (e) {
        this.$menu.find('.active').removeClass('active');
        $(e.currentTarget).addClass('active');
      }
  }

  //  Plugin definition
  $.fn.typeahead = function (option) {
    return this.each(function () {
      var $this = $(this),
          data = $this.data('typeahead'),
          options = typeof option === 'object' && option;

      if (!data) {
          $this.data('typeahead', (data = new Typeahead(this, options)));
      }

      if (typeof option === 'string') {
          data[option]();
      }
    });
  }

  $.fn.typeahead.defaults = _defaults;
  $.fn.typeahead.Constructor = Typeahead;

  //  Data API (no-JS implementation)
  $(function () {
    $('body').on('focus.typeahead.data-api', '[data-provide="typeahead"]', function (e) {
      var $this = $(this);
      if ($this.data('typeahead')) return;
      e.preventDefault();
      $this.typeahead($this.data());
    })
  });
} (window.jQuery);
