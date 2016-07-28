app.controller("documentDetailPageCtrl", ['$scope', '$filter', 'queryStatusService', '$sce', 'tagComparison', 'tagList', '$timeout', 'annotation', 'contextRef', '$window', 'files',
	function($scope, $filter, queryStatusService, $sce, tagComparison, tagList, $timeout,annotation,contextRef, $window,files) {
		$scope.$parent.titlePape = "DashBoardPage";

		$scope.showTabTitle = "Contents";
		$scope.isShowPopupCompareDocument = false;

		$scope.tagComparisonDetails = [];
		$scope.tags = [];

		$scope.attrs = [];
		$scope.filterAttrs = [];

		$scope.Contents = {
			Title: '',
			Description: '',
			Data: []
		};


		$scope.getClassForHistory = function(item) {
			var orangeDate = new Date("Mar 30, 2015");
			var blueDate = new Date("April 01, 2014");
			var greenDate = new Date("Mar 30, 2014");

			var itemDate = new Date(item.DatePost);
			if (itemDate > orangeDate) {
				return "orange";
			} else if (itemDate > blueDate && itemDate < orangeDate) {
				return "blue";
			} else if (itemDate > greenDate) {
				return "green";
			}
		}

		//check Data  Null
		$scope.checkDataNull = function(str) {
			if (str === "") {
				return "-";
			} else {
				if (isNaN(str)) {
					return str;
				} else {
					return $filter('number')(str, 0);
				}
			}
		}

		$scope.$parent.documentDetailData.Contents.Data[0].Data[0].isSelected = true;

		$scope.clickContenTable = function(event, item) {
			angular.element(document.querySelectorAll('.page-document .list-side .sub-side li')).removeClass('active');
			angular.element(event.currentTarget).addClass('active');

			for (var i = 0; i < $scope.documentDetailData.Contents.Data.length; i++) {
				$scope.$parent.documentDetailData.Contents.Data[i].isSelected = false;
			}
			item.isSelected = true;
		}

		$scope.goToContent = function(heading) {
			// deal with spans or b containing bold titles
			var $anchorHeading = $('div[class*="Section"] p.MsoNormal:has( > b)')
				.find('> span b:not(:has(*)), > b > span')
				.filter(function() {
					var $text = $(this).text().trim();
					return $text.length > 3 && $text !== 'CONTENTS' && !/[a-z,]/.test($text.split(' ')[0]);
				})
				.filter(function() {
					var $text = $(this).text().trim();
					return $text === heading;
				});
			var $container = $('.iXBRLHtml');
			$container.scrollTop(
				$anchorHeading.offset().top - $container.offset().top + $container.scrollTop()
			);
		}

		$scope.goToTag = function(contextId, tagName) {
			var selector = '.iXBRLHtml div[class*="Section"] *[contextref="' + contextId + '"][name$="' + tagName + '"]' + ' span, ' +
				'.iXBRLHtml div[class*="Section"] *[contextref="' + contextId + '"][name$="' + tagName + '"]';



			var $container = $('.iXBRLHtml');
			if ($(selector).length === 0) {
				return;
			}
			$container.scrollTop(
				$(selector).offset().top - $container.offset().top + $container.scrollTop()
			);

		}

		$scope.colorAllTags = function () {
			tagList.getAllTagLists().then(function(values) {
				var currentFileGUID = $scope.currentFileGUID;
				$scope.tags = values.data.filter(function(e) {
					return currentFileGUID === e.FileGUID.toLowerCase();
				})[0];

				if (!$scope.tags) {
					return;
				}			
				$scope.tags.TagsList.forEach(function (e) {
					$scope.colorTag(e.Contextid);
				})

			},
			function(error) {
				var errorMessage = 'Error loading tag lists...';
			});

		}

		// add color to tag elements 
		$scope.colorTag = function (contextId) {
			var colorCode = $scope.getColorCode(contextId, $scope.currentFileGUID);
			var selectorAll = '.iXBRLHtml div[class*="Section"] *[contextref="' + contextId + '"]' + ' span, ' +
				'.iXBRLHtml div[class*="Section"] *[contextref="' + contextId + '"]';
			$(selectorAll).css({
				'background':  colorCode ? colorCode.color : ''
			});

		}

		//TEMP return some random color from existing color codes
		$scope.historyColor = function (index, item) {
			var uniqueDatesColors = $scope.uniqueDatesColors;

			var array = $.map(uniqueDatesColors, function(value, index) {
    			return [value.color];
			});

			return array[index % array.length || 0];


		}

		//click show Popup Compare
		$scope.isShowPopupCompare = function() {
			var currentFileGUID = $scope.currentFileGUID;

			$scope.GetTagComparison(currentFileGUID);

			$scope.isShowPopupCompareDocument = true;
			$scope.addClassBlockSrcoll();


		}

		$scope.hiddenPopup = function() {
			$scope.isShowPopupCompareDocument = false;
			angular.element(document.querySelectorAll('body')).removeClass('open-popup');
		}

		$scope.criteriaMatch = function(criteria, ddSelectSelectedHDN) {
			var criteria = criteria || {};
			criteria.IsHidden = ddSelectSelectedHDN.value;
			return function(item) {
				return filterBy(item, criteria);
			}
		}

		function filterBy(item, criteria) {
			for (var key in criteria) {
				if (criteria.hasOwnProperty(key) && criteria[key]) {
					// only have to match one of caption and tagname
					if (key === 'TagName') {
						if (item.Caption != criteria[key] && item.TagName != criteria[key]) {
							return false;
						}

					} else if (item[key] != criteria[key]) {
						return false;
					}
				}
			}
			return true;
		}

		$scope.getOpenQueryCount = function(queries) {
			return queries.filter(function(e) {
				return e.Status === 'Open';
			}).length;
		}

		$scope.addQuery = function(index, queries) {

			var content = queries.queryContent;
			if (content) {
				var newQuery = {
					Comment: content,
					Date: $scope.getTimeNow(),
					Name: 'Jane Doe',
					Status: 'Open',
					Reply: []
				}
				$scope.entitySelected.QueriesGroup[index].Queries.push(newQuery)
				$scope.entitySelected.QueriesGroup[index].isExpand = true;
				queries.queryContent = '';

				queryStatusService.addNewQuery($scope.queryStatusData);

			}
		}


		$scope.addReply = function(groupIndex, queryIndex, $event) {

			var content = angular.element($event.currentTarget).siblings().val();
			angular.element($event.currentTarget).parent().siblings('.when-realy').addClass('show-reply');

			if (content) {
				var newReply = {
					Comment: content,
					Date: $scope.getTimeNow(),
					Name: 'Jane Doe',
				}
				$scope.entitySelected.QueriesGroup[groupIndex].Queries[queryIndex].Reply.push(newReply);

				angular.element($event.currentTarget).siblings().val('');

				queryStatusService.addNewQuery($scope.queryStatusData);


			}
		}

		$scope.filterQueries = function(q) {
			var status = $scope.ddSelectSelectedAllQueries.text;

			var statusRes = (status === 'All Queries') ? true : status === q.Status;

			return statusRes;
		};

		$scope.filterComparisonDetails = function (item) {
			return $scope.filterAttrs.filter(function(e) {
				return e.isCheck === true;
			}).map(function (e) {
				return e.Value;
			}).indexOf(item.Detail) > -1;
		};

		$scope.filterApply = function () {
			$scope.filterAttrs = angular.copy($scope.attrs);
		};
		$scope.filterCancel = function () {
			$scope.attrs = angular.copy($scope.filterAttrs);
		};

		$scope.GetTagComparison = function(fileGuid) {
			var promise = tagComparison.getTagComparisons();

			promise.then(function(values) {
					var tagComparisons = values.data;
					var tagComparisonCurrent = tagComparisons.filter(function(e) {
						return e.FileGuid === fileGuid;
					})[0];
					if(!tagComparisonCurrent) {
						return;
					}

					// load compare attrs
					var uniqueAttrs = Object.keys(tagComparisonCurrent.TagComparisonDetails[0]);
					uniqueAttrs = uniqueAttrs.map(function (e) {
						return e.slice(0,-2);
					}).filter(function (e, i, arr) {
						return arr.indexOf(e) === i && e !== 'Tag';
					}).map(function (e) {
						return {
							Title: e, //Title could be customized
							Value: e,
							isCheck: true
						}
					});

					$scope.attrs = uniqueAttrs;
					$scope.filterAttrs = angular.copy(uniqueAttrs);

					// get the comparison data divided by attrs
					var tagComparisonDetailsByAttr = [];

					tagComparisonCurrent.TagComparisonDetails.forEach(function (detail) {
						var colorsKey = Object.keys($scope.uniqueDatesColors);
						var colorsCount = Object.keys($scope.uniqueDatesColors).length;

						uniqueAttrs.forEach(function(e){
							var comparisonItem = {};
							//TEMP: create dummy data for column detail and item status
							comparisonItem.Status = ['normal', 'high', 'low'][Math.floor(Math.random()*3)];
							comparisonItem.Color = $scope.uniqueDatesColors[colorsKey[Math.floor(Math.random()*colorsCount)]].color;
							comparisonItem.CY = detail[e.Value + 'CY'];
							comparisonItem.PY = detail[e.Value + 'CY'];
							comparisonItem.Detail = e.Value;
							comparisonItem.Tag = detail.TagCY ? detail.TagCY :  detail.TagPY;
							tagComparisonDetailsByAttr.push(comparisonItem);
							$scope.tagComparisonDetails = tagComparisonDetailsByAttr;

						});

					});


				},
				function(error) {
					var errorMessage = 'Error loading tag lists...';
				});
		};
		$scope.toggleReply = function($event) {
			angular.element($event.currentTarget).parent().toggleClass('show-reply');
		}

		$scope.toggleReplyInput = function($event) {
			angular.element($event.currentTarget).siblings('.reply').toggleClass('show');
		}

		$scope.getContents = function () {
			var contents = {
					Title: '',
					Description: '',
					Data: []
				}

			contents.Title = $('*[name$="EntityCurrentLegalOrRegisteredName"]').text();
			contents.Description = $('*[name$="BusinessReportName"]').text()
									+ '  '  + $('*[name$="EndDateForPeriodCoveredByReport"]').text();

				// deal with spans or b containing blod titles
			var $headings = $('.iXBRLHtml div[class*="Section"] p.MsoNormal:has( > b)')
				.find('> span b:not(:has(*)), > b > span')
				.filter(function() {
					var $text = $(this).text().trim();
					return $text.length > 3 && $text !== 'CONTENTS' && !/[a-z,]/.test($text.split(' ')[0]);
				})
				.each(function() {
					var $heading = angular.element(this);
					if ($heading.css('font-size') === '16px') { // main heading

						contents.Data.push({
							NameContent: $heading.text().trim(),
							Data: []
						})
					} else {
						// sub heading
						if (contents.Data.length < 1) {
							return;
						}
						contents.Data[contents.Data.length - 1].Data.push({
							Name: $heading.text().trim()
						})


					}

				})

			$scope.Contents = contents;
		}


		$scope.loadAnnotation = function () {
			var content = jQuery("#toAnno").annotator();

			content.annotator('addPlugin', 'Offline', {
				setAnnotationData: function (anno) {
					anno.FileGUID = $scope.currentFileGUID;
				},
				shouldLoadAnnotation: function (anno) {
					return 	anno.FileGUID === $scope.currentFileGUID;
				}
 		    });

 		   	var annotator = content.data('annotator');

			annotator.subscribe("annotationCreated", function (anno) {
			    annotation.annotate(anno, false);
			});			
			annotator.subscribe("annotationUpdated", function (anno) {
			    annotation.annotate(anno, false);
			});
			annotator.subscribe("annotationDeleted", function (anno) {
			    annotation.annotate(anno, true);
			});


		}
		// get selected quey Data entitiy and fetch iXBRL file 
		$scope.queryEntityById = function(entitiyId, fileGUID){
			var queriesData = $scope.queryStatusData;
			$scope.entitySelected = [];

			queriesData.forEach(function (e, i1) {
				e.DataEntity.forEach(function (e, i2) {
					if (e.EntityId === entitiyId) {
						$scope.entitySelected = queriesData[i1].DataEntity[i2];

					}
				})
			});

			// if no entity found in dummy data , just set the first one 
			if ($scope.entitySelected.length === 0) {
				$scope.entitySelected = queriesData[1].DataEntity[1];

			}

			$scope.loadIXBRLFile(fileGUID);


		};

		$scope.loadIXBRLFile = function (fileGUID) {

			var promise = files.getiXBRLFile(fileGUID);//fileGUID

			promise.then(function (value) {
				var rawHtml = value.data.replace(/\\"/g,'"').replace(/\\n/g,'\n').replace(/\\t/g,'\t');
				// ixbrl file loaded
				$scope.iXBRLHtml = $sce.trustAsHtml(rawHtml);
				$scope.$broadcast('iXBRLLoaded');

				// $scope.goDocummentDetailPage(fileGUID);
			},
			function (error) {
				var errorMessage = 'Error getting iXBRL files...';
				$scope.iXBRLHtml = $sce.trustAsHtml('<p style="color:#000; margin: 50px;"> No iXBRL file found </p>');
				// $scope.goDocummentDetailPage(fileGUID);

			});	
		}

		if (!$scope.currentFileGUID) {
			$scope.currentFileGUID = sessionStorage.getItem('currentFileGUID');
			$scope.currentEntityId = sessionStorage.getItem('currentEntityId');

		}

		$scope.queryEntityById($scope.currentEntityId, $scope.currentFileGUID)


		$scope.$on('iXBRLLoaded', function(event) {
			$timeout(function() {
				$scope.getContents();
				$scope.loadAnnotation();
				$scope.generateUniqueDatesColors([$scope.currentFileGUID]);
				$scope.colorAllTags();

				if ($('.left').height() > $('.iXBRLHtml').height()) {
					$('.iXBRLHtml').height($('.left').height())
				}
			})


		});



	}
]);