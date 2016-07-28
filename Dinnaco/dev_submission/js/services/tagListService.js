/*global angular module*/
/*tagListService.js*/
angular.module('app').factory('tagList', ['$q', '$http', function ($q, $http) {

	var apiUrl = 'database/TagLists.json';

	var getAllTagLists = function () {
		return $http({ method: 'GET', url: apiUrl })
	};

	var getTagList = function (fileGuid) {
		return $http({ method: 'GET', url: apiUrl + '?sFileGuid=' + fileGuid })
	};

	return {
		getAllTagLists: getAllTagLists,
		getTagList: getTagList
	};

}]); 