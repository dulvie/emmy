app.controller('inventory_item_list_ctrl', function($scope, ajaxService) {

    $scope.report_item = function(path, item_id, qty_id) {
        var id = '#'+qty_id
        var qty = $(id).val();
        var inventory_item = {reported: 'true'};
        inventory_item.actual_quantity = qty;
        var url = path+"/inventory_items/"+item_id+".json"
        ajaxService.put(url, inventory_item).then(function(data) {
            //alert(data);
            var b1 = '#' + qty_id.replace('qty_', 'b1_');
            var b2 = '#' + qty_id.replace('qty_', 'b2_');
            $(b1).addClass('hide');
            $(b2).removeClass('hide');
        });

    };
});