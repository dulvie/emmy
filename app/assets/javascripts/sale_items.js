app.controller('sale_items_new_ctrl', function ($scope, $modal, price) {
  var product = {};
	$scope.quantity = $('#sale_item_quantity').val();

	$scope.init = function() {
		$scope.product_value = gon.products[0].value;
		$.each(gon.products, function(i, obj) {
			if (obj.selected == true) {
				$scope.product_value = obj.value;
			}
		});
		$('#price_edit').val(price.toDecimal($('#sale_item_price').val()));
		if ($('#price_edit').val()=='0') {
			$scope.product_changed();
		}
	};

  $scope.radio_text = function() {
      $scope.text_vat = 0;
      $('#price_edit').val(0);
      $scope.price_with_vat = 0;
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
			  product = gon.products[x];
				dPrice = gon.products[x].distributor_price;
				rPrice = gon.products[x].retail_price;
				dPriceVat= gon.products[x].distributor_inc_vat;
				rPriceVat= gon.products[x].retail_inc_vat;
			};

			if (reseller) {
				$('#price_edit').val(price.toDecimal(dPrice));
				$scope.price_with_vat = dPriceVat;
			}
			else  {
				$('#price_edit').val(price.toDecimal(rPrice));
				$scope.price_with_vat = rPriceVat;
			};
		}
	};

	$scope.select_quantity = function(event) {

		if ($("input[name='sale_item[row_type]']:checked").val()=='text') {
			return;
		};
		for (i=0; i< gon.products.length; i++) {
			if (gon.products[i].value == $scope.product_value) {
				if (gon.products[i].stocked && $scope.quantity > gon.products[i].available_quantity) {
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

	$scope.text_vat_price = function() {
	  $scope.calc_vat_price();
	}

	$scope.calc_vat_price = function() {
	  var price = Number($('#price_edit').val());
	  var moms = 0;
	  if ($("input[name='sale_item[row_type]']:checked").val()=='text') {
	    moms = Number(price * Number($('#sale_item_vat').val()) / 100);
    } else {
      moms = Number(price * product.vat_add_factor);
    };
    var ink_moms = (price + moms).toFixed(2);
    $scope.price_with_vat = ink_moms;
  };

	$scope.before_submit = function() {
    	$('#sale_item_price').val(price.toInteger($('#price_edit').val()));
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
		});
	};

});
