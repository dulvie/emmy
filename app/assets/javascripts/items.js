app.controller('item_form_ctrl', function ($scope, price) {
	$scope.init = function() {
		$('#in_price_edit').val(price.toDecimal($('#item_in_price').val()));
    $('#distributor_price_edit').val(price.toDecimal($('#item_distributor_price').val()));
    $('#retail_price_edit').val(price.toDecimal($('#item_retail_price').val()));
	};
	$scope.before_submit = function() {
    $('#item_in_price').val(price.toInteger($('#in_price_edit').val()));
    $('#item_distributor_price').val(price.toInteger($('#distributor_price_edit').val()));
    $('#item_retail_price').val(price.toInteger($('#retail_price_edit').val()));
	};	
});