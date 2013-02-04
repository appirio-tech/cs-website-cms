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

    // aprosxacs -- member / challenge typeahead
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