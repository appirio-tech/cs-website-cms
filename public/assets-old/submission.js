(function() {

  if (!jQuery.fn.highlight) {
    jQuery.fn.highlight = function() {
      return $(this).each(function() {
        var el;
        el = $(this);
        el.before("<div/>");
        return el.prev().width(el.width()).height(el.height()).css({
          "position": "absolute",
          "background-color": "#ffff99",
          "opacity": ".9"
        }).fadeOut(1500);
      });
    };
  }

  window.Submission = (function() {

    function Submission() {
      this.diliverableFormTemplate = $(".new-deliverable form").clone();
      this.initSubmissionForm();
      this.initDeliverables();
      this.initDeliverableForm();
      this.initFileUpload();
      $("select.chosen").chosen();
    }

    Submission.prototype.initSubmissionForm = function() {
      return $("form.submission").bind("ajax:before", function() {
        return $(this).find("[type=submit]").attr("disabled", true).after("<span class='loading'> Saving.. </span>");
      });
    };

    Submission.prototype.initDeliverables = function() {
      var self;
      self = this;
      $(".deliverable a.edit").live("click", function(event) {
        event.preventDefault();
        return self.showDeliverableFormForUpdate(this);
      });
      return $(".deliverable a.delete").bind("ajax:before", function() {
        var layer;
        layer = $("<div class='layer'> Deleting... </div>");
        return $(this).parents(".deliverable").append(layer);
      });
    };

    Submission.prototype.initDeliverableForm = function() {
      var self;
      self = this;
      $("a#add-deliverable").click(function(event) {
        event.preventDefault();
        return $(".new-deliverable form").slideDown(function() {
          return $(this).find("input.url").focus();
        });
      });
      $("form.deliverable a.cancel").live("click", function(event) {
        event.preventDefault();
        return $(this).parents("form").slideUp();
      });
      $("form.deliverable select.type option[value=Code]").remove();
      $("form.deliverable select.type").live("change", function(event) {
        return self.deliverableFormTypeChanged(this);
      });
      return $("form.deliverable").bind("ajax:before", function() {
        return self.deliverableFormbeforeAjax(this);
      });
    };

    Submission.prototype.initFileUpload = function() {
      var drag_drop_area, self;
      self = this;
      drag_drop_area = $(".drag-drop-area");
      return drag_drop_area.filedrop({
        fallback_id: 'upload_button',
        url: drag_drop_area.data("url"),
        paramname: 'file',
        headers: {
          'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        error: function(err, file) {
          switch (err) {
            case "BrowserNotSupported":
              return alert('browser does not support html5 drag and drop');
            case 'TooManyFiles':
              return alert("Too many files");
            case 'FileTooLarge':
              return alert("File too large");
            default:
              return alert(err);
          }
        },
        maxfiles: 10,
        maxfilesize: 1,
        dragEnter: function() {
          return drag_drop_area.addClass("droppable");
        },
        drop: function() {
          return drag_drop_area.removeClass("droppable");
        },
        uploadStarted: function(i, file, len) {
          return drag_drop_area.text("Uploading " + len + " files...");
        },
        uploadFinished: function(i, file, response, time) {
          return self.addDeliverable(response);
        },
        afterAll: function() {
          return drag_drop_area.text("Drag and Drop Files Here to upload");
        }
      });
    };

    Submission.prototype.showDeliverableFormForUpdate = function(ele) {
      var deliverable, form, self;
      $(".deliverable form").remove();
      self = this;
      deliverable = $(ele).parents(".deliverable").data("deliverable");
      form = this.diliverableFormTemplate.clone();
      if (deliverable.source !== "storage") {
        form.find("select.type option[value=Code]").remove();
      }
      form.attr("action", ele.href);
      form.find("h4").text("Edit Deliverable");
      form.find("[type=submit]").val("update");
      form.find("select.type").val(deliverable.type);
      form.find("input.url").val(deliverable.url).attr("readonly", deliverable.source === "storage");
      form.find("textarea.comments").val(deliverable.comments);
      form.find("select.paas").val(deliverable.paas);
      if (deliverable.type !== "Code") {
        form.find("select.paas").parents(".control-group").hide();
      }
      form.find("input.username").val(deliverable.username);
      form.find("input.password").val(deliverable.password);
      form.append("<input name='_method' type='hidden' value='put'>");
      form.bind("ajax:before", function() {
        return self.deliverableFormbeforeAjax(this);
      });
      form.hide();
      $(ele).parents(".deliverable").find(".form-wrapper").empty().append(form);
      form.find("select.chosen").chosen();
      return form.slideDown();
    };

    Submission.prototype.deliverableFormbeforeAjax = function(form) {
      var result;
      result = this.checkDeliverableFormValidation(form);
      if (result === false) {
        return false;
      }
      $(form).find("[type=submit]").attr("disabled", true).after("<span class='loading'> Saving.. </span>");
      return $(form).find("a.cancel").hide();
    };

    Submission.prototype.deliverableFormTypeChanged = function(select) {
      var form, type;
      type = $(select).val();
      form = $(select).parents("form");
      if (type === "Code") {
        return form.find("select.paas").parents(".control-group").show();
      } else {
        return form.find("select.paas").parents(".control-group").hide();
      }
    };

    Submission.prototype.hasCodeTypeExcept = function(deliverable) {
      var array, result;
      result = false;
      array = $("div.deliverable").each(function() {
        var obj;
        obj = $(this).data("deliverable");
        if (deliverable.id === obj.id) {
          return;
        }
        result || (result = obj.type === "Code");
        return true;
      });
      return result;
    };

    Submission.prototype.addDeliverable = function(deliverable) {
      var actions, del, ele, info, path;
      $(".deliverables").find(".empty").remove();
      ele = $("<div class='deliverable'>").attr("id", "deliverable-" + deliverable.id).data("deliverable", deliverable);
      info = $("<div class='clearfix info'>");
      info.append("<div class='type'>" + deliverable.type + "</div>");
      info.append("<div class='url'>" + deliverable.url + "</div>");
      actions = $("<div class='actions'>");
      path = $("form.submission").attr("action") + "/deliverables/" + deliverable.id;
      actions.append("<a href='" + path + "' class='btn edit'> Edit </a>");
      del = $("<a href='" + path + "' class='btn btn-danger delete' data-remote='true' data-method='delete' data-confirm='Are you sure?'> Delete </a>");
      del.bind("ajax:before", function() {
        var layer;
        layer = $("<div class='layer'> Deleting... </div>");
        return $(this).parents(".deliverable").append(layer);
      });
      actions.append(del);
      info.append(actions);
      ele.append(info);
      ele.append("<div class='form-wrapper'>");
      $(".deliverables").append(ele);
      ele.focus();
      return ele.highlight();
    };

    Submission.prototype.checkDeliverableFormValidation = function(form) {
      var deliverable, result, type, url;
      type = $(form).find("select.type").val();
      url = $(form).find("input.url").val();
      result = true;
      $(form).find(".controls .error").remove();
      if (type.length === 0) {
        this.addDeliverableFormError($(form).find("select.type"), "type cannot be blank!");
        result = false;
      }
      deliverable = $(form).parents(".deliverable").data("deliverable");
      if (type === "Code" && this.hasCodeTypeExcept(deliverable)) {
        this.addDeliverableFormError($(form).find("select.type"), "Code should be uniq!");
        result = false;
      }
      if (url.length === 0) {
        this.addDeliverableFormError($(form).find("input.url"), "url cannot be blank!");
        result = false;
      }
      return result;
    };

    Submission.prototype.addDeliverableFormError = function(field, msg) {
      var control;
      control = $(field).parents(".controls");
      control.find(".error").remove();
      return control.append("<div class='error'>" + msg + "</div>");
    };

    Submission.prototype.updateDeliverable = function(deliverable) {
      var ele;
      ele = $("#deliverable-" + deliverable.id);
      ele.data("deliverable", deliverable);
      ele.find(".info .type").text(deliverable.type);
      ele.find(".info .url").text(deliverable.url);
      return this.completeSaveDeliverableForm(ele.find("form"));
    };

    Submission.prototype.removeDeliverable = function(id) {
      return $("#deliverable-" + id).fadeOut("slow", function() {
        return $(this).remove();
      });
    };

    Submission.prototype.completeSaveDeliverableForm = function(form) {
      $(form).find("[type=submit]").attr("disabled", false).siblings(".loading").remove();
      $(form).find("a.cancel").show();
      if ($(form).parents(".deliverable").length === 1) {
        return $(form).slideUp(function() {
          $(form).parents(".deliverable").focus();
          return $(form).parents(".deliverable").highlight();
        });
      } else {
        return $(form).slideUp();
      }
    };

    return Submission;

  })();

}).call(this);
