// Assigns default Plupload settings that work with the asset pipeline.
(function(){var e=plupload.Uploader;plupload.Uploader=function(t){return t=$.extend({},t,{multipart:!0,flash_swf_url:"/assets/plupload.flash.swf",silverlight_xap_url:"/assets/plupload.silverlight.xap"}),e.apply(this,[t])}})();
