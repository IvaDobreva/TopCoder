/*global angular module*/
/*clientsService.js*/

XBRLViewerApp.factory('clients', ['$http', function ($http) {

	var apiUrl = '/Database/ClientYears.json';

	var getClientYears = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getClientYears: getClientYears
	};

}]);