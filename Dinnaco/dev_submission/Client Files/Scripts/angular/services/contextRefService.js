/*global angular module*/
/*contextRefService.js*/

XBRLViewerApp.factory('contextRef', ['$q', '$http', function ($q, $http) {

	var apiUrl = '/Database/ContextRefs.json';

	var getAllContextRefs = function () {
		return $http({ method: 'GET', url: apiUrl })
	};

	return {
		getAllContextRefs: getAllContextRefs
	};

}]);
