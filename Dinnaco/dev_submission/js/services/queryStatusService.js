/*global angular module*/
/*queryStatusService.js*/

angular.module('app').factory('queryStatusService', ['$http', '$q',function ($http, $q) {

	var apiUrl = 'database/queryStatusData.json';

	var getQueryStatusData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	var addNewQuery = function (data) {
		var newQuery = {
			data: data
		}
		return $q(function (resolve,reject) {
			localStorage.setItem('newQuery',angular.toJson(newQuery))
			resolve();
		});
	};

	var queryNewQuery = function () {
		return $q(function(resolve, reject){
			resolve(angular.fromJson(localStorage.getItem('newQuery')));
		});
	};

	return {
		getQueryStatusData: getQueryStatusData,
		queryNewQuery: queryNewQuery,
		addNewQuery: addNewQuery
	};

}]);