app.controller('item_form_ctrl', function ($scope, price) {
	$scope.init = function() {
		$('#item_in_price').val(price.toDecimal($('#item_in_price').val()));
    	$('#item_distributor_price').val(price.toDecimal($('#item_distributor_price').val()));
    	$('#item_retail_price').val(price.toDecimal($('#item_retail_price').val()));
	};
	$scope.before_submit = function() {
    	$('#item_in_price').val(price.toInteger($('#item_in_price').val()));
    	$('#item_distributor_price').val(price.toInteger($('#item_distributor_price').val()));
    	$('#item_retail_price').val(price.toInteger($('#item_retail_price').val()));
	};	
});