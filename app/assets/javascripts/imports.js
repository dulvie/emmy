app.controller('import_batch_form_ctrl', function ($scope, price) {

	$scope.init = function() {
		$scope.supplier = $('#import_batch_supplier').val();
    $('#price_edit').val(price.toDecimal($('#import_batch_price').val()));
    $scope.item_id = $('#import_batch_item_id').val();
    $scope.select_item();
	};

	$scope.select_supplier = function() {
		$('#import_batch_contact_name').val('');
		$('#import_batch_contact_email').val('');
		var supplier_id = $('#import_batch_supplier').val();
		for (x=0; x<gon.suppliers.length; x++) {
			if (supplier_id == gon.suppliers[x].id) {
				var contact_id = gon.suppliers[x].primary_contact_id;
				var contacts = gon.suppliers[x].contacts;
				for (y=0; y<contacts.length; y++) {
					if (contact_id == contacts[y].id) {
						$('#import_batch_contact_name').val(contacts[y].name);
						$('#import_batch_contact_email').val(contacts[y].email);
					}
				}

			}
		}
	};
	$scope.select_item = function() {
	  for (x=0; x < gon.items.length; x++) {
	    if ($scope.item_id == gon.items[x].id) {
	      $('#import_batch_unit').val(gon.items[x].unit.name);
	    }; 
	  };
	};
	$scope.before_submit = function() {
    	$('#import_batch_price').val(price.toInteger($('#price_edit').val()));
	};
	
});
app.controller('import_purchase_form_ctrl', function ($scope, price) {

	$scope.init = function() {
		$scope.supplier = $('#purchase_supplier_id').val();
		$('#price_edit').val(price.toDecimal($('#purchase_purchase_items_attributes_0_price').val()));
	};

	$scope.select_supplier = function() {
		$('#purchase_contact_name').val('');
		$('#purchase_contact_email').val('');
		var supplier_id = $('#purchase_supplier_id').val();
		for (x=0; x<gon.suppliers.length; x++) {
			if (supplier_id == gon.suppliers[x].id) {
				var contact_id = gon.suppliers[x].primary_contact_id;
				var contacts = gon.suppliers[x].contacts;
				for (y=0; y<contacts.length; y++) {
					if (contact_id == contacts[y].id) {
						$('#purchase_contact_name').val(contacts[y].name);
						$('#purchase_contact_email').val(contacts[y].email);
					}
				}

			}
		}
	};
	$scope.before_submit = function() {
    	$('#purchase_purchase_items_attributes_0_price').val(price.toInteger($('#price_edit').val()));
	};
	
});