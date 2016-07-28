/*global angular module*/
/*fileService.js*/

XBRLViewerApp.factory('files', ['$q', '$http', function ($q, $http) {

	var apiUrl = '/Database/Files/';

	var getFile = function (guid) {
		return $http({ method: 'GET', url: apiUrl + guid + '.txt' })
	};

	return {
		getFile: getFile
	};

}]);