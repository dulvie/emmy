app.controller('import_batch_form_ctrl', function ($scope, price) {

	$scope.init = function() {
		$scope.supplier = $('#import_batch_supplier').val();	
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
	$scope.before_submit = function() {
    	$('#import_batch_price').val(price.toInteger($('#import_batch_price').val()));
	};
	
});
app.controller('import_purchase_form_ctrl', function ($scope, price) {

	$scope.init = function() {
		$scope.supplier = $('#purchase_supplier_id').val();	
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
    	$('#purchase_purchase_items_attributes_0_price').val(price.toInteger($('#purchase_purchase_items_attributes_0_price').val()));
	};
	
});