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
	    		$('#sale_payment_term').val($scope.customer[i].payment_term);
	    	}
	    }
	};

	$scope.type_ahead_customer_reference = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
	};

});

app.controller('sale_items_new_ctrl', function ($scope) {
	$scope.batch = {};
	$scope.options = {};
	$scope.show_batch = false;
	
	var bch_id = $('#sale_item_batch_id').val();
	var item_id = $('#sale_item_item_id').val();

	$scope.item_id = item_id;
	$scope.batch.id = bch_id;

	$scope.init = function() {
		$scope.item_changed();
	};

	$scope.item_changed = function() {
		$scope.show_batch = false;
		$scope.batch.id = 0;
		for (var x=0; x < gon.items.length; x++) {
			if ($scope.item_id == gon.items[x].id) {
				$scope.options = gon.items[x].batches;
				if (gon.items[x].stocked == true) {
					$scope.show_batch = true;
				}
				//$('#sales_item_price').val(gon.items[x].in_price);
				if (typeof($scope.options[0]) != "undefined") {
					$scope.batch.id = $scope.options[0].id;					
				}
				$scope.select_batch();
			}
		}
	}

	$scope.select_batch = function() {
		var dPrice = 0;		
		var rPrice = 0;
		$('#sale_item_price').val(0);
		var reseller = $('#sale_customer_reseller').is(":checked");
		for (i=0; i< $scope.options.length; i++) {
			if ($scope.options[i].id == $scope.batch.id) {
				dPrice = $scope.options[i].distributor_price;
				rPrice = $scope.options[i].retail_price;
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
		for (i=0; i< gon.shelves.length; i++) {
			if (gon.shelves[i].batch_id == $scope.batch.id) {
				if ($scope.quantity > gon.shelves[i].quantity)
					alert("Kvantitet överstiger lagrets " + gon.shelves[i].quantity);
			}
		}
	}
});
