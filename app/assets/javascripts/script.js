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
        $('.loginbar-wrapper .login').hide();
        $('.loginbar-wrapper .logined').show();
        $('.nav.hide a').each(function() {
            console.log($(this).attr('href'))
            $(this).attr('href',$(this).attr('href')+'#logined')
        })
        $('.nav').toggleClass('hide');
        return false;
    });
    $('.btn-logout').click(function() {
        $('.loginbar-wrapper .login').show();
        $('.loginbar-wrapper .logined').hide();
        $('.nav').toggleClass('hide');
        return false;
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
});

function exist(el) {
    return $(el).length>0;
}