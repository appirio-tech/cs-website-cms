$ ->
  window.submission = new Submission
  
  if $(".submission-wrapper").length > 0
    window.submission = new Submission
  if $(".search-form.challenges").length > 0
    window.challegeList = new ChallengeList

class window.ChallengeList
  constructor: ->
    $("select.chosen").chosen()

    $(".label[title*=]").tooltip()
    $(".search-form a.toggle-options").toggle (event) ->
      event.preventDefault()
      $(".search-form .options").slideUp()
    , (event) ->
      event.preventDefault()
      $(".search-form .options").slideDown()

