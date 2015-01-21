;(function($, UI){
  jQuery.extend(jQuery.expr[':'], {
      attrStartsWith: function (el, _, b) {
          for (var i = 0, atts = el.attributes, n = atts.length; i < n; i++) {
              if(atts[i].nodeName.indexOf(b[3]) === 0) {
                  return true;
              }
          }

          return false;
      }
  });

  oldHtml = $.fn.html;

  $.extend($.fn, {
    ukMargin: function(){
      var ele = $(this), obj;
      if (!ele.data("stackMargin")) {
          obj = new UI.stackMargin(ele, UI.Utils.options(ele.attr("data-uk-margin")));
      }
      return this;
    },
    html: function() {
      oldHtml.apply(this, arguments);
      var uk_components = $(this).find(':attrStartsWith("data-uk")');
      if (uk_components.length) $(document).trigger("uk-domready");
    }

  })
})(jQuery, jQuery.UIkit)
