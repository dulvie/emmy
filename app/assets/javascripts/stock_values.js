app.controller('stock_value_form_ctrl', function ($scope){

	$scope.init = function() {
		var v = $('#in_value_date').val().split(/\D/);
		v.length == 1 ? $scope.v_date = new Date() : $scope.v_date = new Date(v[0], --v[1], v[2]);
		$scope.max_date = new Date();
	};

	$scope.v_options = {'starting-day': 1,'show-weeks': false};
	$scope.open_v_date = function($event) {
		$event.preventDefault();
		$event.stopPropagation();
		$scope.v_open = true;
	};

});