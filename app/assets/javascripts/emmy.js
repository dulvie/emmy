var app= angular.module('emmy', []);
app.service('ajaxService', function($http, $q) {

	var server = "http://192.168.56.2:5000/";
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
	this.gett = function(service, parm) {
		//alert(service + parm);
		var x = [{'name':'ett','id':'1'},{'name':'two','id':'2'}];
		return x;
	}
});
$(document).on('ready page:load', function(){
	  angular.bootstrap(document.body, ['emmy']);
	});