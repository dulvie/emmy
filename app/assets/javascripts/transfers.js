app.controller('transfer_form_ctrl', function ($scope) {
	$scope.options = gon.warehouses[0].shelves;

	$scope.init = function() {
		$scope.warehouse_id = $('#transfer_from_warehouse_id').val();
		for (x=0; x < gon.warehouses.length; x++) {
			if ($scope.warehouse_id == gon.warehouses[x].id) {
				options = gon.warehouses[x].shelves;
				//$scope.product_id = $scope.options[0].product_id
				//$scope.quantity = $scope.options[0].quantity
			};
		};

		var product_id = $('#transfer_product_id').val();
		for (x=0; x < $scope.options.length; x++) {
			if (product_id == $scope.options[x].product_id) {
				$scope.quantity = $scope.options[x].quantity;
				$scope.prod_id = parseInt(product_id);
			};
		};
		
	};

	$scope.select_warehouse = function() {
		//alert($scope.warehouse_id);
		//alert(gon.warehouses[0].shelves[0].name);
		for (x=0; x < gon.warehouses.length; x++) {
			if ($scope.warehouse_id == gon.warehouses[x].id) {
				$scope.options = gon.warehouses[x].shelves;
				$scope.prod_id = $scope.options[0].product_id
				$scope.quantity = $scope.options[0].quantity
				$('#transfer_product_id').val($scope.prod_id);
			};
		};
	};

	$scope.select_product = function() {
		for (x=0; x < $scope.options.length; x++) {
			if ($scope.prod_id == $scope.options[x].product_id) {
				$scope.quantity = $scope.options[x].quantity
				$('#transfer_product_id').val($scope.prod_id);
			};
		};
	};
});