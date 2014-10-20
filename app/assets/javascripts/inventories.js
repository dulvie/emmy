app.controller('inventory_form_ctrl', function ($scope) {

	$scope.init = function() {
		var inv = $('#in_inventory_date').val().split(/\D/);
		inv.length == 1 ? $scope.inv_date = new Date() : $scope.inv_date = new Date(inv[0], --inv[1], inv[2]);
	};

	$scope.inv_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_inv_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.inv_open = true;
	};

});
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