/*global angular module*/
/*entitiesService.js*/
angular.module('app').factory('entities', ['$q', '$http', function ($q, $http) {

	var apiUrl = 'database/EntityDetails.json';

	var getEntities = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getEntities: getEntities
	};
		
}]);