'use strict';

/* App Module */
var directives = angular.module('directives', []);


//Modal header
directives.directive('headerTemplate', function(){
	return {
		restrict: 'AE',
		templateUrl: 'templates/HeaderTemplate.html'
	};
})

//Modal footer
directives.directive('footerTemplate', function(){
	return {
		restrict: 'AE',
		templateUrl: 'templates/FooterTemplate.html'
	};
})


//Modal disclaimer
directives.directive('disclaimerPopupTemplate', function(){
	return {
		restrict: 'AE',
		templateUrl: 'templates/DisclaimerPopup.html'
	};
})

// Directive for radius chart
directives.directive('radiusChart', function($timeout){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			// start function
				function drawRadiusChart(){
					var widthValue = $(".left-chart .top-chart").width();
					var heightValue = $(".left-chart .top-chart").height();

					$(".knob").knob({
						'width':widthValue,
			   			'height':heightValue,
						change : function (value) {
						//console.log("change : " + value);
						},
						release : function (value) {
						//console.log(this.$.attr('value'));
						},
						cancel : function () {
						},
						format : function (value) {
							return value;
						},
						draw : function () {
						
						}
					});
				}
				drawRadiusChart();

				$scope.$on('compareItemChanged', function (event, listCompareTag) {
					if (listCompareTag && listCompareTag.length === 1) {
						var lastThreeYears = $scope.lastThreeYears;						
						var latestYear = listCompareTag[0].Entities.filter(function (e) {return e.Year === lastThreeYears[0]})[0];
						var lastYear = listCompareTag[0].Entities.filter(function (e) {return e.Year === lastThreeYears[1]})[0];
						if (lastYear) {
							listCompareTag[0].compareETR = calCompare(latestYear.ETR, lastYear.ETR);
							listCompareTag[0].compareROCE = calCompare(latestYear.ROCE, lastYear.ROCE);
							listCompareTag[0].compareDebtorDays = calCompare(latestYear.DebtorDays, lastYear.DebtorDays, true);
						}

						$timeout(function () {
							$('.knob').eq(0).val(Math.abs(Math.round(latestYear.ETR))).end()
							.eq(2).val(Math.abs(Math.round(latestYear.ROCE * 100))).end()
							.eq(0).attr('value',Math.abs(Math.round(latestYear.ETR))).end()
							.eq(2).attr('value',Math.abs(Math.round(latestYear.ROCE * 100))).end().trigger('change');

						}, 100);
					} else {
						$('.knob').eq(0).val(0).end().eq(2).val(0).end().trigger('change');

					}
				})
				$(window).on("resize", function() {
					var widthValue = $(".left-chart .top-chart").width();
					var heightValue = $(".left-chart .top-chart").height();
					$('.knob').trigger(
						'configure',{
							'width':widthValue,
							'height':heightValue,
							format : function (value) {
								return value;
							}

						}

					)
				}).trigger("resize");
			

		}
	}
});

