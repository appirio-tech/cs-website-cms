(function() {

  $(function() {
    this.processNewMessage = function() {
      var body, message, subject, to;
      to = $('#to').val();
      subject = $('#subject').val();
      body = $('#body').val();
      if (to.length > 0 && subject.length > 0 && body.length > 0) {
        body = body.replace(/\n\r?/g, '<br />');
        message = {
          to: to,
          subject: subject,
          body: body
        };
        $.ajax({
          type: 'POST',
          beforeSend: function(xhr) {
            return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
          },
          url: "/messages",
          data: {
            message: message
          },
          success: function(data, textStatus, jqHXR) {
            if (data['success']) {
              window.location.replace('/messages/inbox?sent=true');
            } else {
              alert("Error sending message: " + data['message']);
            }
            return false;
          },
          error: function(jqXHR, textStatus, errorThrown) {
            return alert(errorThrown);
          }
        });
      }
      return false;
    };
    return this.processReply = function(message_id) {
      var body;
      body = $('#body').val();
      if (body.length > 0) {
        body = body.replace(/\n\r?/g, '<br />');
        $.ajax({
          type: 'POST',
          beforeSend: function(xhr) {
            return xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
          },
          url: "/messages/" + message_id + "/reply",
          data: {
            body: body
          },
          success: function(data, textStatus, jqHXR) {
            window.location.reload(false);
            return false;
          },
          error: function(jqXHR, textStatus, errorThrown) {
            return alert(textStatus);
          }
        });
      }
      return false;
    };
  });

}).call(this);
