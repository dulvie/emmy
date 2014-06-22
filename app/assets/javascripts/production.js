app.controller('production_material_form_ctrl', function ($scope) {
	
	$scope.init = function() {

		$scope.shelf_qty = 0;
		var idx = $('#material_product_id').val();
		for (x=0; x < gon.shelves.length; x++) {
			if (gon.shelves[x].product_id == idx) {
				$scope.shelf_qty = gon.shelves[x].quantity;
				$scope.prod = gon.shelves[x].product_id;
			}
		}
	};
	
	$scope.change_product = function() {
		for (x=0; x < gon.shelves.length; x++) {
			if (gon.shelves[x].product_id == $scope.prod) {
				$scope.shelf_qty = gon.shelves[x].quantity;
			}
		}
	};

	$scope.test = function() {
		var idx = $('#material_product_id').val()
		alert(idx);
		alert($scope.prod);
	}
});