/*global angular module*/
/*dropdownService.js*/

angular.module('app').factory('dropdownService', ['$http', function ($http) {

	var apiUrl = 'database/DropdownData.json';

	var getDropdownData = function () {
		return $http({ method: 'GET', url: apiUrl });
	};

	return {
		getDropdownData: getDropdownData
	};

}]);