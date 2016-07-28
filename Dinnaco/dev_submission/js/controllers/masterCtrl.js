app.controller("masterCtrl",['$scope','$location','$window','dashBoardService','fAQsService','dropdownService','compareTagService','queryStatusService','documentDetailDataService','entities','$filter','$sce', 'contextRef', 'disclaimer' ,
	function ($scope,$location,$window,dashBoardService,fAQsService,dropdownService,compareTagService,queryStatusService,documentDetailDataService,entities,$filter,$sce,contextRef,disclaimer) {

		$scope.initVariables = function () {

			$scope.dashBoardDataTable=[];
			$scope.fAQsData =[];
			$scope.disclaimerdataItem =[];

			//data for Dashboard Compare Popup 
			$scope.compareTagsData=[];
			$scope.entityDetails=[];

			//data for QueryStatus 
			$scope.queryStatusData = [];
			$scope.entitySelected = [];

			//data document Detail
			$scope.documentDetailData=[];
			$scope.arraySelectColumn=[];

			//data dropdown json
			$scope.ddSelectOptionsSortBy = [];
			$scope.ddSelectSelectedSortBy = {
				"text": "Sort by"
			};

			$scope.ddSelectOptionsFilterBy = [];
			$scope.ddSelectSelectedFilterBy = {
				"text": "Filter by"
			};

			$scope.ddSelectOptionsCompareTags = [];
			$scope.ddSelectSelectedCompareTags = {
				"text": "All"
			};

			$scope.ddSelectOptionsPerPage = [];
			$scope.ddSelectSelectedPerPage = {
				"text": "10"
			};

			$scope.ddSelectOptionsAllQueries = [];
			$scope.ddSelectSelectedAllQueries = {
				"text": "All Queries"
			};

			$scope.ddSelectOptionsHDN = [];
			$scope.ddSelectSelectedHDN = {
				"text": " "
			};

			$scope.ddSelectOptionsCat = [];
			$scope.ddSelectSelectedCat = {
				"text": " "
			};

			$scope.ddSelectOptionsUnits = [];
			$scope.ddSelectSelectedUnits = {
				"text": " "
			};

			$scope.isShowPopupDisclaimer = false;


			$scope.lastThreeYears = $scope.lastThreeYears || [];

			$scope.ddCompareSelects = [
				{
					"text": "=",
					"value": 0
				}, 
				{
					"text": ">",
					"value": 1
				}, 
				{
					"text": "<",
					"value": 2
				}
			];
			$scope.ddCompareSelected = {
				"text": "="
			};

			// the current fileGUID for document detail
			$scope.currentFileGUID = ''; 


			$scope.allContextRefs = [];
			$scope.colorCodes = [];
			$scope.contextRef = [];

			$scope.isShowGridVer = false;


		};

		$scope.initVariables();

		//get queryStatus Json 
		$scope.totalQueries =0;
		$scope.openQueries =0;
		$scope.closeQueries=0;
		$scope.getTotalQueries = function(){
			$scope.totalQueries =0;
			$scope.openQueries =0;
			$scope.closeQueries=0;
			for (var i = 0; i < $scope.entitySelected.QueriesGroup.length; i++) {

				$scope.totalQueries+= $scope.entitySelected.QueriesGroup[i].Queries.length;

				for (var j = 0; j < $scope.entitySelected.QueriesGroup[i].Queries.length; j++) {
					if ($scope.entitySelected.QueriesGroup[i].Queries[j].Status === "Open") {
						$scope.openQueries+=1;
					}else{
						$scope.closeQueries+=1;
					}
				}
			}
		}

		//get document Detail Json
		documentDetailDataService.getDocumentDetailData().then(function (values) {
			values.data.Contents.Data[0].isExpand = true;
			values.data.Attribute[0].isCheck = true;
			$scope.documentDetailData = values.data;
			$scope.arraySelectColumn = angular.copy(values.data.SelectColumns);
		},
		function (error) {
			var errorMessage = 'Error loading...';
		});

		//click Apply Data
		$scope.applyDataColumnSelect = function(){
			$scope.arraySelectColumn =[];
			$scope.arraySelectColumn = angular.copy($scope.documentDetailData.SelectColumns);
		}


		queryStatusService.getQueryStatusData().then(function (values) {
						//get query Status Json
			queryStatusService.queryNewQuery().then(function (newQuery) {
				if (newQuery && newQuery.data && newQuery.data.length > 0) { // use values from local storage
					newQuery.data[1].isExpand = true;
					newQuery.data[1].DataEntity[1].isSelected = true;
					newQuery.data[1].DataEntity[1].QueriesGroup[1].isExpand = true;
					$scope.queryStatusData = newQuery.data;
					$scope.entitySelected = newQuery.data[1].DataEntity[1];
				} else {
					values.data[1].isExpand = true;
					values.data[1].DataEntity[1].isSelected = true;
					values.data[1].DataEntity[1].QueriesGroup[1].isExpand = true;
					$scope.queryStatusData = values.data;
					$scope.entitySelected = values.data[1].DataEntity[1];
				}
			});
		

			// $scope.getTotalQueries();
		},
		function (error) {
			var errorMessage = 'Error loading...';
		});


		//get compareTag Json DashBoard 
		compareTagService.getCompareTagsData().then(function (values) {
			$scope.compareTagsData = values.data;
			for (var i = 0; i < $scope.compareTagsData.length; i++) {
				$scope.compareTagsData[i].isCheck = true;
			}
		},
		function (error) {
			var errorMessage = 'Error loading...';
		});
		
		//get Data Json DashBoard 
		entities.getEntities().then(function (values) {
			var companies = values.data.map(function (e) {
				return e.CompanyName;
			}).filter(function (e, i, self) {
				return i === self.indexOf(e);
			});

			var dashBoardData = [];

			companies.forEach(function (e, i) {
				var item = {};
				item.ClientName = e;
				item.Id = i;
				item.Entities = [].concat(values.data.filter(function (e) {
					return e.CompanyName === item.ClientName;
				}));

				item.TotalOpenQueries = item.Entities.reduce(function (a, b) {
					return a + b.OpenQueries;
				}, 0);				
				item.TotalQueries = item.Entities.reduce(function (a, b) {
					return a + b.Queries;
				}, 0);				
				item.TotalETR = item.Entities.reduce(function (a, b) {
					return a + b.ETR;
				}, 0);				
				item.TotalDebtorDays = item.Entities.reduce(function (a, b) {
					return a + b.DebtorDays;
				}, 0);				
				item.TotalROCE = item.Entities.reduce(function (a, b) {
					return a + b.ROCE;
				}, 0);
				item.OpenQueries = item.Entities[item.Entities.length - 1].OpenQueries;				
				item.Queries = item.Entities[item.Entities.length - 1].Queries;				
				item.ETR = item.Entities[item.Entities.length - 1].ETR;				
				item.DebtorDays = item.Entities[item.Entities.length - 1].DebtorDays;				
				item.ROCE = item.Entities[item.Entities.length - 1].ROCE;
				item.Year = item.Entities[item.Entities.length - 1].Year;
				item.NumberOfDocuments = item.Entities.length;
				dashBoardData.push(item);		
			});
			dashBoardData.forEach(function(e){
				e.Entities.sort(function (a, b) {
					return b.Year - a.Year;
				})
			})
			$scope.dashBoardDataTable = dashBoardData;
		},
		function (error) {
			var errorMessage = 'Error loading...';
		});

		//get faq data
		fAQsService.getFAQsData().then(function (values) {
			$scope.fAQsData = values.data;
		},
		function (error) {
			var errorMessage = 'Error loading...';
		});

		//get disclaimer
		disclaimer.getDisclaimer().then(function (values) {
			$scope.disclaimerdataItem = values.data;
		},
		function (error) {
			var errorMessage = 'Error loading disclaimer...';
		});



		// load contextrefs 
		contextRef.getAllContextRefs().then(function (values) {
			$scope.allContextRefs = values.data;
			$scope.generateUniqueDatesColors();
		},
		function (error) {
			var errorMessage = 'Error loading context refs...';
		});




		//update data Dashboard item when remove tag compare
		$scope.removeCheckItemDashBoardTable = function(id){
			for (var i = 0; i < $scope.dashBoardDataTable.length; i++) {
				if ($scope.dashBoardDataTable[i].Id === id) {
					$scope.dashBoardDataTable[i].isCheck = false;
					return;
				}
			}
		}

		//set Entity Selected
		$scope.setEntitySelected = function(entity){
			for (var i = 0; i < $scope.queryStatusData.length; i++) {
				for (var j = 0; j < $scope.queryStatusData[i].DataEntity.length; j++) {
					$scope.queryStatusData[i].DataEntity[j].isSelected = false;
				}
			}
			entity.isSelected = true;
			$scope.entitySelected = entity;
		}

		//control header template

		$scope.titlePape = "DashBoardPage";
		$scope.goDashBoard = function(){
			$location.path('/DashBoardPage');
			$scope.titlePape = "DashBoardPage"; 
		}

		$scope.goDocummentDetailPage = function(entityId, fileGUID){
			$scope.currentFileGUID = fileGUID;
			$scope.currentEntityId = entityId;
			sessionStorage.setItem('currentFileGUID',fileGUID);
			sessionStorage.setItem('currentEntityId',entityId);
			$location.path('/DocummentDetailPage');
			$scope.titlePape = "DashBoardPage";
		}

		$scope.goQueryStatusPage = function(){
			$location.path('/QueryStatusPage');
			$scope.titlePape = "QueryStatusPage";
		}

		$scope.goFAQsPage = function(){
			$location.path('/FAQsPage');
			$scope.titlePape = "FAQsPage";
		}

		$scope.goBack = function(){
			$window.history.back();
		}

		//Dropdown for data
		dropdownService.getDropdownData().then(function (values) {
			$scope.ddSelectOptionsSortBy = values.data.sortByDashBoard;
			$scope.ddSelectOptionsFilterBy = values.data.filterByDashBoard;
			$scope.ddSelectOptionsCompareTags = values.data.compareTags;
			$scope.ddSelectOptionsPerPage = values.data.numberPerPage;
			$scope.ddSelectOptionsAllQueries = values.data.allQueries;
			$scope.ddSelectOptionsHDN = values.data.hDN;
			$scope.ddSelectOptionsCat = values.data.category;
			$scope.ddSelectOptionsUnits = values.data.units;
		},
		function (error) {
			var errorMessage = 'Error loading entities...';
		});

		//click show popup Disclaimer
		$scope.clickShowPopupDisclaimer = function(){
			$scope.isShowPopupDisclaimer= true;
			$scope.addClassBlockSrcoll();
			angular.element(document.querySelectorAll('.disclaimer-popup')).css('height',$window.innerHeight-60 + 'px');
		}

		$scope.clickHiddenPopupDisclaimer = function(){
			$scope.isShowPopupDisclaimer=false;
			angular.element(document.querySelectorAll('body')).removeClass('open-popup');
		}

		$scope.addClassBlockSrcoll = function(){
			angular.element(document.querySelectorAll('body')).addClass('open-popup');
		}

		$scope.clickBackToTop = function(){
			$window.scrollTo(0, 0);
		}
		$scope.printDiv = function(divName) {
		  var printContents = document.getElementById(divName).innerHTML;
		  var popupWin = window.open('', '_blank', 'width=300,height=300');
		  popupWin.document.open();

		  popupWin.document.write('<html><head>' + '</head><body onload="window.print()">' + printContents + '</body></html>');
		  popupWin.document.close();
		} 


		$scope.exportData = function (divNames, fileName) {
			var blobContent = [];
			divNames.split(' ').forEach(function (e) {
				blobContent.push(document.getElementById(e).innerHTML);
			})
	        var blob = new Blob(blobContent, {
	            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=utf-8"
	        });

	        		    // for IE
			if (navigator.appVersion.toString().indexOf('.NET') > 0) {
			    window.navigator.msSaveBlob(blob, fileName + '.xls');
			    return;
			}

	        var url = window.URL.createObjectURL(blob);
			var anchor = angular.element('<a/>')
			.css({'display':'none'})
			.append('download');
			angular.element(document.body).append(anchor);

		    anchor.attr({
				href: url,
				target: '_self',
		        download: fileName + '.xls'
		    })[0].click();


	    };		
		$scope.getQueriesCount = function(entitySelected, type, title) {
			if (entitySelected.length === 0) {
				return 0;
			}

			switch (type) {
				case 'total': 
					return entitySelected.QueriesGroup.reduce(function (a, b) {
						return a.concat(b.Queries)
					}, []).length;
				case 'open':
					return entitySelected.QueriesGroup.reduce(function (a, b) {
						return a.concat(b.Queries.filter(function(e) {
							return e.Status === 'Open';
						}));
					}, []).length;				
				case 'closed':
					return entitySelected.QueriesGroup.reduce(function (a, b) {
						return a.concat(b.Queries.filter(function (e) {
							return e.Status === 'Resolved';
						}))
					}, []).length;				

				}

		};



		// go to the latest year
		$scope.queryEntityByLastYear = function (entities) {
			var lastYearEntity = entities.sort(function (a, b) {return b.Year - a.Year;})[0];
			$scope.goDocummentDetailPage(lastYearEntity.EntityId, lastYearEntity.FileGUID);
		}

		$scope.generateUniqueDatesColors = function (fileGUIDs) {
			var allContextRefs = [];
			if (fileGUIDs && fileGUIDs.length > 0) {
				allContextRefs = $scope.allContextRefs;

				allContextRefs = $scope.allContextRefs.filter(function (e) {
					return fileGUIDs.indexOf(e.FileGuid) > -1;
				});
			}
			
			// generate color codes 
			var colors = ['#ff9000','#002776','#00a1de','#81bc00','#babfca'];
			for (var i = 0; i < 100; i++) {
				// generate some random color for use
				colors.push('#'+Math.floor(Math.random()*16777215).toString(16));
			}
			var uniqueDatesColors = {}; // unique start - end dates combinations
			allContextRefs.forEach(function (e) {
				e.ContextRefDetails.forEach(function(e) {
					
					if (!uniqueDatesColors[e.DateStart + e.DateEnd]) {
						var uniqueDatesColorsCount = Object.keys(uniqueDatesColors).length;
						var colorIdx = (uniqueDatesColorsCount < colors.length) ? uniqueDatesColorsCount 
							: (uniqueDatesColorsCount % colors.length);
						uniqueDatesColors[e.DateStart + e.DateEnd] = {
							color: colors[colorIdx],
							DateStart: e.DateStart,
							DateEnd: e.DateEnd,
							PeriodType: e.PeriodType
						};
					}
				})
			});
			$scope.uniqueDatesColors = uniqueDatesColors;

		}

		$scope.getColorCode = function (contextId, fileGUID) {
			var allContextRefs = $scope.allContextRefs;
			var contextRef = allContextRefs.filter(function (e) {
				return e.FileGuid === fileGUID;
			})[0];

			var contextRefDetail = contextRef.ContextRefDetails.filter(function (e) {
				return e.ContextId === contextId;
			})[0];

			return $scope.uniqueDatesColors[contextRefDetail.DateStart + contextRefDetail.DateEnd];
			
		}

		$scope.changeGrid = function (boolean) {
			$scope.isShowGridVer = boolean;
		}

		// return time in format 10:00AM - June 25, 2016
		$scope.getTimeNow = function () {

			return $filter('date')(new Date(), 'hh:mma - MMM dd, yyyy');			
			 
		}

	}
]);