app.controller('product_form_ctrl', function ($scope) {

	$scope.init = function() {
		$scope.refined = true;
		$scope.sales = true;
		$scope.item_id = $('#product_item_id').val();
		var default_price = false;
		if ($('#product_distributor_price').val()=='')
			default_price = true;
		var ex = $('#in_expire_at').val().split(/\D/);
		ex.length == 1 ? $scope.ex_date = new Date() : $scope.ex_date = new Date(ex[0], --ex[1], ex[2]);

		var re = $('#in_refined_at').val().split(/\D/);
		re.length == 1 ? $scope.re_date = new Date() : $scope.re_date = new Date(re[0], --re[1], re[2]);
		
		$scope.select_item(default_price);
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

	$scope.select_item = function(default_price) {
		$scope.refined = true;
		$scope.sales = true;
		for (x=0; x < gon.items.length; x++) {
			if (gon.items[x].id == $scope.item_id) {

				$('#product_in_price').val(gon.items[x].in_price);
				if (default_price)
					$('#product_distributor_price').val(gon.items[x].distributor_price);
				if (default_price)
					$('#product_retail_price').val(gon.items[x].retail_price);

				if (gon.items[x].item_group == 'refined') {
					$scope.refined = false;
				}
				if ((gon.items[x].item_type == 'sales') || (gon.items[x].item_type == 'both')) {
					$scope.sales = false;
				}
			}
		}
	}

});