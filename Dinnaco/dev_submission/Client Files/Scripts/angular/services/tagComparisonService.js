/*global angular module*/
/*tagComparisonService.js*/

XBRLViewerApp.factory('tagComparison', ['$q', '$http', function ($q, $http) {

	var apiUrl = '/Database/TagComparisons.json';

	var getTagComparisons = function () {
		return $http({ method: 'GET', url: apiUrl })
	};

	return {
		getTagComparisons: getTagComparisons,
	};

}]);