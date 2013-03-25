$(document).ready(function() {

    // aprosxacs -- member / challenge typeahead
    $('input.typeahead').typeahead({
        minLength: 2,
        itemSelected: function (item){
          var url = null;
          if(item.challenge_id) {
            url = gon.website_url + "/challenges/" + item.challenge_id;
          }
          else {
            url = gon.website_url + "/members/" + item.name;
          }
          window.location = url;
        },
        sources: [{
          name: "Challenges", 
          type: "jsonp", 
          url: gon.cs_api_url + "/challenges/search", 
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
          url: gon.cs_api_url + "/members/search", 
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

    
    if(location.href.lastIndexOf('#logined')!=-1){
        $('.nav.hide a,.sidebar li a').each(function() {
            $(this).attr('href',$(this).attr('href')+'#logined')
        })
        $('.logined a[href="27_member_profile-current-user.html"]').attr('href','27_member_profile-current-user.html#logined');
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

    if(exist('form.jqTransform')) {
        $('form.jqTransform').jqTransform();
    }

    if(exist('.scrollable')) {
        $('.scrollable').scrollable({circular:true,touch:false}).autoscroll();
    }
    if(exist('.switch')) {
        $('.switch').scrollable({next:'',prev:'',touch:false}).navigator({navi:'.tab'});
    }


    if(exist('.works')) {
        $('.works .icon-large').each(function(i,e) {
            var lr=(i % 2==0)?"left":"right";
            if($(window).width()<=767){
                lr="down";
            }
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


    /**
     *  placeholder
     */
    if(exist(':input[placeholder]')){
        $(":input[placeholder]").placeholder();
    }
	
//	String.prototype.trunc =
//     function(n,useWordBoundary){
//         var toLong = this.length>n,
//             s_ = toLong ? this.substr(0,n-1) : this;
//         s_ = useWordBoundary && toLong ? s_.substr(0,s_.lastIndexOf(' ')) : s_;
//         return  toLong ? s_ + '&hellip;' : s_;
//      };
//
//	 if (exist('.challenge')) {
//		$('.challenge h3 a').each(function() {
//			$(this).html($(this).html().trunc(53, true).toString());
//		});
//	 }

    //online droplist
//    $('.btn-online').click(function() {
//        $('.online').css({width:$(this).width(),left:$(this).position().left});
//        $('.online .viewport,.online .overview').css({width:$(this).width()-6});
//        $('.online').toggle();
//        $('.online').tinyscrollbar_update();
//        return false;
//    });
//    $(document).on('click',function() {$('.online').hide();}).on('click','.btn-online,.online',function (e) { e.stopPropagation() });
//    $('.online').tinyscrollbar();

    $('.btn-adv-search').click(function() {
        $(this).toggleClass('active');
        $('.filter form').toggleClass('hide');
        return false;
    })
    $('.form-adv-search').addClass('hide');
    $('.select-pane input[type=checkbox]').change(function(e) {

        var chkbox=$(this).parents(".checkbox");

        if(chkbox.text().indexOf('All')!=-1){
            if($(this).attr("checked")==undefined){
                chkbox.siblings().find('.jqTransformCheckbox.jqTransformChecked').removeClass("jqTransformChecked");
                chkbox.siblings().find('input').removeAttr("checked");
            }else{
                chkbox.siblings().find('.jqTransformCheckbox:not(.jqTransformChecked)').addClass('jqTransformChecked');
                chkbox.siblings().find('input').attr("checked","checked");
            }
        }else{
            if($(this).attr("checked")==undefined){
                var all=chkbox.parents(".select-pane").find(".checkbox:eq(0) .jqTransformCheckbox");
                if(all.hasClass("jqTransformChecked")){
                    all.removeClass("jqTransformChecked");
                    all.siblings('input').removeAttr("checked");
                }
            }
        }
        e.stopPropagation()
    })
});

function exist(el) {
    return $(el).length>0;
}
;
