// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

app.controller('SalesCtrl', function ($scope, ajaxService) {
	$scope.customers = [];
	$scope.selected = undefined;
	
	$scope.initSales = function() {
		
		ajaxService.get("customers.json", "").then(function(data) {
			var customer = data.customers;
			$scope.customer = customer;
			//for (var i = 0; i < $scope.customers.length; i++) {
			//	if ($scope.customers[i].name == selected)
			//		$scope.customerModel = $scope.customers[i];
			//};			
		});		
	};	
	$scope.onSelect = function (item, model, label) {
	    $('#sale_customer_id').val(item.id); 
	    //alert(model);
	    //alert(label);
	};
	
	$scope.datevar = new Date();
	$scope.dateOptions1 = {
		    'starting-day': 1,
			'show-weeks': false
			};
    $scope.open1 = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.isOpen1 = true;
    	};
	//--------------------
	$scope.products = [];
	$scope.warehouseModel = {};
	//$scope.customerModel = "";
	$scope.productModel = 0;
	$scope.priceModel = 0;
	
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
