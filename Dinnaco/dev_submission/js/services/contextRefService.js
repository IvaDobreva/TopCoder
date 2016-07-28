/*global angular module*/
/*contextRefService.js*/
angular.module('app').factory('contextRef', ['$q', '$http', function ($q, $http) {

	var apiUrl = 'database/ContextRefs.json';

	var getAllContextRefs = function () {
		return $http({ method: 'GET', url: apiUrl })
	};

	return {
		getAllContextRefs: getAllContextRefs
	};

}]);
