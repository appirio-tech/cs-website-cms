$(document).ready(function() {
    if(location.href.lastIndexOf('#logined')!=-1){
        $('.nav.hide a').each(function() {
            console.log($(this).attr('href'))
            $(this).attr('href',$(this).attr('href')+'#logined')
        })
        $('.loginbar-wrapper .container > div').toggleClass('hide');
        $('.nav').toggleClass('hide');
    }

    $('.login-form .btn').click(function() {
        /*
        $('.loginbar-wrapper .login').hide();
        $('.loginbar-wrapper .logined').show();
        $('.nav.hide a').each(function() {
            console.log($(this).attr('href'))
            $(this).attr('href',$(this).attr('href')+'#logined')
        })
        $('.nav').toggleClass('hide');
        return false;
        */
        return true;        
    });
    $('.btn-logout').click(function() {
        /*
        $('.loginbar-wrapper .login').show();
        $('.loginbar-wrapper .logined').hide();
        $('.nav').toggleClass('hide');
        return false;
        */
        return true;
    });

    $('.modal').on('show', function () {
        if(exist('.modal .jqTransform')) {
            $('.modal').jqTransform();
        }
    });

    $('#res-swicher a').click(function() {
        if($(this).hasClass('active')) return;
        $('#res-swicher a.active').removeClass('active');
        $(this).addClass('active');
        $('.res').addClass('hide');
        $($(this).attr('rel')).removeClass('hide');
    });

    $('#forgot-password-modal button.btn[type="submit"]').click(function() {
        $('#thank-modal .content').html('<p>Your request has been sent. You will receive an email from support, shortly.</p>');
        $('#thank-modal').modal('show');
        return false;
    });
    $('#register-modal input[type="submit"]').click(function() {

        $('#register-modal input').each(function() {
            if($(this).val()==''){
                $(this).parents('.control-group').addClass('error');
                if($(this).parents('.controls').find('.help-inline').length==0){
                    $(this).parents('.controls').append('<div class="help-inline">*All fields are required.</div>')
                }else{
                    $(this).parents('.controls').find('.help-inline').html("*All fields are required.");
                }
            }else{
                $(this).parents('.control-group').removeClass('error');
                if($(this).parents('.controls').find('.help-inline').length!=0){
                    $(this).parents('.controls').find('.help-inline').remove();
                }
            }
        })

        if($('#register-modal input[type=checkbox]:checked').length==0){
            var checkbox=$('#register-modal input[type=checkbox]');
            checkbox.parents('.control-group').addClass('error');
            if(checkbox.parents('.controls').find('.help-inline').length==0){
                checkbox.parents('.controls label').append('<div class="help-inline">*You must agree to the terms of service.</div>')
            }else{
                checkbox.parents('.controls').find('.help-inline').html("*You must agree to the terms of service.");
            }
        }

        if($('#register-modal .error').length==0){
            $('#thank-modal .content').html('<p>Your request has been sent. You will receive a confirmation email from us, shortly.</p>');
            $('#thank-modal').modal('show');
        }

        return false;
    });

    if(exist('form.jqTransform')) {
        $('form.jqTransform').jqTransform();
    }

    if(exist('.scrollable')) {
        $('.scrollable').scrollable({circular:true}).autoscroll();
    }


    if(exist('.works')) {
        $('.works .icon-large').each(function(i,e) {
            var lr=(i % 2==0)?"left":"right";
            $(e).popover({animation:false,html:true,placement:lr,trigger:'manual'}).popover('show');
        });
    }

    $('input.typeahead').typeahead({
        minLength: 2,
        itemSelected: function (item){
          var url = null;
          if(item.challenge_id) {
            url = "http://www.cloudspokes.com/challenges/" + item.challenge_id;
          }
          else {
            url = "http://www.cloudspokes.com/members/" + item.name;
          }
          window.location = url;
        },
        sources: [{
          name: "Challenges", 
          type: "jsonp", 
          url: "http://cs-api-sandbox.herokuapp.com/v1/challenges/search", 
          queryName: "keyword",
          val: {},
          sourceTmpl: function(item) {
            return $("<span class='challenge'>").append("<span class='count'>" + item.days_till_close  + "</span> days left");
          },
          nameTmpl: function(item, typeahead) {
            return $("<span class='challenge'>")
              .append("<i class='icon-leaf'>")
              .append(typeahead.highlighter(item.name))
              .append("(<span class='prizes'>$" + item.total_prize_money + "</span>)")
          }
        },
        {
          name: "Members", 
          type: "jsonp", 
          url: "http://cs-api-sandbox.herokuapp.com/v1/members/search", 
          queryName: "keyword",
          val: {},
          sourceTmpl: function(item) {
            return $("<img>").attr("src", item.profile_pic);
          },
          nameTmpl: function(item, typeahead) {
            return $("<span class='member'>")
              .append("<i class='icon-user'>")
              .append(typeahead.highlighter(item.name))
              .append("(<span class='wins'>" + item.total_wins + " wins</span>)")
          }        
        }]
    });

});

function exist(el) {
    return $(el).length>0;
}