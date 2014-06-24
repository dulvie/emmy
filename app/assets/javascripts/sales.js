// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
app.controller('date_ctrl', function ($scope) {
  $scope.dpOptions = {
    'starting-day': 1,
    'show-weeks': false
  };
  $scope.openDp = function($event) {
    $event.preventDefault();
    $event.stopPropagation();
    $scope.isDpOpen = true;
  };
  $scope.openDateForm = function($event) {
	$scope.date = new Date();  
	$event.preventDefault();  
    $event.stopPropagation();  
  };
});

app.controller('sales_new_ctrl', function ($scope, ajaxService) {

	$scope.customers = [];
	$scope.selected = undefined;
	$scope.isOpen1 = false;
	$scope.reference = [];

	$scope.init = function() {
		ajaxService.get("customers.json", "").then(function(data) {
			var customer = data.customers;
			$scope.customer = customer;
		});		
	};

	$scope.type_ahead_customer = function (item, model, label) {		
	    $('#sale_customer_id').val(item.id); 
	    for (var i = 0; i < $scope.customer.length; i++) {
	    	if ($scope.customer[i].id == item.id) {
	    		$scope.reference = $scope.customer[i].contacts;
	    	}
	    }
	};

	$scope.type_ahead_customer_reference = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
	};

});

app.controller('sale_items_new_ctrl', function ($scope) {
	$scope.init = function() {
	};

	$scope.select_product = function() {

		var dPrice = 0;
		var rPrice = 0;
		var reseller = $('#sale_customer_reseller').is(":checked");
		for (i=0; i< gon.shelves.length; i++) {
			if (gon.shelves[i].id == $scope.productId) {
				dPrice = gon.shelves[i].distributor_price;
				rPrice = gon.shelves[i].retail_price;
			}
		};

		if (reseller) {
			$('#sale_item_price').val(dPrice);
		}
		else  {
			$('#sale_item_price').val(rPrice);
		}
	};

	$scope.select_quantity = function() {
		var qty = 0;
		for (i=0; i< gon.shelves.length; i++) {
			if (gon.shelves[i].id == $scope.product_id) {
				if ($scope.quantity > gon.shelves[i].quantity)
					alert("Kvantitet överstiger lagrets " + gon.shelves[i].quantity);
			}
		}
	}
});
