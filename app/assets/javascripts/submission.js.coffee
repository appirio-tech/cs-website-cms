unless jQuery.fn.highlight
  jQuery.fn.highlight = ->
    $(this).each ->
      el = $(this);
      el.before("<div/>")
      el.prev()
        .width(el.width())
        .height(el.height())
        .css
          "position": "absolute",
          "background-color": "#ffff99",
          "opacity": ".9"   
        .fadeOut(1500)

class window.Submission
  constructor: ->
    @diliverableFormTemplate = $(".new-deliverable form").clone()
    @initSubmissionForm()
    @initDeliverables()
    @initDeliverableForm()
    @initFileUpload()
    $("select.chosen").chosen()

  initSubmissionForm: ->
    $("form.submission").bind "ajax:before", ->
      $(this).find("[type=submit]").attr("disabled", true).after("<span class='loading'> Saving.. </span>")

  initDeliverables: ->
    self = this
    $(".deliverable a.edit").live "click", (event) ->
      event.preventDefault()
      self.showDeliverableFormForUpdate(this)

    $(".deliverable a.delete").bind "ajax:before", -> 
      layer = $("<div class='layer'> Deleting... </div>")
      $(this).parents(".deliverable").append(layer)

  initDeliverableForm: ->
    self = this
    $("a#add-deliverable").click (event) ->
      event.preventDefault()
      $(".new-deliverable form").slideDown ->
        $(this).find("input.url").focus()

    $("form.deliverable a.cancel").live "click", (event) ->
      event.preventDefault()
      $(this).parents("form").slideUp()

    $("form.deliverable select.type option[value=Code]").remove()
    $("form.deliverable select.type").live "change", (event) ->
      self.deliverableFormTypeChanged(this)

    $("form.deliverable").bind "ajax:before", ->
      self.deliverableFormbeforeAjax(this)

  initFileUpload: ->
    self = this
    drag_drop_area = $(".drag-drop-area")
    drag_drop_area.filedrop
      fallback_id: 'upload_button'
      url: drag_drop_area.data("url")
      paramname: 'file'
      headers:
        'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
      error: (err, file) ->
        switch err
          when "BrowserNotSupported"
            alert('browser does not support html5 drag and drop')
          when 'TooManyFiles'
            alert("Too many files")
          when 'FileTooLarge'
            alert("File too large")
          else  
            alert(err)

      maxfiles: 10
      maxfilesize: 1    # max file size in MBs
      dragEnter: -> 
        drag_drop_area.addClass("droppable")

      drop: -> 
        drag_drop_area.removeClass("droppable")

      # a file began uploading
      # i = index => 0, 1, 2, 3, 4 etc
      # file is the actual file of the index
      # len = total files user dropped
      uploadStarted: (i, file, len) ->
        drag_drop_area.text("Uploading " + len + " files...")

      # response is the data you got back from server in JSON format.
      uploadFinished: (i, file, response, time) ->
        self.addDeliverable(response)        

      # runs after all files have been uploaded or otherwise dealt with
      afterAll: -> 
        drag_drop_area.text("Drag and Drop Files Here to upload")

  showDeliverableFormForUpdate: (ele) ->
    $(".deliverable form").remove()
    self = this
    deliverable = $(ele).parents(".deliverable").data("deliverable")
    form = @diliverableFormTemplate.clone()
    if deliverable.source != "storage"
      form.find("select.type option[value=Code]").remove()
    form.attr("action", ele.href)
    form.find("h4").text("Edit Deliverable")
    form.find("[type=submit]").val("update")
    form.find("select.type").val(deliverable.type)
    form.find("input.url").val(deliverable.url).attr("readonly", deliverable.source == "storage")
    form.find("textarea.comments").val(deliverable.comments)
    form.find("select.paas").val(deliverable.paas)
    if deliverable.type != "Code"
      form.find("select.paas").parents(".control-group").hide()
    form.find("input.username").val(deliverable.username)
    form.find("input.password").val(deliverable.password)
    form.append("<input name='_method' type='hidden' value='put'>")
    form.bind "ajax:before", ->
      self.deliverableFormbeforeAjax(this)

    form.hide()
    $(ele).parents(".deliverable").find(".form-wrapper").empty().append(form)
    form.find("select.chosen").chosen()
    form.slideDown()

  deliverableFormbeforeAjax: (form) ->
    result = @checkDeliverableFormValidation(form)
    return false if result == false

    $(form).find("[type=submit]").attr("disabled", true).after("<span class='loading'> Saving.. </span>")
    $(form).find("a.cancel").hide()


  deliverableFormTypeChanged: (select) ->
    type = $(select).val()
    form = $(select).parents("form")
    if type == "Code"
      form.find("select.paas").parents(".control-group").show()
    else
      form.find("select.paas").parents(".control-group").hide()

  hasCodeTypeExcept: (deliverable) ->
    result = false
    array = $("div.deliverable").each ->
      obj = $(this).data("deliverable")
      return if deliverable.id == obj.id
      result ||= obj.type == "Code"
      true
    
    result


  addDeliverable: (deliverable) ->
    $(".deliverables").find(".empty").remove()
    ele = $("<div class='deliverable'>").attr("id", "deliverable-" + deliverable.id)
      .data("deliverable", deliverable)
    info = $("<div class='clearfix info'>")
    info.append("<div class='type'>" + deliverable.type + "</div>")
    info.append("<div class='url'>" + deliverable.url + "</div>")

    actions = $("<div class='actions'>")
    path = $("form.submission").attr("action") + "/deliverables/" + deliverable.id
    actions.append("<a href='" + path + "' class='btn edit'> Edit </a>")
    del = $("<a href='" + path + "' class='btn btn-danger delete' data-remote='true' data-method='delete' data-confirm='Are you sure?'> Delete </a>")
    del.bind "ajax:before", -> 
      layer = $("<div class='layer'> Deleting... </div>")
      $(this).parents(".deliverable").append(layer)
    actions.append(del)

    info.append(actions)
    ele.append(info)
    ele.append("<div class='form-wrapper'>")

    $(".deliverables").append(ele)
    ele.focus()
    ele.highlight()

  checkDeliverableFormValidation: (form) ->
    type = $(form).find("select.type").val()
    url = $(form).find("input.url").val()

    result = true
    $(form).find(".controls .error").remove()
    if type.length == 0
      @addDeliverableFormError($(form).find("select.type"), "type cannot be blank!")
      result = false

    deliverable = $(form).parents(".deliverable").data("deliverable")
    if type == "Code" and @hasCodeTypeExcept(deliverable)
      @addDeliverableFormError($(form).find("select.type"), "Code should be uniq!")
      result = false

    if url.length == 0
      @addDeliverableFormError($(form).find("input.url"), "url cannot be blank!")
      result = false

    result

  addDeliverableFormError: (field, msg) ->
    control = $(field).parents(".controls")
    control.find(".error").remove()
    control.append("<div class='error'>" + msg + "</div>")

  updateDeliverable: (deliverable) ->
    ele = $("#deliverable-" + deliverable.id)
    ele.data("deliverable", deliverable)
    ele.find(".info .type").text(deliverable.type)
    ele.find(".info .url").text(deliverable.url)
    @completeSaveDeliverableForm(ele.find("form"))

  removeDeliverable: (id) ->
    $("#deliverable-" + id).fadeOut "slow", ->
      $(this).remove()

  completeSaveDeliverableForm: (form) ->
    $(form).find("[type=submit]").attr("disabled", false).siblings(".loading").remove()
    $(form).find("a.cancel").show()
    if $(form).parents(".deliverable").length == 1
      $(form).slideUp ->
        $(form).parents(".deliverable").focus();
        $(form).parents(".deliverable").highlight()
    else
      $(form).slideUp()
