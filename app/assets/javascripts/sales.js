// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

app.controller('SalesCtrl', function ($scope, ajaxService) {
	$scope.customers = [];
	$scope.products = [];
	
	$scope.warehouseModel = {};
	$scope.customerModel = "";
	$scope.productModel = 0;
	$scope.priceModel = 0;
	
	$scope.initSales = function() {
		ajaxService.get("customers.json", "").then(function(data) {
			$scope.customers = data.customers;	
		});
		
	};	
	
	$scope.init = function() {
		
		ajaxService.get("products.json", "").then(function(data) {
			$scope.products = data.products;
			alert($scope.products[1].distributor_price);
		});
	}; 
	
	$scope.selectProduct = function() {
		if ($scope.customerModel == 1) {
			$scope.priceModel = Number($scope.products[$scope.productModel-1].distributor_price);
			//$scope.priceModel = 10.00;
		}
		else  {
			$scope.priceModel = Number($scope.products[$scope.productModel-1].retail_price);
			//$scope.priceModel = 10.00;
		}
		
	};
});