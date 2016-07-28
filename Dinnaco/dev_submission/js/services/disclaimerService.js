/*global angular module*/
/*disclaimerService.js*/

angular.module('app').factory('disclaimer', ['$http', function ($http) {

	var apiUrl = 'database/disclaimerData.json';

	var getDisclaimer = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getDisclaimer: getDisclaimer
	};

}]);