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

		var batch_id = $('#transfer_batch_id').val();
		for (x=0; x < $scope.options.length; x++) {
			if (batch_id == $scope.options[x].batch_id) {
				$scope.quantity = $scope.options[x].quantity;
				$scope.bch_id = parseInt(batch_id);
			};
		};
		
	};

	$scope.select_warehouse = function() {
		//alert($scope.warehouse_id);
		//alert(gon.warehouses[0].shelves[0].name);
		for (x=0; x < gon.warehouses.length; x++) {
			if ($scope.warehouse_id == gon.warehouses[x].id) {
				$scope.options = gon.warehouses[x].shelves;
				$scope.bch_id = $scope.options[0].batch_id
				$scope.quantity = $scope.options[0].quantity
				$('#transfer_batch_id').val($scope.bch_id);
			};
		};
	};

	$scope.select_batch = function() {
		for (x=0; x < $scope.options.length; x++) {
			if ($scope.bch_id == $scope.options[x].batch_id) {
				$scope.quantity = $scope.options[x].quantity
				$('#transfer_batch_id').val($scope.bch_id);
			};
		};
	};
});