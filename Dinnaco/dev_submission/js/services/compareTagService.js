/*global angular module*/
/*compareTagService.js*/

angular.module('app').factory('compareTagService', ['$http', function ($http) {

	var apiUrl = 'database/TagComparisons.json';

	var getCompareTagsData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getCompareTagsData: getCompareTagsData
	};

}]);