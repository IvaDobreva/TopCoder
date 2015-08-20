function autoResize(iframe) {
    var newheight;
    var newwidth;

    if (document.getElementById) {
        newheight = iframe.contentWindow.document.body.scrollHeight;
    }
    iframe.height = (newheight < 600 ? 600 : newheight) + 100 + "px";
}
(function () {
    'use string';
    var CrowdExchangeAppDirectives = angular.module("CrowdExchangeAppDirectives", []);
    CrowdExchangeAppDirectives.filter("sanitize", [
        '$sce', function ($sce) {
            return function (htmlCode) {
                return $sce.trustAsHtml(htmlCode);
            };
        }
    ]);
    CrowdExchangeAppDirectives.directive('ngEnter', function () {
        return function (scope, element, attrs) {
            element.bind("keydown keypress", function (event) {
                if(event.which === 13) {
                    scope.$apply(function (){
                        scope.$eval(attrs.ngEnter);
                    });

                    event.preventDefault();
                }
            });
        };
    });
    CrowdExchangeAppDirectives.directive('ngJqtransform', function ($timeout) {
        return {
            priority: Number.MAX_SAFE_INTEGER, // execute first, before all other directives if any.
            restrict: "AE",
            link: function (scope, element, attrs) {
                $timeout(function () {
                    $(element).jqTransform({ imgPath: 'i/' });
                });
            }
        };
    });
    CrowdExchangeAppDirectives.directive('convertToNumber', function () {
        return {
            require: 'ngModel',
            link: function (scope, element, attrs, ngModel) {
                ngModel.$parsers.push(function (val) {
                    return parseInt(val, 10);
                });
                ngModel.$formatters.push(function (val) {
                    return '' + val;
                });
            }
        };
    });
    CrowdExchangeAppDirectives.directive("fileread", [
        function () {
            return {
                scope: {
                    fileread: "=",
                    filename: "="
                },
                link: function (scope, element, attributes) {
                    element.bind("change", function (changeEvent) {
                        if (!changeEvent.target.files.length) {
                            scope.$apply(function () {
                                scope.filename = "";
                                scope.fileread = null;
                            });
                            return;
                        }
                        var reader = new FileReader();
                        reader.onload = function (loadEvent) {
                            scope.$apply(function () {
                                scope.fileread = loadEvent.target.result;
                            });
                        };
                        scope.$apply(function () {
                            scope.filename = changeEvent.target.files[0].name;
                        });
                        reader.readAsDataURL(changeEvent.target.files[0]);
                    });
                }
            };
        }
    ]);
    CrowdExchangeAppDirectives.directive('filePicker', function () {
        return {
            priority: Number.MAX_SAFE_INTEGER, // execute first, before all other directives if any.
            restrict: 'AE',
            scope: {
                field: '@',
                model: '='
            },
            link: function (scope, element, attrs) {

                var fileInput = $(element).find("input[type=file]");
                setTimeout(function () {
                    $(element).find("input[type=text].file-name-input,.browse-link").click(function () {
                        fileInput.trigger('click');
                        fileInput.trigger('change');
                    });
                }, 10);
            }
        };
    });
    CrowdExchangeAppDirectives.directive('custTooltip', function () {
        return function (scope, element, attrs) {
            $(element).hover(function () {
                $(this).next().removeClass("hide");
            }, function () {
                $(this).next().addClass("hide");
            });
        };
    });
    CrowdExchangeAppDirectives.directive('tipText', function () {
        return function (scope, element, attrs) {
            $(element).hover(function () {
                $(".tip-text").addClass("hide");
                $(this).find(".tip-text").removeClass("hide");

                //event.stopPropagation();
            }, function () {
                $(this).find(".tip-text").addClass("hide");
            })
        };
    });
    CrowdExchangeAppDirectives.directive('ngElementReady', [
        function () {
            return {
                priority: Number.MAX_SAFE_INTEGER, // execute first, before all other directives if any.
                restrict: "A",
                link: function ($scope, $element, $attributes) {
                    $scope.$eval($attributes.ngElementReady); // execute the expression in the attribute.
                }
            };
        }
    ]);
    CrowdExchangeAppDirectives.directive('checkbox', function () {
        return {
            restrict: 'AE',
            require: 'ngModel',
            link: function (scope, element, attrs, ngModelController) {
                // when model change, update our view (just update the div content)
                ngModelController.$render = function () {
                    if (ngModelController.$viewValue)
                        $(element).addClass("checked");
                    else $(element).removeClass("checked");
                };

                // update the model then the view
                function updateModel() {
                    // call $parsers pipeline then update $modelValue
                    ngModelController.$setViewValue(!ngModelController.$viewValue);
                    // update the local view
                    ngModelController.$render();
                }

                $(element).click(function () {
                    updateModel();
                });

            }
        };
    });
    //dirrective for the search result list item
    CrowdExchangeAppDirectives.directive('searchItem', function ($compile, $templateCache) {
        //gets appropriate template for the search result
        var getTemplate = function (item) {
            var template;
            if (item instanceof Story) {
                template = $templateCache.get('searchItemStory.html');
            } else if (item instanceof Activity) {
                template = $templateCache.get('searchItemActivity.html');
            } else if (item instanceof UserViewModel) {
                template = $templateCache.get('searchItemMember.html');
            }
            return template;
        }
        var linker = function (scope, element, attrs) {
            element.html(getTemplate(scope.content)).show();
            scope.user = GLOBAL_CONFIG.currentUser;
            $compile(element.contents())(scope);
        }

        return {
            restrict: "E",
            link: linker,
            scope: {
                content: '='
            }
        };
    });
})();