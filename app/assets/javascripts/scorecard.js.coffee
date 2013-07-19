totalRadioQuestions = 0

this.hide_submitbutton = ->
  if $('#deleteSubmissionCheckbox').is(':checked')
    $('#btnSave').show()
  else
    $('#btnSave').hide()

this.process_json = (input) ->
  totalRadioQuestions = 0
  # input = $.parseJSON(input_str);
  question_groups = {};

  key = k for k of input
  #input = input[key]

  for question in input
    # for each question in the input json
    qs_grp_no = question["question__r"]["qwikscore_question_group__r"]["sequence_number"]
    if question_groups[qs_grp_no] == undefined
      # create a question group if the question group is seen for the first time
      # also store the necessary information for rendering the question group
      qs_grp = question["question__r"]["qwikscore_question_group__r"]
      question_groups[qs_grp_no] = {"name": qs_grp["name"], "weight": qs_grp["group_weight"], "questions": {}}

    # new scorecards will have undefined (null) comments
    if question["comments"] == undefined
      question["comments"] = ""        

    # group questions and store the required information for rendering based on the question group they belong to,
    # ordering them as per sequence number
    question_groups[qs_grp_no]["questions"][question["question__r"]["sequence_number"]] = {
      "text": question["question__r"]["question_text_long"],
      "weight": question["question__r"]["question_weight"],
      "type": question["question__r"]["question_type"],
      "min": question["question__r"]["minimum_value"],
      "max": question["question__r"]["maximum_value"],
      "answer_value": question["answer_value"],
      "answer_text": question["answer_text"],
      "isanswered": question["isanswered"],
      "comments": question["comments"],
      "id": question["id"]
    }

  question_groups


this.scorecard_render = (question_groups, container) ->
  for q of question_groups
    # for each question group, render it, and append it to the div container
    $("#"+ container).append(question_group_render(question_groups[q]))

  return


this.question_group_render = (ques_grp) ->
  # question group boiler plate template
  ques_grp_dom = $("<div class='question_group'>
    <div class='title'><h1>#{ques_grp.name} - #{ques_grp.weight}%</h1></div>
  </div>");

  for q of ques_grp["questions"]
    # for each question in the question group, render it and append it to the question group
    ques_grp_dom.children(":last").append(question_render(ques_grp["questions"][q]))

  ques_grp_dom


this.question_render = (question) ->
  if question["type"] == "Text"
    answer_text = if question["answer_text"] != undefined then question["answer_text"] else ""
    answer_text = decodeURIComponent(answer_text.replace(/\+/g,  " "))

    # if question type is Text, render a textarea
    question_answer_dom = "<div class='control-group'>
      <label class='control-label'>Comments</label>
      <div class='controls'>
        <textarea class='span10 scorecard' name='answers[#{question.id}]' onKeyDown='limitText(this,255);' onKeyUp='limitText(this,255);'>#{answer_text}</textarea>
      </div>
      <div id='#{question.id}_hint' class='hint'>Limit 255 characters</div>
    </div>"

    ques_dom = $(question_answer_dom)

  else   
    totalRadioQuestions += 1

    # else render the radio buttons
    question_answer_dom = "<table width='100%'><tr>"
    
    # loop through question choices
    question_range = [question["min"]..question["max"]]
    for i in question_range
      if question["isanswered"] == 1 && question["answer_value"] == i
        question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[#{question.id}]' value='#{i}' checked><label>#{i}</label></td>"

      else
        if question["answer_value"] == 0 && i == 3 && question["max"] == 4
          question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[#{question.id}]' value='#{i}' checked><label>#{i}</label></td>"

        else
          question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[#{question.id}]' value='#{i}'><label>#{i}</label></td>"

    question_answer_dom += "</tr></table>"

    ques_dom = $("<div class='well rating'>
      <table width='100%'>
        <tr>
          <td rowspan='2' class='weight'>#{question.weight}%</td>
          <td rowspan='2' class='desc'>#{question.text}</td>
          <td colspan='2' class='options'>Unsatisfactory</td>
          <td colspan='2' class='options'>Exceeded Expectations</td>                    
        </tr>
        <tr>
          <td  colspan='4'>
            #{question_answer_dom}
          </td>
        </tr>
        <tr>
          <td  colspan='5'>
            <textarea name='comments[#{question.id}]' class='question-comments' placeholder='Your comments...'>#{question["comments"]}</textarea><br/><span style='font-size:x-small'>No maximum number of characters.</span>
          </td>
        </tr>        
      </table>
    </div>");

  ques_dom


this.limitText = (limitField, limitNum) ->
  # find the correct hint element
  hint = $("##{limitField.name}_hint");

  if limitField.value.length > 0
    remchar = limitNum - limitField.value.length
    $(hint).html("Characters Remaining : "+ remchar)

  else
    $(hint).html("Limit #{limitNum} characters")

  if limitField.value.length > limitNum
    $(hint).html("Characters Remaining : 0")
    limitField.value = limitField.value.substring(0, limitNum)
    alert("Comments are limited to #{limitNum} characters.")


this.doSubmit = (scored) ->
  allTextareasCompleted = true
  totalRadioQuestionsAnswered = 0
  jsonData = []

  $("input.scorecard,textarea.scorecard").each ->
    if this.tagName == "INPUT"
      if this.checked
        # for each radio box in scorecard, capture the value of the radio box thats checked
        jsonData.push({type: 'qwikscore_question_answer', id: this.name, field: {id: 'answer_text', value: this.value}});
        totalRadioQuestionsAnswered = totalRadioQuestionsAnswered + 1;
    else
      # for each textarea in scorecard, capture the text filled in
      if this.value.length == 0
        allTextareasCompleted = false
        jsonData.push({type: 'qwikscore_question_answer', id: this.name, field: {id:'answer_text', value: encodeURIComponent(this.value.replace(/\+/g," "))}})


  # deleteing this scorecard
  if document.getElementById("deleteSubmissionCheckbox").checked
    $("#scorecard_form").submit()

  # submitting the scores
  else if !scored || (allTextareasCompleted && (totalRadioQuestionsAnswered == totalRadioQuestions))
    # set the value of scored
    $("#hidden_scored").val scored.toString()

    # The generated xml is added as the value of a hidden input of the form
    #$("#hiddenjson").val JSON.stringify(jsonData)

    # alert JSON.stringify(jsonData)
    # and the form is submitted
    $("#scorecard_form").submit()

  else
    alert("Looks like you missed something! Please complete all questions and enter text for all comment fields.")  