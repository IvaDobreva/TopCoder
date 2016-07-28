/*global angular module*/
/*fAQsService.js*/

angular.module('app').factory('fAQsService', ['$http', function ($http) {

	var apiUrl = 'database/FAQsData.json';

	var getFAQsData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getFAQsData: getFAQsData
	};

}]);