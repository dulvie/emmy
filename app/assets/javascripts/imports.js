app.controller('import_batch_form_ctrl', function ($scope) {

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
	
});