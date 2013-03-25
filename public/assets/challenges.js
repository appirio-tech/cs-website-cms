(function() {

  $(function() {
    if ($(".submission-wrapper").length > 0) {
      window.submission = new Submission;
    }
    if ($(".search-form.challenges").length > 0) {
      return window.challegeList = new ChallengeList;
    }
  });

  window.ChallengeList = (function() {

    function ChallengeList() {
      $("select.chosen").chosen();
      $(".label[title*=]").tooltip();
      $(".search-form a.toggle-options").toggle(function(event) {
        event.preventDefault();
        return $(".search-form .options").slideUp();
      }, function(event) {
        event.preventDefault();
        return $(".search-form .options").slideDown();
      });
    }

    return ChallengeList;

  })();

}).call(this);
