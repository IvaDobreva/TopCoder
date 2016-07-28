app.controller("queryStatusPageCtrl",['$scope','$window','$timeout', 'queryStatusService',
	function ($scope,$window,$timeout,queryStatusService) {
		$scope.$parent.titlePape = "QueryStatusPage"; 

		var browserHeight = $window.innerHeight - 396;
		$scope.setHeightForLeftAside = function(){
			if ($window.innerWidth > 1279) {
				$timeout(function(){
					var heightRightContent = angular.element(document.querySelectorAll('.page-document .body-page .right'))[0].clientHeight;
					if ( heightRightContent < browserHeight) {
						angular.element(document.querySelectorAll('.page-document .querystatuspage.main-content-side')).css('height',browserHeight +"px");
					}else{
						angular.element(document.querySelectorAll('.page-document .querystatuspage.main-content-side')).css('height',heightRightContent -24 + "px");
					}
				}, 10);
			}
		}

		$scope.setHeightForClickExpandLeft = function(){
			if ($window.innerWidth > 1279) {
				$timeout(function(){
					var heightRightContent = angular.element(document.querySelectorAll('.page-document .body-page .right'))[0].clientHeight;
					if (angular.element(document.querySelectorAll('.querystatuspage.main-content-side .list-side'))[0].clientHeight > heightRightContent) {
						angular.element(document.querySelectorAll('.querystatuspage.main-content-side')).css('height',"auto");
					}else{
						$scope.setHeightForLeftAside();
					}
				}, 10);
			}
			
		}

		$scope.setHeightForLeftAside();
		$scope.clickQueriesChatItem = function(chatItem){
			$scope.goDocummentDetailPage();
			chatItem.isSelected = true;
		}

		$scope.filterQueries = function (q) {
			var status = $scope.ddSelectSelectedAllQueries.text;

			var statusRes = (status === 'All Queries') ? true: status === q.Status;

			return (q.Comment || '').indexOf($scope.queryFilter || '') > -1 && statusRes;
		}

		$scope.addQuery = function() {
			var content = $scope.queryContent;
			if (content) {
				var newQuery ={
					Comment: content,
					Date: $scope.getTimeNow(),
					Name: 'Jane Doe',
					Status: 'Open',
					Reply: []
				}
				$scope.entitySelected.QueriesGroup[0].Queries.push(newQuery)
				$scope.entitySelected.QueriesGroup[0].isExpand = true;
				$scope.queryContent = '';

				queryStatusService.addNewQuery($scope.queryStatusData);


			}
		}

		$scope.toggleReply = function ($event) {
			angular.element($event.currentTarget).parent().toggleClass('show-reply');
		}


		$scope.addReply = function(groupIndex, queryIndex, $event) {

			var content = angular.element($event.currentTarget).siblings().val();
			angular.element($event.currentTarget).parent().siblings('.when-realy').addClass('show-reply');
			if (content) {
				var newReply = {
					Comment: content,
					Date: $scope.getTimeNow(),
					Name: 'Jane Doe',
				};
				$scope.entitySelected.QueriesGroup[groupIndex].Queries[queryIndex].Reply.push(newReply);

				angular.element($event.currentTarget).siblings().val('');

				queryStatusService.addNewQuery($scope.queryStatusData);


			}
		}

		$scope.toggleReplyInput = function ($event) {
			angular.element($event.currentTarget).siblings('.reply').toggleClass('show');
		}
		
	}
]);