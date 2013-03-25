(function() {

  this.init_sortable_menu = function() {
    var $menu;
    $menu = $("#menu");
    if ($menu.length === 0) {
      return;
    }
    $menu.sortable({
      items: "> *:not(#menu_reorder, #menu_reorder_done)",
      axis: "x",
      cursor: "crosshair",
      connectWith: ".nested",
      update: function() {
        return $.post("/refinery/update_menu_positions", $menu.sortable("serialize", {
          key: "menu[]",
          expression: /plugin_([\w]*)$/
        }));
      }
    }).tabs();
    $menu.sortable("disable");
    $menu.find("#menu_reorder").click(function(e) {
      return trigger_reordering(e, true);
    });
    $menu.find("#menu_reorder_done").click(function(e) {
      return trigger_reordering(e, false);
    });
    return $menu.find("> a").corner("top 5px");
  };

}).call(this);
