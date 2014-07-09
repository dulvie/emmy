var app= angular.module('emmy', ["ui.bootstrap"]);
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
$(document).on('ready page:load', function(){
	  angular.bootstrap(document.body, ['emmy']);
    Setup.init();
	});
