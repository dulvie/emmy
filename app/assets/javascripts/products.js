app.controller('product_form_ctrl', function ($scope) {

	$scope.init = function() {
		
		$scope.item_id = $('#product_item_id').val();

		var ex = $('#in_expire_at').val().split(/\D/);
		ex.length == 1 ? $scope.ex_date = new Date() : $scope.ex_date = new Date(ex[0], --ex[1], ex[2]);

		var re = $('#in_refined_at').val().split(/\D/);
		re.length == 1 ? $scope.re_date = new Date() : $scope.re_date = new Date(re[0], --re[1], re[2]);
	};

	$scope.ex_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_ex_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.ex_open = true;
	};

	$scope.re_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_re_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.re_open = true;
	};

	$scope.select_item = function() {
		for (x=0; x < gon.items.length; x++) {
			if (gon.items[x].id == $scope.item_id) {
				$('#product_in_price').val(gon.items[x].in_price);
				$('#product_distributor_price').val(gon.items[x].distributor_price);
				$('#product_retail_price').val(gon.items[x].retail_price);
			}
		}
	}
});