// Directive for group ETR chart D3
directives.directive('groupChart', function($timeout){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			// start function
			var itemCount = 3;

			$scope.$on('compareItemChanged', function (event, listCompareTag) {
				if (listCompareTag && listCompareTag.length > 1) {
					itemCount = listCompareTag.length;
					$timeout(function () {
						$(window).trigger('resize');
					}, 100);
				}
			})
			function drawChart(){
				// color for bar chart
				var color = d3.scale.ordinal()
					.range(["#00246c", "#78af00", "#0099d2"]);

				var inputH = 223;
				var inputTop = 5 + 10;
				
				if ($(window).width() >=375 && $(window).width() <=1279) {
					inputH = 172;
					inputTop = 1 + 10;
				}

				var margin = {top: inputTop, right: 0, bottom: 50, left: 25},
				w = $(".group-bar").width() - margin.left - margin.right,
				h = inputH - margin.top - margin.bottom;

				var x0 = d3.scale.ordinal()
					.rangeRoundBands([0, w], .2);
				var x1 = d3.scale.ordinal();
				var y = d3.scale.linear()
					.range([h, 0]);

				var xAxis = d3.svg.axis()
					.scale(x0)  
					.orient("bottom");

				var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left")
					.tickSize(-0,0,0)
					.ticks(6)

				var yGrid = d3.svg.axis()
					.scale(y)
					.orient("left")
					.ticks(5)
					.tickSize(-0, 0, 0)
					.tickFormat("")  

				var svg = d3.select("#etrChart").append("svg")
					.attr("width", w + margin.left + margin.right)
					.attr("height", h + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");


					var listCompareTag = $scope.listCompareTag;
					if (listCompareTag == null || listCompareTag.length === 0) {
						return;
					}
					// var latestYear = listCompareTag[0].Entities[0].Year;
					var latestYear = d3.max(listCompareTag.map(function (e) {
						return e.Entities[e.Entities.length -1 ].Year;
					}));

					var lastThreeYears = $scope.lastThreeYears;
					var data = listCompareTag.map(function (e, i) {
						var res = {};
						res.Country = i + 1 + '. ' + e.ClientName.split(' ')[0] + '...';
						lastThreeYears.forEach(function (e) {
							res[e] = 0;
						})
						e.Entities.forEach(function (e) {
							if(lastThreeYears.indexOf(e.Year) > -1) {
								res[e.Year] = Math.round(Math.abs(e.ETR));
							}
						});
						return res;
					});
					var color_hash = {  0 : [lastThreeYears[2], "#00246c"],
						1 : [lastThreeYears[1], "#78af00"],
						2 : [lastThreeYears[0], "#0099d2"]
					}					
					// Draw grid
					function make_y_axis() {        
						return d3.svg.axis()
						.scale(y)
						.orient("left")
						.ticks(5)
					}		
					svg.append("g")         
						.attr("class", "Ygrid")
						.style("stroke-dasharray", ("3, 3"))
						.call(make_y_axis()
						.tickSize(-w, 0, 0)
						.tickFormat("")
					)   


					var sectorNames = d3.keys(data[0]).filter(function(key) { 
						return key !== "Country"; });
					data.forEach(function(d) {
						d.countries = sectorNames.map(function(name) { 
							return {name: name, value: +d[name]}; 
						});
					});  


					x0.domain(data.map(function(d) { return d.Country; }));
					x1.domain(sectorNames).rangeRoundBands([0, x0.rangeBand()]);
					y.domain([0, d3.max(data, function(d) { 
						return d3.max(d.countries, function(d) {return d.value; }); })]);

					svg.append("g")
						.attr("class", "x axis")
						.attr("transform", "translate(0," + h + ")")
						.call(xAxis);

					svg.append("g")
						.attr("class", "y axis")
						.attr("transform", "translate(-5," + 0 + ")")
						.call(yAxis)

					svg.append("g")         
						.attr("class", "grid")
						.call(yGrid);  

					var country = svg.selectAll(".country")
						.data(data)
						.enter().append("g")
						.attr("class", "number-value")
						.attr("transform", function(d) { return "translate(" + x0(d.Country) + ",0)"; }); 

					country.selectAll("rect")
						.data(function(d) { return d.countries; })
						.enter().append("rect")
						.attr("width", x1.rangeBand()) 
						.attr("x", function(d) { return x1(d.name); }) 
						.attr("y", function(d) { return y(d.value); }) 
						.attr("height", function(d) { return h - y(d.value); })
						.style("fill", function(d) { return color(d.name); });

					var pointlabels = country.selectAll(".pointlabels")
						.data(function(d) { return d.countries; })
						.enter().append("g")
						.attr("class", "pointlabels")
						.attr("transform", function(d) { 
							  return "translate(" + x1(d.name) + "," + y(d.value) + ")"; });

					pointlabels.append("text")
						.attr("dy", "-5")
						.attr("x", x1.rangeBand()/2)
						.attr("text-anchor", "middle")  
						.text(function(d) { return d.value; });

					// Add legend
					var centerLegend = 245;
					var topLegend = 35;
					var widthLegend = 14;
					var marginLeftLegend = 20;
					var marginTopLegend = 76;
					if ($(window).width() >=1600) {
						centerLegend = 350;
					}
					if ($(window).width() >=1440 && $(window).width() <1600) {
						centerLegend = 280;
					}
					if ($(window).width() >768 && $(window).width() <=1279) {
						centerLegend = 230;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					if ($(window).width() >=375 && $(window).width() <=768) {
						centerLegend = 175;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					
					var legend = svg.append("g")
						.data(data)
						.attr("class", "legend")
						.attr("x", w)
						// .attr("y", 50)
						.attr("height", 50)
						.attr("width", 300)
						.attr("transform", "translate(" + (w - centerLegend) + "," + (h-topLegend)+")");

					legend.selectAll('g').data(color.domain().slice().reverse())
						.enter()
						.append('g')
						.each(function(d, i) {
							var g = d3.select(this);
							g.append("rect")
								.attr("x", i * 68)
								.attr("y", 65)
								.attr("width", widthLegend)
								.attr("height", widthLegend)
								.style("fill", color_hash[String(i)][1]);

							g.append("text")
							.attr("x", i * 68 + marginLeftLegend)
							.attr("y", marginTopLegend)
							.attr("height",30)	
							.attr("width",100)	
							.text(color_hash[String(i)][0]);
				  		});

					// add yAxis line custom
					var colX = svg.append("rect")
						.attr("x", 0)
						.attr("y", 0)
						.style('fill', '#dedede')	
						.attr("class", "rectColX")
						.attr("width", 1)
						.attr("height", h);
				// });
			}
			drawChart();
			// Responses line chart
			function onResizeChart() {
				var chart = $("#etrChart"),
				    aspect = chart.width() / chart.height(),
				    container = chart.parent();

				if (chart.height() == 0) {
					return;
				}

				var targetWidth = container.width();

				var svgs = $('#etrChart').find('svg');
				svgs.remove();
				drawChart();

				var svg = $('#etrChart').find('svg')[0];
				if(typeof svg !== 'undefined'){
				    svg.setAttribute('width', targetWidth + 'px');
				    svg.setAttribute('height', Math.round(targetWidth / aspect) + 'px');

				    svg.setAttribute('viewBox', '0 0 ' + targetWidth + ' ' + Math.round(targetWidth / aspect));
				    svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');
				}
			}
			

			$(window).on("resize", function() {
				onResizeChart();
			}).trigger("resize");
			
		}
	}
});

// Directive for group DEBTOR DAYS chart D3
directives.directive('groupChartDay', function($timeout){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			var itemCount = 3;

			$scope.$on('compareItemChanged', function (event, listCompareTag) {
				if (listCompareTag && listCompareTag.length > 1) {
					itemCount = listCompareTag.length;
					$timeout(function () {
						$(window).trigger('resize');
					}, 100);
				}
			})

			// start function
			function drawChartDay(){
				// color for bar chart
				var color = d3.scale.ordinal()
					.range(["#00246c", "#78af00", "#0099d2"]);

				// Color for legend


				var inputH = 223;
				var inputTop = 5 + 10;

				if ($(window).width() >=375 && $(window).width() <=1279) {
					inputH = 172;
					inputTop = 1 + 10;
				}

				var margin = {top: inputTop, right: 0, bottom: 50, left: 25},
				w = $(".group-bar").width() - margin.left - margin.right,
				h = inputH - margin.top - margin.bottom;

				var x0 = d3.scale.ordinal()
					.rangeRoundBands([0, w], .2);
				var x1 = d3.scale.ordinal();
				var y = d3.scale.linear()
					.range([h, 0]);

				var xAxis = d3.svg.axis()
					.scale(x0)  
					.orient("bottom");

				var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left")
					.tickSize(-0,0,0)
					.ticks(6)

				var yGrid = d3.svg.axis()
					.scale(y)
					.orient("left")
					.ticks(5)
					.tickSize(-0, 0, 0)
					.tickFormat("")  

				var svg = d3.select("#dayChart").append("svg")
					.attr("width", w + margin.left + margin.right)
					.attr("height", h + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

					// keep the data items same as selected 
					var listCompareTag = $scope.listCompareTag;
					if (listCompareTag == null || listCompareTag.length === 0) {
						return;
					}

					var lastThreeYears = $scope.lastThreeYears;
					var data = listCompareTag.map(function (e, i) {
						var res = {};
						res.Country = i + 1 + '. ' + e.ClientName.split(' ')[0] + '...';
						lastThreeYears.forEach(function (e) {
							res[e] = 0;
						})
						e.Entities.forEach(function (e) {
							if(lastThreeYears.indexOf(e.Year) > -1) {
								res[e.Year] = Math.round(Math.abs(e.DebtorDays));
							}
						});
						return res;
					});

					var color_hash = {  0 : [lastThreeYears[2], "#00246c"],
						1 : [lastThreeYears[1], "#78af00"],
						2 : [lastThreeYears[0], "#0099d2"]
					}					
					// Draw grid
					function make_y_axis() {        
						return d3.svg.axis()
						.scale(y)
						.orient("left")
						.ticks(5)
					}		
					svg.append("g")         
						.attr("class", "Ygrid")
						.style("stroke-dasharray", ("3, 3"))
						.call(make_y_axis()
						.tickSize(-w, 0, 0)
						.tickFormat("")
					)   


					var sectorNames = d3.keys(data[0]).filter(function(key) { 
						return key !== "Country"; });
					data.forEach(function(d) {
						d.countries = sectorNames.map(function(name) { 
							return {name: name, value: +d[name]}; 
						});
					});  

					x0.domain(data.map(function(d) { return d.Country; }));
					x1.domain(sectorNames).rangeRoundBands([0, x0.rangeBand()]);
					y.domain([0, d3.max(data, function(d) { 
						return d3.max(d.countries, function(d) { return d.value; }); })]);

					svg.append("g")
						.attr("class", "x axis")
						.attr("transform", "translate(0," + h + ")")
						.call(xAxis);

					svg.append("g")
						.attr("class", "y axis")
						.attr("transform", "translate(-5," + 0 + ")")
						.call(yAxis)

					svg.append("g")         
						.attr("class", "grid")
						.call(yGrid);  

					var country = svg.selectAll(".country")
						.data(data)
						.enter().append("g")
						.attr("class", "number-value")
						.attr("transform", function(d) { return "translate(" + x0(d.Country) + ",0)"; }); 

					country.selectAll("rect")
						.data(function(d) { return d.countries; })
						.enter().append("rect")
						.attr("width", x1.rangeBand()) 
						.attr("x", function(d) { return x1(d.name); }) 
						.attr("y", function(d) { return y(d.value); }) 
						.attr("height", function(d) { return h - y(d.value); })
						.style("fill", function(d) { return color(d.name); });

					var pointlabels = country.selectAll(".pointlabels")
						.data(function(d) { return d.countries; })
						.enter().append("g")
						.attr("class", "pointlabels")
						.attr("transform", function(d) { 
							  return "translate(" + x1(d.name) + "," + y(d.value) + ")"; });

					pointlabels.append("text")
						.attr("dy", "-5")
						.attr("x", x1.rangeBand()/2)
						.attr("text-anchor", "middle")  
						.text(function(d) { return d.value; });

					// Add legend
					var centerLegend = 245;
					var topLegend = 35;
					var widthLegend = 14;
					var marginLeftLegend = 20;
					var marginTopLegend = 76;
					if ($(window).width() >=1600) {
						centerLegend = 350;
					}
					if ($(window).width() >=1440 && $(window).width() <1600) {
						centerLegend = 280;
					}
					if ($(window).width() >768 && $(window).width() <=1279) {
						centerLegend = 230;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					if ($(window).width() >=375 && $(window).width() <=768) {
						centerLegend = 175;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					
					var legend = svg.append("g")
						.data(data)
						.attr("class", "legend")
						.attr("x", w)
						// .attr("y", 50)
						.attr("height", 50)
						.attr("width", 300)
						.attr("transform", "translate(" + (w - centerLegend) + "," + (h-topLegend)+")");

					legend.selectAll('g').data(color.domain().slice().reverse())
						.enter()
						.append('g')
						.each(function(d, i) {
							var g = d3.select(this);
							g.append("rect")
								.attr("x", i * 68)
								.attr("y", 65)
								.attr("width", widthLegend)
								.attr("height", widthLegend)
								.style("fill", color_hash[String(i)][1]);

							g.append("text")
							.attr("x", i * 68 + marginLeftLegend)
							.attr("y", marginTopLegend)
							.attr("height",30)	
							.attr("width",100)
							.text(color_hash[String(i)][0]);
				  		});

					// add yAxis line custom
					var colX = svg.append("rect")
						.attr("x", 0)
						.attr("y", 0)
						.style('fill', '#dedede')	
						.attr("class", "rectColX")
						.attr("width", 1)
						.attr("height", h);
				// });
			}
			drawChartDay();
			// Responses line chart
			function onResizeChartDay() {
				var chart = $("#dayChart"),
				    aspect = chart.width() / chart.height(),
				    container = chart.parent();

				if (chart.height() == 0) {
					return;
				}

				var targetWidth = container.width();

				var svgs = $('#dayChart').find('svg');
				svgs.remove();
				drawChartDay();

				var svg = $('#dayChart').find('svg')[0];
				if(typeof svg !== 'undefined'){
				    svg.setAttribute('width', targetWidth + 'px');
				    svg.setAttribute('height', Math.round(targetWidth / aspect) + 'px');

				    svg.setAttribute('viewBox', '0 0 ' + targetWidth + ' ' + Math.round(targetWidth / aspect));
				    svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');
				}
			}

			
			$(window).on("resize", function() {
				onResizeChartDay();
			}).trigger("resize");
			
		}
	}
});

// Directive for group ROCE chart D3
directives.directive('groupChartRoce', function($timeout){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			// start function
			var itemCount = 3;
			$scope.$on('compareItemChanged', function (event, listCompareTag) {
				if (listCompareTag && listCompareTag.length > 1) {
					itemCount = listCompareTag.length;
					$timeout(function () {
						$(window).trigger('resize');
					}, 100);
				}
			})

			function drawChartRoce(){
				// color for bar chart
				var color = d3.scale.ordinal()
					.range(["#00246c", "#78af00", "#0099d2"]);


				var inputH = 223;
				var inputTop = 15;

				if ($(window).width() >=375 && $(window).width() <=1279) {
					inputH = 172;
					inputTop = 11
				}

				var margin = {top: inputTop, right: 0, bottom: 50, left: 25},
				w = $(".group-bar").width() - margin.left - margin.right,
				h = inputH - margin.top - margin.bottom;

				var x0 = d3.scale.ordinal()
					.rangeRoundBands([0, w], .2);
				var x1 = d3.scale.ordinal();
				var y = d3.scale.linear()
					.range([h, 0]);

				var xAxis = d3.svg.axis()
					.scale(x0)  
					.orient("bottom");

				var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left")
					.tickSize(-0,0,0)
					.ticks(6)

				var yGrid = d3.svg.axis()
					.scale(y)
					.orient("left")
					.ticks(5)
					.tickSize(-0, 0, 0)
					.tickFormat("")  

				var svg = d3.select("#roceChart").append("svg")
					.attr("width", w + margin.left + margin.right)
					.attr("height", h + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

					// keep the data items same as selected 
					var listCompareTag = $scope.listCompareTag;
					if (listCompareTag == null || listCompareTag.length === 0) {
						return;
					}


					var lastThreeYears = $scope.lastThreeYears;
					var data = listCompareTag.map(function (e, i) {
						var res = {};
						res.Country = i + 1 + '. ' +  e.ClientName.split(' ')[0] + '...';
						lastThreeYears.forEach(function (e) {
							res[e] = 0;
						})
						e.Entities.forEach(function (e) {
							if(lastThreeYears.indexOf(e.Year) > -1) {
								res[e.Year] = Math.round(Math.abs(e.ROCE*100));
							}
						});
						return res;
					});	
					var color_hash = {  0 : [lastThreeYears[2], "#00246c"],
						1 : [lastThreeYears[1], "#78af00"],
						2 : [lastThreeYears[0], "#0099d2"]
					}		
					// Draw grid
					function make_y_axis() {        
						return d3.svg.axis()
						.scale(y)
						.orient("left")
						.ticks(5)
					}		
					svg.append("g")         
						.attr("class", "Ygrid")
						.style("stroke-dasharray", ("3, 3"))
						.call(make_y_axis()
						.tickSize(-w, 0, 0)
						.tickFormat("")
					)   


					var sectorNames = d3.keys(data[0]).filter(function(key) { 
						return key !== "Country"; });
					data.forEach(function(d) {
						d.countries = sectorNames.map(function(name) { 
							return {name: name, value: +d[name]}; 
						});
					});  

					x0.domain(data.map(function(d) { return d.Country; }));
					x1.domain(sectorNames).rangeRoundBands([0, x0.rangeBand()]);
					y.domain([0, d3.max(data, function(d) { 
						return d3.max(d.countries, function(d) { return d.value; }); })]);

					svg.append("g")
						.attr("class", "x axis")
						.attr("transform", "translate(0," + h + ")")
						.call(xAxis);

					svg.append("g")
						.attr("class", "y axis")
						.attr("transform", "translate(-5," + 0 + ")")
						.call(yAxis)

					svg.append("g")         
						.attr("class", "grid")
						.call(yGrid);  

					var country = svg.selectAll(".country")
						.data(data)
						.enter().append("g")
						.attr("class", "number-value")
						.attr("transform", function(d) { return "translate(" + x0(d.Country) + ",0)"; }); 

					country.selectAll("rect")
						.data(function(d) { return d.countries; })
						.enter().append("rect")
						.attr("width", x1.rangeBand()) 
						.attr("x", function(d) { return x1(d.name); }) 
						.attr("y", function(d) { return y(d.value); }) 
						.attr("height", function(d) { return h - y(d.value); })
						.style("fill", function(d) { return color(d.name); });

					var pointlabels = country.selectAll(".pointlabels")
						.data(function(d) { return d.countries; })
						.enter().append("g")
						.attr("class", "pointlabels")
						.attr("transform", function(d) { 
							  return "translate(" + x1(d.name) + "," + y(d.value) + ")"; });

					pointlabels.append("text")
						.attr("dy", "-5")
						.attr("x", x1.rangeBand()/2)
						.attr("text-anchor", "middle")  
						.text(function(d) { return d.value; });

					// Add legend
					var centerLegend = 245;
					var topLegend = 35;
					var widthLegend = 14;
					var marginLeftLegend = 20;
					var marginTopLegend = 76;
					if ($(window).width() >=1600) {
						centerLegend = 350;
					}
					if ($(window).width() >=1440 && $(window).width() <1600) {
						centerLegend = 280;
					}
					if ($(window).width() >768 && $(window).width() <=1279) {
						centerLegend = 230;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					if ($(window).width() >=375 && $(window).width() <=768) {
						centerLegend = 175;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					
					var legend = svg.append("g")
						.data(data)
						.attr("class", "legend")
						.attr("x", w)
						// .attr("y", 50)
						.attr("height", 50)
						.attr("width", 300)
						.attr("transform", "translate(" + (w - centerLegend) + "," + (h-topLegend)+")");

					legend.selectAll('g').data(color.domain().slice().reverse())
						.enter()
						.append('g')
						.each(function(d, i) {
							var g = d3.select(this);
							g.append("rect")
								.attr("x", i * 68)
								.attr("y", 65)
								.attr("width", widthLegend)
								.attr("height", widthLegend)
								.style("fill", color_hash[String(i)][1]);

							g.append("text")
							.attr("x", i * 68 + marginLeftLegend)
							.attr("y", marginTopLegend)
							.attr("height",30)	
							.attr("width",100)
							.text(color_hash[String(i)][0]);
				  		});

					// add yAxis line custom
					var colX = svg.append("rect")
						.attr("x", 0)
						.attr("y", 0)
						.style('fill', '#dedede')	
						.attr("class", "rectColX")
						.attr("width", 1)
						.attr("height", h);
				// });
			}
			drawChartRoce();
			// Responses line chart
			function onResizeChartRoce() {
				var chart = $("#roceChart"),
				    aspect = chart.width() / chart.height(),
				    container = chart.parent();

				if (chart.height() == 0) {
					return;
				}
				var targetWidth = container.width();
				var svgs = $('#roceChart').find('svg');
				svgs.remove();
				drawChartRoce();

				var svg = $('#roceChart').find('svg')[0];
				if(typeof svg !== 'undefined'){
				    svg.setAttribute('width', targetWidth + 'px');
				    svg.setAttribute('height', Math.round(targetWidth / aspect) + 'px');

				    svg.setAttribute('viewBox', '0 0 ' + targetWidth + ' ' + Math.round(targetWidth / aspect));
				    svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');
				}
			}
			

			$(window).on("resize", function() {
				onResizeChartRoce();
			}).trigger("resize");


			
		}
	}
});

// Directive for group ROCE chart D3
directives.directive('groupChartZoom', function($timeout){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			// start function
			var itemCount = 3;
			$scope.$on('compareItemPopup', function (event, listCompareTag) {
				if (listCompareTag && listCompareTag.length > 1) {
					itemCount = listCompareTag.length;
					$timeout(function () {
						onResizeChartZoom();
					}, 100)
				}
			})

			function drawChartZoom(){
				// color for bar chart
				var color = d3.scale.ordinal()
					.range(["#00246c", "#78af00", "#0099d2"]);


				var inputH = 257;
				var inputTop = 15;
				if ($(window).width() >=375 && $(window).width() <=1279) {
					inputH = 227;
				}
				var margin = {top: inputTop, right: 0, bottom: 50, left: 25},
				w = $(".bottom-details").width() - margin.left - margin.right,
				h = inputH- margin.top - margin.bottom;

				var x0 = d3.scale.ordinal()
					.rangeRoundBands([0, w], .2);
				var x1 = d3.scale.ordinal();
				var y = d3.scale.linear()
					.range([h, 0]);

				var xAxis = d3.svg.axis()
					.scale(x0)  
					.orient("bottom");

				var yAxis = d3.svg.axis()
					.scale(y)
					.orient("left")
					.tickSize(-0,0,0)
					.ticks(6)

				var yGrid = d3.svg.axis()
					.scale(y)
					.orient("left")
					.ticks(5)
					.tickSize(-0, 0, 0)
					.tickFormat("")  

				var svg = d3.select("#zoomChart").append("svg")
					.attr("width", w + margin.left + margin.right)
					.attr("height", h + margin.top + margin.bottom)
					.append("g")
					.attr("transform", "translate(" + margin.left + "," + margin.top + ")");

					var listCompareTag = $scope.listCompareTag;
					if (listCompareTag == null || listCompareTag.length === 0) {
						return;
					}
					var type = $scope.titleSelectedCompare;
					if (type === 'DEBTOR DAYS') {
						type = 'DebtorDays';
					}

					var lastThreeYears = $scope.lastThreeYears;
					var data = listCompareTag.map(function (e, i) {
						var res = {};
						res.Country = i + 1 + '. ' + e.ClientName.split(' ')[0] + '...';
						lastThreeYears.forEach(function (e) {
							res[e] = 0;
						})
						e.Entities.forEach(function (e) {
							if(lastThreeYears.indexOf(e.Year) > -1) {
								res[e.Year] = Math.round(Math.abs(e[type]));

								if (type === 'ROCE') {
									res[e.Year] = Math.round(Math.abs(e[type] * 100));
								}
							}
						});
						return res;
					});

					var color_hash = {  0 : [lastThreeYears[2], "#00246c"],
						1 : [lastThreeYears[1], "#78af00"],
						2 : [lastThreeYears[0], "#0099d2"]
					}					

					// Draw grid
					function make_y_axis() {        
						return d3.svg.axis()
						.scale(y)
						.orient("left")
						.ticks(5)
					}		
					svg.append("g")         
						.attr("class", "Ygrid")
						.style("stroke-dasharray", ("3, 3"))
						.call(make_y_axis()
						.tickSize(-w, 0, 0)
						.tickFormat("")
					)   


					var sectorNames = d3.keys(data[0]).filter(function(key) { 
						return key !== "Country"; });
					data.forEach(function(d) {
						d.countries = sectorNames.map(function(name) { 
							return {name: name, value: +d[name]}; 
						});
					});  

					x0.domain(data.map(function(d) { return d.Country; }));
					x1.domain(sectorNames).rangeRoundBands([0, x0.rangeBand()]);
					y.domain([0, d3.max(data, function(d) { 
						return d3.max(d.countries, function(d) { return d.value; }); })]);

					svg.append("g")
						.attr("class", "x axis")
						.attr("transform", "translate(0," + h + ")")
						.call(xAxis);

					svg.append("g")
						.attr("class", "y axis")
						.attr("transform", "translate(-5," + 0 + ")")
						.call(yAxis)

					svg.append("g")         
						.attr("class", "grid")
						.call(yGrid);  

					var country = svg.selectAll(".country")
						.data(data)
						.enter().append("g")
						.attr("class", "number-value")
						.attr("transform", function(d) { return "translate(" + x0(d.Country) + ",0)"; }); 

					country.selectAll("rect")
						.data(function(d) { return d.countries; })
						.enter().append("rect")
						.attr("width", x1.rangeBand()) 
						.attr("x", function(d) { return x1(d.name); }) 
						.attr("y", function(d) { return y(d.value); }) 
						.attr("height", function(d) { return h - y(d.value); })
						.style("fill", function(d) { return color(d.name); });

					var pointlabels = country.selectAll(".pointlabels")
						.data(function(d) { return d.countries; })
						.enter().append("g")
						.attr("class", "pointlabels")
						.attr("transform", function(d) { 
							  return "translate(" + x1(d.name) + "," + y(d.value) + ")"; });

					pointlabels.append("text")
						.attr("dy", "-5")
						.attr("x", x1.rangeBand()/2)
						.attr("text-anchor", "middle")  
						.text(function(d) { return d.value; });

					// Add legend
					var centerLegend = 280;
					var topLegend = 25;
					var widthLegend = 14;
					var marginLeftLegend = 20;
					var marginTopLegend = 76;
					if ($(window).width() >=1600) {
						centerLegend = 280;
					}
					if ($(window).width() >=1440 && $(window).width() <1600) {
						centerLegend = 280;
					}
					if ($(window).width() >=375 && $(window).width() <=1279) {
						centerLegend = 230;
						topLegend = 40;
						widthLegend = 10;
						marginLeftLegend = 15;
						marginTopLegend = 74;
					}
					
					var legend = svg.append("g")
						.data(data)
						.attr("class", "legend")
						.attr("x", w)
						// .attr("y", 50)
						.attr("height", 50)
						.attr("width", 300)
						.attr("transform", "translate(" + (w - centerLegend) + "," + (h-topLegend)+")");

					legend.selectAll('g').data(color.domain().slice().reverse())
						.enter()
						.append('g')
						.each(function(d, i) {
							var g = d3.select(this);
							g.append("rect")
								.attr("x", i * 68)
								.attr("y", 65)
								.attr("width", widthLegend)
								.attr("height", widthLegend)
								.style("fill", color_hash[String(i)][1]);

							g.append("text")
							.attr("x", i * 68 + marginLeftLegend)
							.attr("y", marginTopLegend)
							.attr("height",30)	
							.attr("width",100)
							.text(color_hash[String(i)][0]);
				  		});

					// add yAxis line custom
					var colX = svg.append("rect")
						.attr("x", 0)
						.attr("y", 0)
						.style('fill', '#dedede')	
						.attr("class", "rectColX")
						.attr("width", 1)
						.attr("height", h);
				// });
			}
			drawChartZoom();
			// Responses line chart
			function onResizeChartZoom() {
				var chart = $("#zoomChart"),
				    aspect = chart.width() / chart.height(),
				    container = chart.parent();


				if (chart.height() == 0) {
					return;
				}

				var targetWidth = container.width();
				var svgs = $('#zoomChart').find('svg');
				svgs.remove();
				drawChartZoom();

				var svg = $('#zoomChart').find('svg')[0];
				if(typeof svg !== 'undefined'){
				    svg.setAttribute('width', targetWidth + 'px');
				    svg.setAttribute('height', Math.round(targetWidth / aspect) + 'px');

				    svg.setAttribute('viewBox', '0 0 ' + targetWidth + ' ' + Math.round(targetWidth / aspect));
				    svg.setAttribute('preserveAspectRatio', 'xMinYMin meet');
				}
			}
			

			$(window).on("resize", function() {
				onResizeChartZoom();
			}).trigger("resize");
			
		}
	}
});

// Directive for select table ui
directives.directive('selectable', function(){
	return {
		restrict: 'AE',
		priority: 10000,
		link: function ($scope, elem, attrs) {
			$("#selectable01").selectable({
				selected : function(event, ui) {
					angular.element(document.querySelector('.tool-tip-new.part-one')).css('display', "none");
			    		var topValueSelect = angular.element(document.querySelector('#selectable01 .ui-selected'));			    		
				   	var outerHeight = 0;
				   	$('#selectable01 tr.ui-selected').each(function() {
						outerHeight += $(this).outerHeight();
				   	});

				   	var totalBetter = topValueSelect[0].offsetTop + (outerHeight/2-24);
				   	$scope.textValuePartOne = "";

				   	angular.element(document.querySelector('.icon-sms.part-one')).css('top', totalBetter + "px");
				   	angular.element(document.querySelector('.icon-sms.part-one')).css('display', "block");

				   	angular.element(document.querySelector('.tool-tip-new.part-one')).css('top', totalBetter + 60 + "px");

				},
				stop: function() {
					
			      	}
			});

			$("#selectable02").selectable({
				selected : function(event, ui) {
					angular.element(document.querySelector('.tool-tip-new.part-two')).css('display', "none");
					var topValueSelect = angular.element(document.querySelector('#selectable02 .ui-selected'));			    		
				   	var outerHeight = 0;
				   	$('#selectable02 tr.ui-selected').each(function() {
						outerHeight += $(this).outerHeight();
				   	});

				   	var totalBetter2 = topValueSelect[0].offsetTop + (outerHeight/2-24);
				   	$scope.textValuePartTwo = "";

				   	angular.element(document.querySelector('.icon-sms.part-two')).css('top', totalBetter2 + "px");
				   	angular.element(document.querySelector('.icon-sms.part-two')).css('display', "block");

				   	angular.element(document.querySelector('.tool-tip-new.part-two')).css('top', totalBetter2 + 60 + "px");
				}
			});

			$scope.showPopupPartOne = function() {
				angular.element(document.querySelector('.tool-tip-new.part-one')).css('display', "block");
			}

			$scope.showPopupPartTwo = function() {
				angular.element(document.querySelector('.tool-tip-new.part-two')).css('display', "block");
			}

			$scope.cancelPopupPartOne = function() {
				angular.element(document.querySelector('.tool-tip-new.part-one')).css('display', "none");
				$scope.textValuePartOne = "";
			}

			$scope.cancelPopupPartTwo = function() {
				angular.element(document.querySelector('.tool-tip-new.part-two')).css('display', "none");
				$scope.textValuePartTwo = "";
			}



			
		}
	}
});

//format number input
directives.directive('format', function () {
    return {
        require: 'ngModel',
        link: function (scope, element, attr, ngModelCtrl) {
            function fromUser(text) {
            	if (text === "") {
            		return 0;
            	}
                if (text) {
                    var transformedInput = text.replace(/[^0-9]/g, '');

                    if (transformedInput !== text) {
                        ngModelCtrl.$setViewValue(transformedInput);
                        ngModelCtrl.$render();
                    }
                    return transformedInput;
                }
                return undefined;
            }            
            ngModelCtrl.$parsers.push(fromUser);
        }
    };
});

// cal compare percentage
function calCompare(current, last, isInteger) {  
	if(isInteger) {
		return ((current - last) / last) * 100;
	}
	return (current * 100 - last * 100) / 100;
}