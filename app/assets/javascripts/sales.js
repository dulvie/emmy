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
		$scope.custref = '';
		$('#sale_contact_name').val(''); 
    $('#sale_contact_email').val(''); 
    $('#sale_contact_telephone').val('');
	    $('#sale_customer_id').val(item.id);
	    for (var i = 0; i < $scope.customer.length; i++) {
	    	if ($scope.customer[i].id == item.id) {
	    		$scope.reference = $scope.customer[i].contacts;
	    		$scope.set_contact($scope.customer[i]);
	    		$('#sale_payment_term').val($scope.customer[i].payment_term);
	    		//$scope.cc = false;
	    	}
	    }
	};

	$scope.set_contact = function(customer) {
	  for (var x = 0; x < customer.contacts.length; x++) {
      if (customer.primary_contact_id == customer.contacts[x].id) {
        $scope.custref = customer.contacts[x].name;
        $('#sale_contact_name').val(customer.contacts[x].name); 
        $('#sale_contact_email').val(customer.contacts[x].email); 
        $('#sale_contact_telephone').val(customer.contacts[x].telephone);
      };
    };
	};

	$scope.type_ahead_customer_reference = function (item, model, label) {
	    $('#sale_contact_name').val(item.name); 
	    $('#sale_contact_email').val(item.email); 
	    $('#sale_contact_telephone').val(item.telephone);
	};

});
