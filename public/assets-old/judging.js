(function() {

  $(function() {
    return this.addJudge = function(challenge_id) {
      var id;
      id = "signup-" + challenge_id;
      document.getElementById(id).innerHTML = 'Processing request...';
      return $.ajax({
        type: 'GET',
        url: '/judging/add_judge/' + challenge_id,
        success: function(results, textStatus, jqHXR) {
          return document.getElementById(id).innerHTML = results;
        }
      });
    };
  });

}).call(this);
