// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

app.controller('salesCtrl', function ($scope, ajaxService) {
	$scope.customers = [];
	$scope.selected = undefined;
	$scope.isOpen1 = false;
	
	$scope.initSales = function() {
		
		ajaxService.get("customers.json", "").then(function(data) {
			var customer = data.customers;
			$scope.customer = customer;
			$scope.reference = [{"id":1, "name":"adam"},{"id":2, "name":"alvar"},{"id":3, "name":"Bertil"}];
			//for (var i = 0; i < $scope.customers.length; i++) {
			//	if ($scope.customers[i].name == selected)
			//		$scope.customerModel = $scope.customers[i];
			//};			
		});		
	};	
	$scope.onSelect = function (item, model, label) {

	    $('#sale_customer_id').val(item.id); 
	    for (var i = 0; i < $scope.customer.length; i++) {
	    	if ($scope.customer[i].id == item.id) {
	    		$scope.reference = $scope.customer[i].contacts;
	    	}
	    }
	    //alert(model);
	    //alert($scope.customer[0].contacts[0].name);
	};
	$scope.onSelectRef = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
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
app.controller('saleItemsCtrl', function ($scope) {
	$scope.init = function() {
		//alert(gon.sale.warehouse_id);
		alert("kvant:" + gon.shelves[0].quantity);
		alert("distributör:" + gon.shelves[0].distributor_price);
		alert("slutkund:" + gon.shelves[0].retail_price);
	};
});
app.controller('saleEditCtrl', function ($scope) {

	$scope.approved = new Date();
	
	$scope.dateOptions1 = {
		    'starting-day': 1,
			'show-weeks': false
			};
    	
	$scope.openDate = function($event) {
		  $event.preventDefault();
	      $event.stopPropagation();
	      $scope.isOpen1 = true;
	};

});
