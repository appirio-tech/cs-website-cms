$(document).ready(function() {
    if(location.href.lastIndexOf('#logined')!=-1){
        $('.nav.hide a,.sidebar li a').each(function() {
            console.log($(this).attr('href'))
            $(this).attr('href',$(this).attr('href')+'#logined')
        })
        $('.loginbar-wrapper .container > div').toggleClass('hide');
        $('.nav').toggleClass('hide');
    }

    $('.login-form .btn').click(function() {
        return true;
    });
    $('.btn-logout').click(function() {
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
        $($(this).attr('data-toggle')).removeClass('hide');
        return false;
    });

    $('.techs a').mouseover(function() {
        var i=$(this).parent().index();
        $('.tip .col5').addClass('hide');
        $('.tip .col5:eq('+i+')').removeClass('hide');
        $('.tip .arrow').css({left:$(this).position().left-$(this).parents("ul").position().left+40})
    })

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
    if(exist('.banner')) {
        $(".banner .container").hide().show(); // fix layout issue in IE7
    }
        if(exist('.member-profile')) {
        $(".member-profile .stat .place .count").each(function() {
            var count = $(this);
            count.css("width", 3.3*count.data("count"));
        });
        $(".member-profile .recommend-this-member").click(function() {
            $(this).parent().hide();
            $(".recommendation").show();
        });
    }

    /* about us modal */
    if(exist('#team-member-modal')) {
        $(".team a[href='#team-member-modal']").click(function() {
            var team = $(this).parentsUntil('.team');
            team = $(team[team.length-1]).parent();
            var large = $('.photo', team).data("large");
            var name = $('h2 a', team).text();
            var modal = $("#team-member-modal");
            $(".photo", modal).attr("src", large);
            $("h2 a", modal).text(name);
        });
    }

    /* file upload */
    $('.btn-file input[type=file]').change(function() {
        var filePath = $(this).val().split('\\');
        var fname = filePath[filePath.length - 1];
        if(fname=="") fname="No file chosen";
        $(this).next().text(fname);
    }).hover(function() {
            $(this).prev().toggleClass('hover');
        });

});

function exist(el) {
    return $(el).length>0;
}