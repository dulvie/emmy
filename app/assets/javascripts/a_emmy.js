var app= angular.module('emmy', ["ui.bootstrap"]);
app.service('price', function() {
	this.toDecimal = function(value) {
	    if (!typeof value === 'number'){ return 0 };
	    return value/100;
	};
	this.toInteger = function(value) {
		var regexp = /^[0-9]+(\.[0-9]{1,2})?$/;
		if (!regexp.test(value)) { return 0 };
		if (value.indexOf('.') === -1) { return value.concat('00') };
		if (value.indexOf('.') == value.length-3) { return value.replace('.','') }
		if (value.indexOf('.') == value.length-2) {
			var v = value.replace('.', '');
			return v.concat('0');
		}
		var v = value.replace('.','');
		return v.concat('00');
	};
});
app.service('ajaxService', function($http, $q) {

	authToken = $("meta[name=\"csrf-token\"]").attr("content")
	$http.defaults.headers.common["X-CSRF-TOKEN"] = authToken

	var server = "/";
	this.get = function(service, parm) {
		var deferred = $q.defer();
		$http({
			url: server + service,
			method: "GET",
			params: parm  })
			.success(function(data, status, headers, config) {
				deferred.resolve(data); })
			.error(function(data, status, headers, config) {
				deferred.reject();  });
		return deferred.promise;
	};
	this.put = function (service, parm) {
		var deferred = $q.defer();
		$http({
			url: server + service,
			method: "PUT",
			data: parm
		}).success(function(data, status, headers, config) {
			deferred.resolve(data);
		}).error(function(data, status, headers, config) {
			deferred.reject(); 
		});
		return deferred.promise;
	};
});
app.directive('ngBlur', ['$parse', function($parse) {
	return function(scope, element, attr) {
		var fn = $parse(attr['ngBlur']);
		element.bind('blur', function(event) {
			scope.$apply(function() {
				fn(scope, {$event:event});
			});
		});
	}
}]);

app.controller('ModalInfoInstanceCtrl', function ($scope, $uibModalInstance, info) {
    $scope.info = info;
    $scope.openDate = function($event) {
        $event.preventDefault();
        $event.stopPropagation();
        $scope.isOpen = true;
    };

    $scope.cancel = function () {
        $uibModalInstance.dismiss('cancel');
    };
});
$(document).on('ready page:load', function(){
	  angular.bootstrap(document.body, ['emmy']);
    Setup.init();
	});
