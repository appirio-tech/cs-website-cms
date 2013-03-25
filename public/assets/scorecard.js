(function() {
  var totalRadioQuestions;

  totalRadioQuestions = 0;

  this.hide_submitbutton = function() {
    if ($('#deleteSubmissionCheckbox').is(':checked')) {
      return $('#btnSave').show();
    } else {
      return $('#btnSave').hide();
    }
  };

  this.process_json = function(input) {
    var k, key, qs_grp, qs_grp_no, question, question_groups, _i, _len;
    totalRadioQuestions = 0;
    question_groups = {};
    for (k in input) {
      key = k;
    }
    for (_i = 0, _len = input.length; _i < _len; _i++) {
      question = input[_i];
      qs_grp_no = question["question__r"]["qwikscore_question_group__r"]["sequence_number"];
      if (question_groups[qs_grp_no] === void 0) {
        qs_grp = question["question__r"]["qwikscore_question_group__r"];
        question_groups[qs_grp_no] = {
          "name": qs_grp["name"],
          "weight": qs_grp["group_weight"],
          "questions": {}
        };
      }
      question_groups[qs_grp_no]["questions"][question["question__r"]["sequence_number"]] = {
        "text": question["question__r"]["question_text"],
        "weight": question["question__r"]["question_weight"],
        "type": question["question__r"]["question_type"],
        "min": question["question__r"]["minimum_value"],
        "max": question["question__r"]["maximum_value"],
        "answer_value": question["answer_value"],
        "answer_text": question["answer_text"],
        "isanswered": question["isanswered"],
        "id": question["id"]
      };
    }
    return question_groups;
  };

  this.scorecard_render = function(question_groups, container) {
    var q;
    console.log(question_groups);
    for (q in question_groups) {
      $("#" + container).append(question_group_render(question_groups[q]));
    }
  };

  this.question_group_render = function(ques_grp) {
    var q, ques_grp_dom;
    ques_grp_dom = $("<div class='question_group'>    <div class='title'><h1>" + ques_grp.name + " - " + ques_grp.weight + "%</h1></div>  </div>");
    for (q in ques_grp["questions"]) {
      ques_grp_dom.children(":last").append(question_render(ques_grp["questions"][q]));
    }
    return ques_grp_dom;
  };

  this.question_render = function(question) {
    var answer_text, i, ques_dom, question_answer_dom, question_range, _i, _j, _len, _ref, _ref1, _results;
    if (question["type"] === "Text") {
      answer_text = question["answer_text"] !== void 0 ? question["answer_text"] : "";
      answer_text = decodeURIComponent(answer_text.replace(/\+/g, " "));
      question_answer_dom = "<div class='control-group'>      <label class='control-label'>Comments</label>      <div class='controls'>        <textarea class='span10 scorecard' name='answers[" + question.id + "]' onKeyDown='limitText(this,255);' onKeyUp='limitText(this,255);'>" + answer_text + "</textarea>      </div>      <div id='" + question.id + "_hint' class='hint'>Limit 255 characters</div>    </div>";
      ques_dom = $(question_answer_dom);
    } else {
      totalRadioQuestions += 1;
      question_answer_dom = "<table width='100%'><tr>";
      question_range = (function() {
        _results = [];
        for (var _i = _ref = question["min"], _ref1 = question["max"]; _ref <= _ref1 ? _i <= _ref1 : _i >= _ref1; _ref <= _ref1 ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      for (_j = 0, _len = question_range.length; _j < _len; _j++) {
        i = question_range[_j];
        if (question["isanswered"] === 1 && question["answer_value"] === i) {
          question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[" + question.id + "]' value='" + i + "' checked><label>" + i + "</label></td>";
        } else {
          if (question["answer_value"] === 0 && i === 3 && question["max"] === 4) {
            question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[" + question.id + "]' value='" + i + "' checked><label>" + i + "</label></td>";
          } else {
            question_answer_dom += "<td class='level'><input class='scorecard' type='radio' name='answers[" + question.id + "]' value='" + i + "'><label>" + i + "</label></td>";
          }
        }
      }
      question_answer_dom += "</tr></table>";
      ques_dom = $("<div class='well rating'>      <table width='100%''>        <tr>          <td rowspan='2' class='weight'>" + question.weight + "%</td>          <td rowspan='2' class='desc'>" + question.text + "</td>          <td colspan='2' class='options'>Unsatisfactory</td>          <td colspan='2' class='options'>Exceeded Expectations</td>                            </tr>        <tr>          <td  colspan='4'>            " + question_answer_dom + "          </td>        </tr>      </table>    </div>");
    }
    return ques_dom;
  };

  this.limitText = function(limitField, limitNum) {
    var hint, remchar;
    hint = $("#" + limitField.name + "_hint");
    if (limitField.value.length > 0) {
      remchar = limitNum - limitField.value.length;
      $(hint).html("Characters Remaining : " + remchar);
    } else {
      $(hint).html("Limit " + limitNum + " characters");
    }
    if (limitField.value.length > limitNum) {
      $(hint).html("Characters Remaining : 0");
      limitField.value = limitField.value.substring(0, limitNum);
      return alert("Comments are limited to " + limitNum + " characters.");
    }
  };

  this.doSubmit = function(scored) {
    var allTextareasCompleted, jsonData, totalRadioQuestionsAnswered;
    allTextareasCompleted = true;
    totalRadioQuestionsAnswered = 0;
    jsonData = [];
    $("input.scorecard,textarea.scorecard").each(function() {
      if (this.tagName === "INPUT") {
        if (this.checked) {
          jsonData.push({
            type: 'qwikscore_question_answer',
            id: this.name,
            field: {
              id: 'answer_text',
              value: this.value
            }
          });
          return totalRadioQuestionsAnswered = totalRadioQuestionsAnswered + 1;
        }
      } else {
        if (this.value.length === 0) {
          allTextareasCompleted = false;
          return jsonData.push({
            type: 'qwikscore_question_answer',
            id: this.name,
            field: {
              id: 'answer_text',
              value: encodeURIComponent(this.value.replace(/\+/g, " "))
            }
          });
        }
      }
    });
    if (document.getElementById("deleteSubmissionCheckbox").checked) {
      return $("#scorecard_form").submit();
    } else if (!scored || (allTextareasCompleted && (totalRadioQuestionsAnswered === totalRadioQuestions))) {
      $("#hidden_scored").val(scored.toString());
      return $("#scorecard_form").submit();
    } else {
      return alert("Looks like you missed something! Please complete all questions and enter text for all comment fields.");
    }
  };

}).call(this);
