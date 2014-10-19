app.controller('sales_new_ctrl', function ($scope, ajaxService) {

	$scope.customers = [];
	$scope.selected = undefined;
	$scope.reference = [];
	$scope.cc = true;
	$scope.init = function(url) {
		ajaxService.get(url+"customers.json", "").then(function(data) {
			var customer = data.customers;
			$scope.customer = customer;
			$scope.set_ref();
		});
	};
	$scope.set_ref = function() {
		var cid = $('#sale_customer_id').val();
		if (cid != '') {			
			for (var i = 0; i < $scope.customer.length; i++) {
				if ($scope.customer[i].id == cid) {
					$scope.selected = $scope.customer[i].name;
				}
			}
		}
	};
	$scope.type_ahead_customer = function (item, model, label) {
		$scope.cc = false;
	    $('#sale_customer_id').val(item.id);
	    for (var i = 0; i < $scope.customer.length; i++) {
	    	if ($scope.customer[i].id == item.id) {
	    		$scope.reference = $scope.customer[i].contacts;
	    		$('#sale_payment_term').val($scope.customer[i].payment_term);
	    		//$scope.cc = false;
	    	}
	    }
	};

	$scope.type_ahead_customer_reference = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
	    $('#sale_contact_telephone').val(item.telephone);
	};

});

app.controller('sale_items_new_ctrl', function ($scope, $modal, price) {

	$scope.quantity = $('#sale_item_quantity').val();
	$scope.init = function() {
		$scope.product_value = gon.products[0].value;
		$.each(gon.products, function(i, obj) {
			if (obj.selected == true) {
				$scope.product_value = obj.value;
			}
		});
		$('#sale_item_price').val(price.toDecimal($('#sale_item_price').val()));
		if ($('#sale_item_price').val()=='0') {
			$scope.product_changed();
		}
	};
	$scope.radio_product = function() {
		$scope.product_changed();
	};
	$scope.product_changed = function() {
		if ($("input[name='sale_item[row_type]']:checked").val()=='text') {
			return;
		};
		var dPrice = 0;
		var rPrice = 0;
		$('#sale_item_price').val(0);
		var reseller = $('#sale_customer_reseller').is(":checked");
		for (var x=0; x < gon.products.length; x++) {
			if (gon.products[x].value == $scope.product_value) {
				dPrice = gon.products[x].distributor_price;
				rPrice = gon.products[x].retail_price;
			};

			if (reseller) {
				$('#sale_item_price').val(price.toDecimal(dPrice));
			}
			else  {
				$('#sale_item_price').val(price.toDecimal(rPrice));
			};
		}
	};

	$scope.select_quantity = function(event) {

		if ($("input[name='sale_item[row_type]']:checked").val()=='text') {
			return;
		};
		for (i=0; i< gon.products.length; i++) {
			if (gon.products[i].value == $scope.product_value) {
				if ($scope.quantity > gon.products[i].available_quantity) {
					//$scope.quantity = gon.products[i].available_quantity;
					var msg = "Kvantitet överstiger lagrets " + gon.products[i].available_quantity
					$scope.open_message('sm', 'messageContent', msg);
					$scope.quantity = gon.products[i].available_quantity;
					//$scope.open_message = function ($event, size, el, msg)
					//alert("Kvantitet överstiger lagrets " + gon.products[i].available_quantity);
				}
			}
		}
	};
	
	$scope.before_submit = function() {
    	$('#sale_item_price').val(price.toInteger($('#sale_item_price').val()));
  	};
  	
  	
	$scope.open_message = function (size, el, msg) {
		$scope.message = msg;
		var elem = '#'+el;
		var temp = $(elem).html();
		var modalInstance = $modal.open({
			template: temp,
			controller: 'ModalMessageInstanceCtrl',
			size: size,
			resolve: {
				msg: function () {
					return $scope.message;
				}
			}
		});
		modalInstance.result.then(function (selectedItem) {
			$scope.selected = selectedItem;
		}, function () {
			//$log.info('Modal dismissed at: ' + new Date());
		});
		//$event.preventDefault();
		//$event.stopPropagation();
	};
	
	
});
