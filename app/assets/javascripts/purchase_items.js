app.controller('purchase_items_form_ctrl', function ($scope) {

	var o =  $("#purchase_item_item_id").find('option').first().val();
	$scope.item_id = o;

	$scope.item_changed = function() {
		$scope.product = {};
		for (var x=0; x < gon.items.length; x++) {
			if ($scope.item_id == gon.items[x].id) {
				$scope.options = gon.items[x].products
				if (typeof($scope.options[0]) != "undefined")
					$scope.product.id = $scope.options[0].id
			}
		}
	}

	$scope.item_changed();
});