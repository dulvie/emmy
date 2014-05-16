// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

app.controller('SalesCtrl', function ($scope, ajaxService) {
	$scope.customers = [];
	$scope.warehouseModel = {};
	$scope.customerModel = {};
	$scope.selectWarehouse = function() {
		//alert($scope.warehouseModel);
		var m = ajaxService.gett("getCustomer", '&warehouse='+$scope.warehouseModel);
		//alert(m);
		//$scope.customers = [{"name":"ett"}];
		$scope.customers = m;
	};
	
});