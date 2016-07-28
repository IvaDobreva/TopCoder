app.controller("dashBoardPageCtrl",['$scope','$filter','$window','dropdownService','clients', 'entities', 'tagList', 'contextRef', 'tagComparison', 'files', '$sce',
	function ($scope,$filter,$window,dropdownService, clients, entities, tagList, contextRef, tagComparison, files, $sce) {
		$scope.$parent.titlePape = "DashBoardPage"; 

		var heightContent = angular.element(document.querySelectorAll('.dinnaco-full-content'))[0].clientHeight;
		if (heightContent<$window.innerHeight) {
			angular.element(document.querySelectorAll('.overlay')).css('height',$window.innerHeight);
		}


		$scope.listCompareTag = [];

		$scope.isHidenTitleDrag = false;

		//filter Data
		$scope.sortingOrder = "";
		$scope.reverse = true;
		$scope.filteredItems = [];
		$scope.groupedItems = [];
		$scope.itemsPerPage = 10;
		$scope.pagedItems = [];
		$scope.currentPage = 0;

		var searchMatch = function (haystack, needle) {
		    haystack = haystack.toString();
		    if (!needle) {
		        return true;
		    }
		    return haystack.toLowerCase().indexOf(needle.toString().toLowerCase()) !== -1;
		};

		// init the filtered items
		$scope.querySearchDropdown = "";
		$scope.filedSearchDropdown="";
		$scope.search = function (selected) {
			var compareType = selected ? selected.value : $scope.ddCompareSelected.value;
		    $scope.filteredItems = $filter('filter')($scope.dashBoardDataTable, function (item) {
		    	var resultCheckData = false;
		        if (searchMatch(item.ClientName, $scope.querySearch)){
		            return true;
		        }
		        return false;
		    });

		    if ($scope.querySearchDropdown !== "" && $scope.filedSearchDropdown!=="" && $scope.querySearchDropdown !== 0) {
		    	$scope.filteredItems = $filter('filter')($scope.dashBoardDataTable, function (item) {
		    		
		    	    if ($scope.filedSearchDropdown === "ClientName") {
		    	    	if (searchMatch(item.ClientName,$scope.querySearchDropdown)) {
		    	    		return true;
		    	    	}
		    	    }
		    	    if ($scope.filedSearchDropdown === "OpenQueries") {
		    	    	if (compareByType(Math.round(item.OpenQueries), parseInt($scope.querySearchDropdown), compareType)) {
		    	    		return true;
		    	    	}
		    	    }
		    	    if ($scope.filedSearchDropdown === "ETR") {
		    	    	if (compareByType(Math.round(item.ETR), parseInt($scope.querySearchDropdown), compareType)){
		    	    		return true;
		    	    	}
		    	    }
		    	    if ($scope.filedSearchDropdown === "DebtorDays") {
		    	    	if (compareByType(Math.round(item.DebtorDays), parseInt($scope.querySearchDropdown), compareType)) {
		    	    		return true;
		    	    	}
		    	    }
		    	    if ($scope.filedSearchDropdown === "ROCE") {
		    	    	if (compareByType(Math.round(item.ROCE * 100),  parseInt($scope.querySearchDropdown), compareType)) {
		    	    		return true;
		    	    	}
		    	    }
		    	    return false;
		    	});
		    }

		    if ($scope.sortingOrder !== '') {
		        $scope.filteredItems = $filter('orderBy')($scope.filteredItems, $scope.sortingOrder, $scope.reverse);
		    }
		    $scope.currentPage = 0;
		    $scope.groupToPages();
		};



		// calculate page in place
		$scope.groupToPages = function () {
		    $scope.pagedItems = [];
		    for (var i = 0; i < $scope.filteredItems.length; i++) {
		        if (i % $scope.itemsPerPage === 0) {
		                $scope.pagedItems[Math.floor(i / $scope.itemsPerPage)] = [$scope.filteredItems[i]];
		        } else {
		                $scope.pagedItems[Math.floor(i / $scope.itemsPerPage)].push($scope.filteredItems[i]);
		        }
		    }
		};

		$scope.hiddenDotPage = false;
		$scope.getRangePage = function(start,end){
			$scope.hiddenDotPage = false;
			var ret = [];
		    if (!end) {
		            end = start;
		            start = 0;
		    }
		    if (end <=4 ) {
		    	for (var i = start; i < end; i++) {
		    	    ret.push(i);
		    	}	
		    }else{
		    	if ($scope.currentPage<=2) {
		    		for (var i = 0; i < 4; i++) {
	    				ret.push(i);
	    			}
		    	}else{
		    		if ($scope.currentPage+2 < end) {
			    		for (var i = $scope.currentPage-2; i < $scope.currentPage+2; i++) {
		    				ret.push(i);
		    			}
		    		}else{
		    			$scope.hiddenDotPage = true;
			    		for (var i = end-4; i < end; i++) {
		    				ret.push(i);
		    			}
		    		}
		    	}
		    }
		    return ret;
		}

		$scope.prevPage = function () {
		    if ($scope.currentPage > 0) {
		            $scope.currentPage--;
		    }
		};

		$scope.nextPage = function () {
		    if ($scope.currentPage < $scope.pagedItems.length - 1) {
		            $scope.currentPage++;
		    }
		};

		$scope.setPage = function () {
		    $scope.currentPage = this.n;
		};

		// change sorting order
		$scope.sort_by = function (newSortingOrder) {
	        if ($scope.sortingOrder === newSortingOrder){
	                $scope.reverse = !$scope.reverse;          
	        }else{
	            $scope.reverse = false;
	            $scope.sortingOrder = newSortingOrder;
	        }
	        $scope.search();
		};

		//change sorting order entity Table
		$scope.sort_by_entity = function(group,newSortingOrder){
			if (group.strSortingOrderEntity === newSortingOrder){
			        group.reverseEntity = !group.reverseEntity;          
			}else{
			    group.reverseEntity = false;
			    group.strSortingOrderEntity = newSortingOrder;
			}

			group.Entities = $filter('orderBy')(group.Entities, group.strSortingOrderEntity, group.reverseEntity);
		}

		//select item on dropdow Page
		$scope.setNumberPerPage = function(selected){
		     $scope.itemsPerPage = selected.value;
		     $scope.search();  
		};

		$scope.search();

		// set check item datatable
		$scope.isCompareTag= false;
		if ($scope.dashBoardDataTable.length > 1) {
			for (var i = 0; i < $scope.dashBoardDataTable.length; i++) {
				if ($scope.dashBoardDataTable[i].isCheck) {
					$scope.listCompareTag.push($scope.dashBoardDataTable[i]);
					$scope.isHidenTitleDrag = true;
					$scope.isCompareTag = $scope.listCompareTag.length > 1;
				}
			}
		}
		
		$scope.clickCheckBoxItem = function(item){
			if (item.isCheck) {
				if($scope.listCompareTag.length>0){
					item.isCheck = false;
					$scope.removeTagCompare(item.Id);
				}
			}else{
				if ($scope.listCompareTag.length < 3) {
					item.isCheck = true;
					$scope.addTagCompare(item);
				}
			}
		}

		//show Popup Compare
		$scope.clickShowPopupCompare = function(){
			$scope.isShowPopupCompare=true;
			angular.element(document.querySelectorAll('body')).addClass('open-popup');
			if (heightContent === 0 || heightContent>$window.innerHeight) {
				angular.element(document.querySelectorAll('.dinnaco-full-content .compare-tags-popup')).css('height',$window.innerHeight-60 + 'px');
				angular.element(document.querySelectorAll('.dinnaco-full-content .compare-tags-popup .cover-table')).css('height',$window.innerHeight-305 + 'px');
				angular.element(document.querySelectorAll('.dinnaco-full-content .compare-tags-popup .cover-table')).css('overflow-y','auto');
			}
			$scope.GetTagListByCompare($scope.listCompareTag);
		}

		$scope.clickHiddenPopup = function(){
			$scope.isShowPopupChart=false;
			$scope.isShowPopupCompare=false;
			$scope.$parent.isShowPopupDisclaimer=false;
			angular.element(document.querySelectorAll('body')).removeClass('open-popup');
		}
			
		//add tag List Compare
		$scope.addTagCompare = function(item){
			if ($scope.listCompareTag.length < 3) {
				$scope.listCompareTag.push(item);
				updateLastThreeYears();

				$scope.isHidenTitleDrag = true;
				if ($scope.dashBoardDataTable.length > 1 && $scope.listCompareTag.length>1) {
					$scope.isCompareTag = true;
				}

				$scope.$broadcast('compareItemChanged', $scope.listCompareTag);
			}
		}



		//remove tag List compare
		$scope.removeTagCompare = function(id){
			if ($scope.listCompareTag.length > 0) {
				for (var i = 0; i < $scope.listCompareTag.length; i++) {
					if($scope.listCompareTag[i].Id === id){
						$scope.listCompareTag.splice(i,1);
						if ($scope.listCompareTag.length === 1) {
							$scope.isCompareTag = false;
						}
						if ($scope.listCompareTag.length === 0) {
							$scope.isHidenTitleDrag = false;
						}
						updateLastThreeYears();
						$scope.removeCheckItemDashBoardTable(id);
						$scope.$broadcast('compareItemChanged', $scope.listCompareTag);

					}
				}
			}
		}

		function updateLastThreeYears() {
			var listCompareTag = $scope.listCompareTag;
			var allYears = [];
			$scope.listCompareTag.forEach(function(e){
				var entityYears = e.Entities.map(function(entity){
					return entity.Year;
				});
				allYears = allYears.concat(entityYears);
			});
			var latestYear = d3.max(allYears);
			var lastThreeYears = [latestYear, latestYear-1,latestYear-2];
			$scope.lastThreeYears = lastThreeYears;

		}


		$scope.showEtrChart = function (isShow) {
			$scope.isShowEtrChart = isShow;
		}
		//get Data Etr 
		$scope.isShowEtrChart = false;
		$scope.getDataETR = function(item,yearIdx){
			var lastThreeYears = $scope.lastThreeYears;
			for (var i = 0; i < item.Entities.length; i++) {
				if (item.Entities[i].Year === lastThreeYears[yearIdx]) {
					return item.Entities[i].ETR;;
				}
			}

		}

		//get Data DebtorDays 
		$scope.isShowDebtorDaysChart = false;
		$scope.getDataDebtorDays = function(item,yearIdx){
			var lastThreeYears = $scope.lastThreeYears;
			for (var i = 0; i < item.Entities.length; i++) {
				if (item.Entities[i].Year === lastThreeYears[yearIdx]) {
					return item.Entities[i].DebtorDays;
				}
			}
		}

		//get Data Roce 
		$scope.isShowRoceChart = false;
		$scope.getDataRoce = function(item,yearIdx){

			var lastThreeYears = $scope.lastThreeYears;
			for (var i = 0; i < item.Entities.length; i++) {
				if (item.Entities[i].Year === lastThreeYears[yearIdx]) {
					return item.Entities[i].ROCE*100;
				}
			}
		}
		
		//selected compare category
		$scope.titleSelectedCompare ="ETR";
		$scope.isShowPopupChart = false;
		$scope.isShowDataPopupChart=false;
		$scope.selectedCompareZoom = function(title){
			$scope.titleSelectedCompare = title;
			if (title === "ETR") {
				$scope.isShowDataPopupChart = $scope.isShowEtrChart;
			}else if(title === "DEBTOR DAYS"){
				$scope.isShowDataPopupChart = $scope.isShowDebtorDaysChart;
			}else if(title === "ROCE"){
				$scope.isShowDataPopupChart = $scope.isShowRoceChart;
			}
			$scope.isShowPopupChart = true;
			$scope.addClassBlockSrcoll();
			$scope.$broadcast('compareItemPopup', $scope.listCompareTag);
		}

		$scope.isShowPopupCompare = false;

		$scope.highlightRow = function(event, ui){
			var isFirefox = navigator.userAgent.toLowerCase().indexOf('firefox') > -1;
			var isChrome = /Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor);
			var stringValue = "";

			if (isFirefox) {
				stringValue = ui.draggable[0].attributes[0].nodeValue;
			}else{
				stringValue = angular.element(ui.draggable)[0].attributes[3].nodeValue;
			}
			var stringIndex = stringValue.substring(stringValue.indexOf("index")+6,stringValue.indexOf(","));
			for (var i = 0; i < $scope.dashBoardDataTable.length; i++) {
				if($scope.dashBoardDataTable[i].Id === parseInt(stringIndex)){
					if ($scope.listCompareTag.length < 3) {
						if (!$scope.$parent.dashBoardDataTable[i].isCheck) {
							$scope.$parent.dashBoardDataTable[i].isCheck = true;
							$scope.addTagCompare($scope.dashBoardDataTable[i]);
						}
					}
				}
			}
		};

		//get class for grid Item
		$scope.getClassForGridItem = function(index,item){
			var strClass  = "";
			if (item.isCheck) {
				strClass = "active ";
			}

			if ($window.innerWidth > 1025) {
				if (index%4 === 0) {
					strClass += "one"; 
				}else if(index%4 === 1){
					strClass += "two"; 
				}else if(index%4 === 2){
					strClass += "three"; 
				}else if(index%4 === 3){
					strClass += "four"; 
				}
			}else{
				if (index%3 === 0) {
					strClass += "one"; 
				}else if(index%3 === 1){
					strClass += "two"; 
				}else if(index%3 === 2){
					strClass += "three"; 
				}
			}
			return strClass;
		}

		//get Class for Grid 
		$scope.getClassForGridIpad = function(){
			if ($scope.isShowGridVer) {
				return "for-grid";
			}
		}

		//click show Popup Chart on Ipad
		$scope.clickChartOnIpad = function(strChart){
			if ($window.innerWidth < 1025) {
				$scope.selectedCompareZoom(strChart);
			}
		}

		//get data popup Chart
		$scope.getDataPopupChart = function(item,yearIdx){
			var lastThreeYears = $scope.lastThreeYears;
			for (var i = 0; i < item.Entities.length; i++) {
				if (item.Entities[i].Year === lastThreeYears[yearIdx]) {
					if ($scope.titleSelectedCompare === "ETR") {
						return item.Entities[i].ETR;
					}else if($scope.titleSelectedCompare === "DEBTOR DAYS"){
						return item.Entities[i].DebtorDays;
					}else if($scope.titleSelectedCompare === "ROCE"){
						return item.Entities[i].ROCE*100;
					}
				}
			}


			
		}

		//Dropdown for Sort by
		$scope.sortByFunc  =function(selected){
			angular.element(document.querySelectorAll('.sort-change .wrap-dd-select')).addClass('change');
			$scope.sort_by(selected.value);
		};

		//Dropdown for Filter by
		$scope.isShowInputTextFilter = false;
		$scope.isShowInputNumberFilter = false;
		$scope.hiddenInputFilter = function(){
			$scope.isShowInputTextFilter = false;
			$scope.isShowInputNumberFilter = false;
		}

		$scope.filterByFunc  =function(selected){
			angular.element(document.querySelectorAll('.filter-by .wrap-dd-select')).addClass('change');
			$scope.isShowInputTextFilter = false;
			$scope.isShowInputNumberFilter = false;
			$scope.isShowInputTextFilter="";

			$scope.filedSearchDropdown = selected.value;
			if (selected.value === "ClientName") {
				$scope.isShowInputTextFilter = true;
			}else{
				$scope.isShowInputNumberFilter = true;
			}
			$scope.search();
		};
		

		//Dropdown for Number per Page
		$scope.perPageFunc  =function(selected){
			angular.element(document.querySelectorAll('.dropdown-here .wrap-dd-select')).addClass('change');
			$scope.setNumberPerPage(selected);
		};

		//get Class For Drag and Drop
		$scope.getClassDragDropIpad = function(){
			if ($window.innerWidth <1025 && $scope.isCompareTag) {
				return "for-column";
			}
		}

		//old Data
		$scope.init = function () {
			$scope.initVariables();
			updateLastThreeYears();
		};

		$scope.initVariables = function () {

			$scope.clientYearDetails = [];
			$scope.clientYear = [];
			$scope.entityDetails = [];
			$scope.entity = [];
			$scope.allTagLists = [];
			$scope.tagList = [];
			$scope.tagComparisons = [];
			$scope.tagComparison = [];
			$scope.file = [];
			$scope.isShowListSelectTags = false;


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
		


		$scope.GetFile = function (fileGUID, fileType) {
			fileGUID = 'dummyfileguid'; // for temp use
			
			var promise = files.getFile(fileGUID, fileType);



			promise.then(function (value) {
				var anchor = angular.element('<a/>');
				anchor.css({'display':'none'})
				.append('download')
			    .attr({
					href: value.config.url,
					target: '_self',
			        download: fileGUID + '.' +  fileType + '.zip'
			    });

				angular.element(document.body).append(anchor);
				anchor[0].click()


			},
			function (error) {
				var errorMessage = 'Error getting files...';
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

		$scope.GetTagList = function (fileGUID) {
			var promise = tagList.getAllTagLists();

			promise.then(function (values) {
				var allTagLists = values.data;
				$scope.tagList = allTagLists.filter(customFilter({ 'FileGUID': fileGUID.toLowerCase() }));
				$scope.tagListCount = $scope.tagList.length;
				$scope.compareTagsData = values.data;
				$scope.compareTagsDataForFilter = angular.copy($scope.compareTagsData);

				$scope.checkedTags = $scope.compareTagsDataForFilter.filter(function (e) {
					return e.isCheck;
				}).map(function(e){
					return e.Tag;
				});


			},
			function (error) {
				var errorMessage = 'Error loading tag lists...';
			});
		};

		$scope.GetTagListByCompare = function (allEntities) {
			var promise = tagList.getAllTagLists();

			var uniqueEntities = [];
			allEntities.forEach(function (e) {
				uniqueEntities = uniqueEntities.concat(e.Entities.map(function (e) {
					return {
						FileGUID: e.FileGUID,
						CompanyName: e.CompanyName,
						Year: e.Year
					};
				}))
			});

			// generate color code for compare pop up
			$scope.generateUniqueDatesColors(uniqueEntities.map(function (e) {
				return e.FileGUID;
			}))

			var uniqueYears = [{
				"text": "All",
				"value": "All"
			}];
			uniqueEntities.map(function (e) {
				return e.Year;
			}).filter(function (e, i, arr){
				return i === arr.indexOf(e);
			}).forEach(function (e) {
				uniqueYears.push({
					"text": e,
					"value": e

				})
			});

			promise.then(function (values) {
				var allTagLists = values.data;
				var dataByCompare = [];
				var allCompareValues = [];
				uniqueEntities.forEach(function (e) {
					dataByCompare = dataByCompare.concat(allTagLists.filter(customFilter({ 'FileGUID': e.FileGUID.toLowerCase() })));
				})
				var uniqueTagLists = [];
				for (var i = 0; i < dataByCompare.length; i++) {
					uniqueTagLists = uniqueTagLists.concat(dataByCompare[i].TagsList.map(function (e) {
						return e.TagName;
					}));
					var fileGUID = dataByCompare[i].FileGUID;

					dataByCompare[i].TagsList.forEach(function (e) {
						var res = {
							FileGUID: fileGUID,
							Tag: e.TagName,
							Contextid: e.Contextid
						};
						var isAppend = true;
						var currentEntity = uniqueEntities.filter(function (e) {
							return e.FileGUID === fileGUID;
						})[0];
						var _length = allCompareValues.length;
						for (var j = 0; j < _length; j++) {
							if(e.TagName === allCompareValues[j].Tag 
								&& allCompareValues[j].Year === currentEntity.Year) 
							{
								isAppend = false;
								break;
							}

						}

						if (isAppend) {
							res.Year = currentEntity.Year;
							res[currentEntity.CompanyName] = e.ReportedValue;
							allCompareValues.push(res);

						} else {
							allCompareValues[j][currentEntity.CompanyName] = e.ReportedValue;

						}


					});
					// })
				}

				uniqueTagLists = uniqueTagLists.filter(function (e, i, arr) {
					return i === arr.indexOf(e);
				});

				uniqueTagLists.map(function (e) {
					return {
						Tag: e
					};
				});
				var compareTagsData = uniqueTagLists.map(function (e){ return { Tag: e, isCheck: true}});

				$scope.tagListCount = compareTagsData.length;
				$scope.compareTagsData = compareTagsData;
				$scope.compareTagsDataForFilter = angular.copy($scope.compareTagsData);
				$scope.checkedTags = $scope.compareTagsDataForFilter.filter(function (e) {
					return e.isCheck;
				}).map(function(e){
					return e.Tag;
				});
				$scope.ddSelectOptionsCompareTags = uniqueYears; // year selector
				$scope.allCompareValues = allCompareValues;


			},
			function (error) {
				var errorMessage = 'Error loading tag lists...';
			});
		};


		$scope.handleInput = function ($event) {
			if ($event.keyCode === 13) {
				$scope.hiddenInputFilter();
			}
		};

		$scope.handleDropDown = function () {
			var filterDropDown = angular.element(document.querySelector('#filter-dropdown'));
			if (filterDropDown.hasClass('active')) {
				$scope.hiddenInputFilter();
			}

		};

		$scope.filterCompareTagsData = function (item) {
			var year = $scope.ddSelectSelectedCompareTags.value;

			var yearPass = true;
			if (year === 'All' || !year) {
				yearPass = true;
			} else {
				yearPass = (item.Year === year);
			}

			return yearPass && $scope.checkedTags.indexOf(item.Tag) > 0;
		}

		$scope.selectedTagsLength = function () {
			return $scope.compareTagsData.filter(function(e){
				return e.isCheck;
			}).length;
		}


		//click Apply popup Compare
		$scope.clickApplyPopupCompare = function(isApply){
			if (isApply) {
    			$scope.compareTagsDataForFilter = angular.copy($scope.compareTagsData);

			} else {
    			$scope.compareTagsData = angular.copy($scope.compareTagsDataForFilter);

			}

			var checkedTags = $scope.compareTagsDataForFilter.filter(function (e) {
				return e.isCheck;
			}).map(function(e){
				return e.Tag;
			});

			$scope.checkedTags = checkedTags;
			$scope.isShowListSelectTags = false;

		}


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

		function compareByType(a, b, type) {
			switch (type) {
				case 1: // type > 
					return a > b;
				case 2: // type <
					return a < b;
				case 0: // type =
				default:
					return a === b;

			}
		}

		$scope.init();

	}
]);