/*global angular module*/
/*tagComparisonService.js*/
angular.module('app').factory('tagComparison', ['$q', '$http', function ($q, $http) {

	var apiUrl = 'database/TagComparisons.json';

	var getTagComparisons = function () {
		return $http({ method: 'GET', url: apiUrl })
	};

	return {
		getTagComparisons: getTagComparisons,
	};

}]);