/*global angular module*/
/*entitiesService.js*/

XBRLViewerApp.factory('entities', ['$q', '$http', function ($q, $http) {

	var apiUrl = '/Database/EntityDetails.json';

	var getEntities = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getEntities: getEntities
	};
		
}]);