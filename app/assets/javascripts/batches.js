app.controller('batch_form_ctrl', function ($scope, price) {

	$scope.init = function() {
		$scope.refined = true;
		$scope.sales = true;
		$scope.item_id = $('#batch_item_id').val();
		var default_price = false;
		if ($('#batch_distributor_price').val()=='')
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

				$('#batch_in_price').val(price.toDecimal(gon.items[x].in_price));
				if (default_price)
					$('#batch_distributor_price').val(gon.items[x].distributor_price);
				if (default_price)
					$('#batch_retail_price').val(gon.items[x].retail_price);
				$('#batch_distributor_price').val(price.toDecimal($('#batch_distributor_price').val()));
			    $('#batch_retail_price').val(price.toDecimal($('#batch_retail_price').val()));			    	
				if (gon.items[x].item_group == 'refined') {
					$scope.refined = false;
				}
				if ((gon.items[x].item_type == 'sales') || (gon.items[x].item_type == 'both')) {
					$scope.sales = false;
				}
			}
		}
	};

	$scope.before_submit = function() {
    	$('#batch_in_price').val(price.toInteger($('#batch_in_price').val()));
    	$('#batch_distributor_price').val(price.toInteger($('#batch_distributor_price').val()));
    	$('#batch_retail_price').val(price.toInteger($('#batch_retail_price').val()));
	};	

});