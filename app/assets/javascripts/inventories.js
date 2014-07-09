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

	$scope.report_item = function(inventory_id, item_id, qty_id) {
		var id = '#'+qty_id
		var qty = $(id).val();

		
		var inventory_item = {};
		inventory_item.actual_quantity = qty;
		//alert(JSON.stringify(inventory_item));
		var url = "inventories/"+inventory_id+"/inventory_items/"+item_id+".json"
		ajaxService.put(url, inventory_item).then(function(data) {
			//alert(data);	
		});
		
	};
});