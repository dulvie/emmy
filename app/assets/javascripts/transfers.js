app.controller('transfer_form_ctrl', function ($scope) {
	$scope.options = {}
	$scope.init = function() {
		var warehouse = gon.warehouses[0];
		//alert(warehouse.shelves[0].quantity + " : " + warehouse.shelves[1].quantity);
		
		
	};

	$scope.select_warehouse = function() {
		//alert($scope.warehouse_id);
		//alert(gon.warehouses[0].shelves[0].name);
		for (x=0; x < gon.warehouses.length; x++) {
			if ($scope.warehouse_id == gon.warehouses[x].id) {
				$scope.options = gon.warehouses[x].shelves;
				$scope.product_id = $scope.options[0].product_id
				$scope.quantity = $scope.options[0].quantity
			}
		}
	};

	$scope.select_product = function() {
		for (x=0; x < $scope.options.length; x++) {
			if ($scope.product_id == $scope.options[x].product_id) {
				$scope.quantity = $scope.options[x].quantity
			}
		}
	};
});