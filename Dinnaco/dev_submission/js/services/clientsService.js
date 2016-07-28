/*global angular module*/
/*clientsService.js*/

angular.module('app').factory('clients', ['$http', function ($http) {

	var apiUrl = 'database/ClientYears.json';

	var getClientYears = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getClientYears: getClientYears
	};

}]);