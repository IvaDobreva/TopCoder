/*global angular module*/
/*dashBoardService.js*/

angular.module('app').factory('dashBoardService', ['$http', function ($http) {

	var apiUrl = 'database/DashBoard.json';

	var getdashBoardData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getdashBoardData: getdashBoardData
	};

}]);