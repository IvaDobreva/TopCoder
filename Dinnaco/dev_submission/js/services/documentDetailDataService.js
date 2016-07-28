/*global angular module*/
/*documentDetailDataService.js*/

angular.module('app').factory('documentDetailDataService', ['$http', function ($http) {

	var apiUrl = 'database/DocumentDetailData.json';

	var getDocumentDetailData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getDocumentDetailData: getDocumentDetailData
	};

}]);