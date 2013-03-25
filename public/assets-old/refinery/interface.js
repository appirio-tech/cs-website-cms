(function() {

  this.init_interface = function() {
    var $menu;
    if (parent && parent.document.location.href !== document.location.href) {
      $("body#dialog_container.dialog").addClass("iframed");
    }
    $("input:submit:not(.button)").addClass("button");
    if (!$.browser.msie) {
      $("#page_container, .wym_box").corner("5px bottom");
      $(".wym_box").corner("5px tr");
      $(".field > .wym_box").corner("5px tl");
      $(".wym_iframe iframe").corner("2px");
      $(".form-actions:not(\".form-actions-dialog\")").corner("5px");
    }
    $("#recent_activity li a, #recent_inquiries li a").each(function(i, a) {
      return $(this).textTruncate({
        width: $(this).width(),
        tooltip: false
      });
    });
    $("textarea.wymeditor").each(function() {
      var instance, next, prev, textarea;
      textarea = $(this);
      if ((instance = WYMeditor.INSTANCES[$((textarea.next(".wym_box").find("iframe").attr("id") || "").split("_")).last().get(0)]) != null) {
        if (((next = textarea.parent().next()) != null) && next.length > 0) {
          next.find("input, textarea").keydown($.proxy(function(e) {
            var shiftHeld;
            shiftHeld = e.shiftKey;
            if (shiftHeld && e.keyCode === $.ui.keyCode.TAB) {
              this._iframe.contentWindow.focus();
              return e.preventDefault();
            }
          }, instance)).keyup(function(e) {
            var shiftHeld;
            return shiftHeld = false;
          });
        }
        if (((prev = textarea.parent().prev()) != null) && prev.length > 0) {
          return prev.find("input, textarea").keydown($.proxy(function(e) {
            if (e.keyCode === $.ui.keyCode.TAB) {
              this._iframe.contentWindow.focus();
              return e.preventDefault();
            }
          }, instance));
        }
      }
    });
    if (($menu = $("#menu")).length > 0) {
      $menu.jcarousel({
        vertical: false,
        scroll: 1,
        buttonNextHTML: "<img src='/assets/refinery/carousel-right.png' alt='down' height='15' width='10' />",
        buttonPrevHTML: "<img src='/assets/refinery/carousel-left.png' alt='up' height='15' width='10' />",
        listTag: $menu.get(0).tagName.toLowerCase(),
        itemTag: $menu.children(":first").get(0).tagName.toLowerCase()
      });
      if ($menu.outerWidth() < $("#page_container").outerWidth()) {
        $("#page_container:not('.login #page_container')").corner("5px tr");
      } else {
        $("#page_container:not('.login #page_container')").uncorner();
      }
    }
    $("#current_locale li a").click(function(e) {
      $("#current_locale li a span").each(function(span) {
        return $(this).css("display", ($(this).css("display") === "none" ? "" : "none"));
      });
      $("#other_locales").animate({
        opacity: "toggle",
        height: "toggle"
      }, 250);
      $("html,body").animate({
        scrollTop: $("#other_locales").parent().offset().top
      }, 250);
      return e.preventDefault();
    });
    $("#existing_image img").load(function() {
      var margin_top;
      margin_top = $("#existing_image").height() - $("form.edit_image").height() + 8;
      if (margin_top > 0) {
        return $("form.edit_image .form-actions").css({
          "margin-top": margin_top
        });
      }
    });
    $(".form-actions .form-actions-left input:submit#submit_button").click(function(e) {
      return $("<img src='/assets/refinery/ajax-loader.gif' width='16' height='16' class='save-loader' />").appendTo($(this).parent());
    });
    $(".form-actions.form-actions-dialog .form-actions-left a.close_dialog").click(function(e) {
      var titlebar_close_button;
      titlebar_close_button = $('.ui-dialog-titlebar-close');
      if (parent) {
        titlebar_close_button = parent.$('.ui-dialog-titlebar-close');
      }
      titlebar_close_button.trigger('click');
      return e.preventDefault();
    });
    return $("a.suppress").live("click", function(e) {
      return e.preventDefault();
    });
  };

}).call(this);
