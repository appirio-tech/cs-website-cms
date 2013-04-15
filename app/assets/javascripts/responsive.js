/**
 * Responsive
 */
$(document).ready(function() {

    if($(window).width()>767){
        $('.select-pane').tinyscrollbar();
    }

    if($(window).width()<=979){

        if($(window).width()<=767) {
            $('.footer-wrapper h2').click(function() {
                var v=$(this).next().is(":visible");
                $('.footer-wrapper ul').hide();
                if(!v) $(this).next().toggle();
            })

            var footSocialLinks=$('.footer-wrapper .row-fluid div:eq(3)');
            footSocialLinks.detach().appendTo('.footer-wrapper .row-fluid').addClass('social-links');

            $('.form-account > .controls-row:first-child div:eq(2)').detach().prependTo('.form-account > .controls-row:first-child');

            $('.box-blue td br').remove();


            $('.rating table tr:first-child').each(function() {
                var w=$(this).find('.weight');
                var d=$(this).find('.desc');
                w.detach();
                d.detach();
                $(this).parent().prepend('<tr><td colspan="1" rowspan="1">'+w.text()+'</td><td colspan="3" rowspan="1">'+d.text()+'<br/><br/></td></tr>');
            });

        }

        $('.nav-wrapper .container').append('<a href="#" class="btn menu"><span><i></i></span></a>');
        $('.nav-wrapper nav li a').click(function() {
            $('.nav-wrapper nav').hide();
        })

        $('.menu').click(function() {
            $('.nav').toggle();
        });
        if($('.nav > li.active a:contains("ACCOUNT")').length>0){
            $('.sidebar').detach().appendTo('.nav > li.active');
        }
        $('.popover.left').removeClass('left').addClass('right');
    }


    $('.techs a').mouseover(function() {
        $('.techs a.active').removeClass('active');
        $(this).addClass('active');
        var i=$(this).parent().index();
        $('.tip .col5').addClass('hide');
        $('.tip .col5:eq('+i+')').removeClass('hide');

        if($('.techs').width()==134){
            $('.tip .arrow').css({top:$(this).position().top-$(this).parents("ul").position().top+40})
        }else{
            $('.tip .arrow').css({left:$(this).position().left-$(this).parents("ul").position().left+50})
        }
    }).click(function() {
            return false;
        });

    $('.switch .item').css({width:$('.switch').width()});

    $('.quotes .scrollable').each(function() {
        $(this).find('.item').width($('.scrollable').width()-20);
        var h=0;
        $(this).find('.item').each(function(){
            h=Math.max($(this).height(),h);
        });
        $(this).height(h);
    });
    $('.switch').css({height:$('.switch .item').height()})
});
(function(a){a.tiny=a.tiny||{};a.tiny.scrollbar={options:{axis:"y",wheel:40,scroll:true,lockscroll:true,size:"auto",sizethumb:"auto",invertscroll:false}};a.fn.tinyscrollbar=function(d){var c=a.extend({},a.tiny.scrollbar.options,d);this.each(function(){a(this).data("tsb",new b(a(this),c))});return this};a.fn.tinyscrollbar_update=function(c){return a(this).data("tsb").update(c)};function b(q,g){var k=this,t=q,j={obj:a(".viewport",q)},h={obj:a(".overview",q)},d={obj:a(".scrollbar",q)},m={obj:a(".track",d.obj)},p={obj:a(".thumb",d.obj)},l=g.axis==="x",n=l?"left":"top",v=l?"Width":"Height",r=0,y={start:0,now:0},o={},e="ontouchstart" in document.documentElement;function c(){k.update();s();return k}this.update=function(z){j[g.axis]=j.obj[0]["offset"+v];h[g.axis]=h.obj[0]["scroll"+v];h.ratio=j[g.axis]/h[g.axis];d.obj.toggleClass("disable",h.ratio>=1);m[g.axis]=g.size==="auto"?j[g.axis]:g.size;p[g.axis]=Math.min(m[g.axis],Math.max(0,(g.sizethumb==="auto"?(m[g.axis]*h.ratio):g.sizethumb)));d.ratio=g.sizethumb==="auto"?(h[g.axis]/m[g.axis]):(h[g.axis]-j[g.axis])/(m[g.axis]-p[g.axis]);r=(z==="relative"&&h.ratio<=1)?Math.min((h[g.axis]-j[g.axis]),Math.max(0,r)):0;r=(z==="bottom"&&h.ratio<=1)?(h[g.axis]-j[g.axis]):isNaN(parseInt(z,10))?r:parseInt(z,10);w()};function w(){var z=v.toLowerCase();p.obj.css(n,r/d.ratio);h.obj.css(n,-r);o.start=p.obj.offset()[n];d.obj.css(z,m[g.axis]);m.obj.css(z,m[g.axis]);p.obj.css(z,p[g.axis])}function s(){if(!e){p.obj.bind("mousedown",i);m.obj.bind("mouseup",u)}else{j.obj[0].ontouchstart=function(z){if(1===z.touches.length){i(z.touches[0]);z.stopPropagation()}}}if(g.scroll&&window.addEventListener){t[0].addEventListener("DOMMouseScroll",x,false);t[0].addEventListener("mousewheel",x,false);t[0].addEventListener("MozMousePixelScroll",function(z){z.preventDefault()},false)}else{if(g.scroll){t[0].onmousewheel=x}}}function i(A){a("body").addClass("noSelect");var z=parseInt(p.obj.css(n),10);o.start=l?A.pageX:A.pageY;y.start=z=="auto"?0:z;if(!e){a(document).bind("mousemove",u);a(document).bind("mouseup",f);p.obj.bind("mouseup",f)}else{document.ontouchmove=function(B){B.preventDefault();u(B.touches[0])};document.ontouchend=f}}function x(B){if(h.ratio<1){var A=B||window.event,z=A.wheelDelta?A.wheelDelta/120:-A.detail/3;r-=z*g.wheel;r=Math.min((h[g.axis]-j[g.axis]),Math.max(0,r));p.obj.css(n,r/d.ratio);h.obj.css(n,-r);if(g.lockscroll||(r!==(h[g.axis]-j[g.axis])&&r!==0)){A=a.event.fix(A);A.preventDefault()}}}function u(z){if(h.ratio<1){if(g.invertscroll&&e){y.now=Math.min((m[g.axis]-p[g.axis]),Math.max(0,(y.start+(o.start-(l?z.pageX:z.pageY)))))}else{y.now=Math.min((m[g.axis]-p[g.axis]),Math.max(0,(y.start+((l?z.pageX:z.pageY)-o.start))))}r=y.now*d.ratio;h.obj.css(n,-r);p.obj.css(n,y.now)}}function f(){a("body").removeClass("noSelect");a(document).unbind("mousemove",u);a(document).unbind("mouseup",f);p.obj.unbind("mouseup",f);document.ontouchmove=document.ontouchend=null}return c()}}(jQuery));