app.controller('purchase_form_ctrl', function ($scope) {

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
	
});