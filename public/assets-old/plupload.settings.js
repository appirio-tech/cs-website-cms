// Assigns default Plupload settings that work with the asset pipeline.
(function () {
  var proxied = plupload.Uploader;
  
  plupload.Uploader = function (settings) {
    settings = $.extend({}, settings, {
      multipart: true,
      flash_swf_url: '/assets/plupload.flash.swf',
      silverlight_xap_url: '/assets/plupload.silverlight.xap'
    });
    
    return proxied.apply(this, [settings]);
  };
}());
