var app= angular.module('emmy', []);
app.service('ajaxService', function($http, $q) {

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
});
$(document).on('ready page:load', function(){
	  angular.bootstrap(document.body, ['emmy']);
	});