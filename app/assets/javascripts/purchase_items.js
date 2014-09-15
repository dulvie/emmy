app.controller('purchase_items_form_ctrl', function ($scope, $filter) {
	
	$scope.show_batch = false;
    var o = $("#purchase_item_item_id").val();
	$scope.item_id = o;
	var p = $('#purchase_item_price').val();
	var pri = true;
    if (p == '') {
    	pri = false;
    }


	$scope.item_changed = function() {
		$scope.show_batch = false;
		$scope.batch = {};
		for (var x=0; x < gon.items.length; x++) {
			if ($scope.item_id == gon.items[x].id) {
				$scope.options = gon.items[x].batches;
				$scope.unit = gon.items[x].unit.name;
				$('.money').unmask();
				if (pri) {
					$('#price').val(p);
					pri = false;
				}	
				else {	
					$('#price').val(gon.items[x].in_price);
				}
				$('.money').mask('####0,00', {reverse: true});
				//$('#purchase_item_price').val(gon.items[x].in_price);
				if (typeof($scope.options[0]) != "undefined") {
					$scope.batch.id = $scope.options[0].id;
					$scope.show_batch = true;
				}
				if (gon.items[x].stocked) {
					$scope.show_batch = true;
				}				
			}
		}
	}
	$scope.item_changed();

});