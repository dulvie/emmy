app.controller('production_material_form_ctrl', function ($scope) {

	$scope.init = function() {

		$scope.shelf_qty = 0;
		var idx = $('#material_batch_id').val();
		for (x=0; x < gon.shelves.length; x++) {
			if (gon.shelves[x].batch_id == idx) {
				$scope.shelf_qty = gon.shelves[x].quantity;
				$scope.bch = gon.shelves[x].batch_id;
			}
		}
	};

	$scope.change_batch = function() {
		for (x=0; x < gon.shelves.length; x++) {
			if (gon.shelves[x].batch_id == $scope.bch) {
				$scope.shelf_qty = gon.shelves[x].quantity;
			}
		}
	};

});