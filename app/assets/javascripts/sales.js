// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

app.controller('salesNewCtrl', function ($scope, ajaxService) {
	$scope.customers = [];
	$scope.selected = undefined;
	$scope.isOpen1 = false;
	$scope.reference = [];
	
	$scope.initSales = function() {
		ajaxService.get("customers.json", "").then(function(data) {
			var customer = data.customers;
			$scope.customer = customer;
		});		
	};

	$scope.onSelect = function (item, model, label) {
	    $('#sale_customer_id').val(item.id); 
	    for (var i = 0; i < $scope.customer.length; i++) {
	    	if ($scope.customer[i].id == item.id) {
	    		$scope.reference = $scope.customer[i].contacts;
	    	}
	    }
	};

	$scope.onSelectRef = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
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
});

app.controller('saleItemsCtrl', function ($scope) {
	$scope.initSalesItem = function() {
		//alert("kvant:" + gon.shelves[0].quantity);
		//alert("nu ska priset komma");
		alert("distributör:" + gon.shelves[0].distributor_price);
		//alert("slutkund:" + gon.shelves[0].retail_price);
	};

	
	$scope.selectProduct = function() {

		var dPrice = 0;
		var rPrice = 0;
		var reseller = $('#sale_customer_reseller').is(":checked");
		for (i=0; i< gon.shelves.length; i++) {
			if (gon.shelves[i].id == $scope.productId) {
				dPrice = gon.shelves[i].distributor_price;
				rPrice = gon.shelves[i].retail_price;
			}
		};
		//$scope.togg = false;
		if (reseller) {
			$('#sale_item_price').val(dPrice);
		}
		else  {
			$('#sale_item_price').val(rPrice);
		}
		
	};

	$scope.selectQuantity = function() {
		var qty = 0;
		for (i=0; i< gon.shelves.length; i++) {
			if (gon.shelves[i].id == $scope.productId) {
				if ($scope.quantity > gon.shelves[i].quantity)
					alert("Kvantitet överstiger lagrets " + gon.shelves[i].quantity);
			}
		}
	}
});
app.controller('stateModalCtrl', function ($scope) {
	$scope.dt = new Date();
	$scope.minDate = new Date();
});
app.controller('saleEditCtrl', function ($scope) {
	
	$scope.togg = false;
	$scope.dt = new Date();
	$scope.type = "next";
	
	$scope.openDate = function($event, btn) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.togg = true;
		$scope.type = btn;
	}
	$scope.approved = new Date();

});
