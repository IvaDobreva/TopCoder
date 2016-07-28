/*global angular module*/
/*fileService.js*/
angular.module('app').factory('files', ['$q', '$http', function ($q, $http) {

	var apiUrl = 'database/Files/';

	var getFile = function (guid, type) {
		return $http({ method: 'GET', url: apiUrl + guid + '.' + type + '.zip' })
	};

	var getiXBRLFile = function (guid) {
		return $http({ method: 'GET', url: apiUrl + guid.toUpperCase() + '.txt' })
	}

	return {
		getFile: getFile,
		getiXBRLFile: getiXBRLFile
	};

}]);