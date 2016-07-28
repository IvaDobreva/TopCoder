app.controller("fAQsPageCtrl",['$scope','$window','$timeout',
	function ($scope,$window,$timeout) {
		$scope.$parent.titlePape = "FAQsPage"; 
		
		$scope.checkHeight = function(){
			$timeout(function(){
				if ($window.innerWidth > 1279) {
					if (angular.element(document.querySelectorAll('.tab-asked-questions'))[0].clientHeight < ($window.innerHeight -213)) {
						angular.element(document.querySelectorAll('.main-content')).css('height',$window.innerHeight -213 + "px");
					}else{
						angular.element(document.querySelectorAll('.main-content')).css('height',"auto");
					}
				}else{
					if (angular.element(document.querySelectorAll('.tab-asked-questions'))[0].clientHeight < ($window.innerHeight -150)) {
						angular.element(document.querySelectorAll('.main-content')).css('height',$window.innerHeight -150 + "px");
					}else{
						angular.element(document.querySelectorAll('.main-content')).css('height',"auto");
					}
				}
			}, 100);
		}

		$scope.checkHeight();
	}
]);