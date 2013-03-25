(function() {

  $(function() {
    var maxEmailCount;
    $('#forgot-password-modal button.btn[type="submit"]').click(function() {
      var username;
      $('#forgot-password-modal .reset-results').html('<p></p>');
      username = $('#reset-username').val();
      if (username.length > 0) {
        $('#forgot-password-btn').html('Processing....');
        $.ajax({
          type: 'POST',
          url: '/users/password',
          data: {
            username: username
          },
          success: function(data, textStatus, jqHXR) {
            $('#forgot-password-modal .reset-results').html('<p>' + data + '</p>');
            $('#forgot-password-btn').html('SUBMIT');
            return false;
          },
          error: function(jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            $('#forgot-password-btn').html('SUBMIT');
            return $('#forgot-password-modal .reset-results').html('<p>We could not process your request successfully. Please make sure you are using your username and not email address.</p>');
          }
        });
      }
      return false;
    });
    $('#register-modal input[type="submit"]').click(function() {
      var checkbox, email, has_missing_fields, password, password_again, password_again_container, password_container, username;
      username = $('#input-name').val();
      email = $('#input-email').val();
      password = $('#input-pwd').val();
      password_again = $('#input-pwd-again').val();
      has_missing_fields = false;
      $('#register-modal input').each(function() {
        if ($(this).val() === '') {
          $(this).parents('.control-group').addClass('error');
          if ($(this).parents('.controls').find('.help-inline').length === 0) {
            return $(this).parents('.controls').append('<div class="help-inline">*All fields are required.</div>');
          } else {
            return $(this).parents('.controls').find('.help-inline').html("*All fields are required.");
          }
        } else {
          $(this).parents('.control-group').removeClass('error');
          if ($(this).parents('.controls').find('.help-inline').length !== 0) {
            return $(this).parents('.controls').find('.help-inline').remove();
          }
        }
      });
      if ($('#register-modal input[type=checkbox]:checked').length === 0) {
        checkbox = $('#register-modal input[type=checkbox]');
        checkbox.parents('.control-group').addClass('error');
        if (checkbox.parents('.controls').find('.help-inline').length === 0) {
          checkbox.parents('.controls label').append('<div class="help-inline">You must agree to the terms of service.</div>');
        } else {
          checkbox.parents('.controls').find('.help-inline').html("You must agree to the terms of service.");
        }
      }
      password_container = $('#input-password-container');
      password_again_container = $('#input-password-again-container');
      if ($('#register-modal .error').length === 0) {
        if (password.length < 8) {
          password_container.parents('.control-group').addClass('error');
          password_container.append('<div class="help-inline">8 characters with letters & numbers</div>');
        } else {
          if (password !== password_again) {
            password_container.parents('.control-group').addClass('error');
            password_container.append('<div class="help-inline">Passwords do not match</div>');
            password_again_container.parents('.control-group').addClass('error');
            password_again_container.append('<div class="help-inline">Passwords do not match</div>');
          }
        }
      }
      if ($('#register-modal .error').length === 0) {
        $('#sign-up-btn').val('Processing....');
        $.ajax({
          type: 'POST',
          url: '/users',
          data: {
            user: {
              username: username,
              email: email,
              password: password,
              password_confirm: password_again
            }
          },
          success: function(results, textStatus, jqHXR) {
            var email_container, username_container;
            console.log(results);
            if (results.indexOf('Member created successfully') === 0) {
              $('#signup-success-modal .content').html('<p style="text-align:center">' + results + '</p>');
              $('#signup-success-modal').modal('show');
            } else if (results.indexOf('email') !== -1) {
              email_container = $('#input-email-container');
              email_container.parents('.control-group').addClass('error');
              email_container.append('<div class="help-inline">' + results + '</div>');
            } else if (results.indexOf('sername') !== -1) {
              username_container = $('#input-username-container');
              username_container.parents('.control-group').addClass('error');
              username_container.append('<div class="help-inline">' + results + '</div>');
            } else if (results.indexOf('assword') !== -1) {
              if (results.indexOf('INVALID_NEW_PASSWORD: Your password m' !== -1)) {
                results = "M" + (results.slice(37));
              }
              password_container = $('#input-password-container');
              password_container.parents('.control-group').addClass('error');
              password_container.append('<div class="help-inline">' + results + '</div>');
            }
            return $('#sign-up-btn').val('Signup');
          },
          error: function(jqXHR, textStatus, errorThrown) {
            console.log(textStatus);
            return $('#sign-up-btn').val('Signup');
          }
        });
      }
      return false;
    });
    maxEmailCount = 10;
    $("form.invite-friends a.btn-add-email").click(function(event) {
      var currentCount, item, remove;
      event.preventDefault();
      currentCount = $("form.invite-friends .items").length;
      if (currentCount >= maxEmailCount) {
        window.alert("Sorry, limit " + maxEmailCount + " invites at a time.");
        return;
      }
      item = $("form.invite-friends .item").first().clone();
      item.find("input").val("");
      remove = $("<a href='#' class='remove'> remove </a>").click(function(event) {
        event.preventDefault();
        return $(this).parents(".item").remove();
      });
      item.append(remove);
      return $("form.invite-friends .emails").append(item);
    });
    return $("form.invite-friends").submit(function() {
      var pattern, retval;
      retval = true;
      pattern = new RegExp(/^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?$/i);
      $("form.invite-friends .item input").each(function() {
        var email;
        if (!retval) {
          next;

        }
        email = $(this).val();
        if (!pattern.test(email)) {
          alert("" + email + " is not a valid email address!");
          return retval = false;
        }
      });
      return retval;
    });
  });

}).call(this);
