/*global angular module*/
/*dashboardController.js*/

XBRLViewerApp.controller("dashboardController",
['$scope', 'clients', 'entities', 'tagList', 'contextRef', 'tagComparison', 'files', '$sce',
function ($scope, clients, entities, tagList, contextRef, tagComparison, files, $sce) {

	$scope.init = function () {
		$scope.initVariables();
	};

	$scope.initVariables = function () {

		$scope.clientYearDetails = [];
		$scope.clientYear = [];
		$scope.entityDetails = [];
		$scope.entity = [];
		$scope.allTagLists = [];
		$scope.tagList = [];
		$scope.allContextRefs = [];
		$scope.contextRef = [];
		$scope.tagComparisons = [];
		$scope.tagComparison = [];
		$scope.file = [];
	};

	$scope.getClientYears = function () {
		var promise = clients.getClientYears();

		promise.then(function (values) {
			$scope.clientYearDetails = values.data;
			$scope.clientYearsCount = $scope.clientYearDetails.length;
		},
		function (error) {
			var errorMessage = 'Error loading entities...';
		});
	};


	$scope.getClientYear = function () {
		var promise = clients.getClientYears();

		promise.then(function (values) {
			var clientYearDetails = values.data;
			$scope.clientYear = clientYearDetails.filter(customFilter({ 'Year': 2014 }));
			$scope.clientYearCount = $scope.clientYear.length;
		},
		function (error) {
			var errorMessage = 'Error loading entities...';
		});
	};


	$scope.getEntities = function () {
		var promise = entities.getEntities();

		promise.then(function (values) {
			$scope.entityDetails = values.data;
			$scope.entityCount = $scope.entityDetails.length;
		},
		function (error) {
			var errorMessage = 'Error loading entities...';
		});	
	};


	$scope.getEntity = function () {
		var promise = entities.getEntities();

		promise.then(function (values) {
			var entityDetails = values.data;
			$scope.entity = entityDetails.filter(customFilter({ 'EntityId': 60608 }));
			$scope.entitySingleCount = $scope.entity.length;
		},
		function (error) {
			var errorMessage = 'Error loading entities...';
		});
	};
	

	$scope.GetTagComparisons = function () {
		var promise = tagComparison.getTagComparisons();

		promise.then(function (values) {
			$scope.tagComparisons = values.data;
			$scope.tagComparisonsCount = $scope.tagComparisons.length;
		},
		function (error) {
			var errorMessage = 'Error loading tag lists...';
		});
	};


	$scope.GetFile = function () {
		var promise = files.getFile('10529355-11FB-4124-808C-7B5EFE0FF78F');

		promise.then(function (value) {
			$scope.file =  $sce.trustAsHtml(value.data);
			$scope.fileCount = 1;
		},
		function (error) {
			var errorMessage = 'Error loading tag lists...';
		});
	};
	

	$scope.GetTagComparison = function () {
		var promise = tagComparison.getTagComparisons();

		promise.then(function (values) {
			var tagComparisons = values.data;
			$scope.tagComparison = tagComparisons.filter(customFilter({ 'FileGuid': '10529355-11FB-4124-808C-7B5EFE0FF78F'.toLowerCase() }));
			$scope.tagComparisonCount = $scope.tagComparison.length;
		},
		function (error) {
			var errorMessage = 'Error loading tag lists...';
		});
	};


	$scope.GetAllTagLists = function () {
		var promise = tagList.getAllTagLists();

		promise.then(function (values) {
			$scope.allTagLists = values.data;
			$scope.tagListsCount = $scope.allTagLists.length;
		},
		function (error) {
			var errorMessage = 'Error loading tag lists...';
		});
	};

	$scope.GetTagList = function () {
		var promise = tagList.getAllTagLists();

		promise.then(function (values) {
			var allTagLists = values.data;
			$scope.tagList = allTagLists.filter(customFilter({ 'FileGUID': '10529355-11FB-4124-808C-7B5EFE0FF78F'.toLowerCase() }));
			$scope.tagListCount = $scope.tagList.length;
		},
		function (error) {
			var errorMessage = 'Error loading tag lists...';
		});
	};


	$scope.GetAllContextRefs = function () {
		var promise = contextRef.getAllContextRefs();

		promise.then(function (values) {
			$scope.allContextRefs = values.data;
			$scope.contextRefsCount = $scope.allContextRefs.length;
		},
		function (error) {
			var errorMessage = 'Error loading context refs...';
		});
	};

	$scope.GetContextRef = function () {
		var promise = contextRef.getAllContextRefs();

		promise.then(function (values) {
			var contextRefs = values.data;
			$scope.contextRef = contextRefs.filter(customFilter({ 'FileGuid': '10529355-11FB-4124-808C-7B5EFE0FF78F'.toLowerCase() }));
			$scope.contextRefCount = $scope.contextRef.length;
		},
		function (error) {
			var errorMessage = 'Error loading context refs...';
		});
	};

	//Pass in an array of values to filter by
	function customFilter(values) {
		return function (r) {
			var keys = Object.keys(values);
			var answer = true;
			for (var i = 0, len = keys.length; i < len; i++) {
				if (r[keys[i]] !== values[keys[i]]) {
					answer = false;
					break;
				}
			}
			return answer;
		}
	}

	$scope.init();

}]);
