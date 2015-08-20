(function () {
    'use string';
    var CrowdExchangeAppServices = angular.module("CrowdExchangeAppServices", ['ui.bootstrap', 'dialogs.main']);
    //function for wrapping SFDC Remote methods in promise
    var getStandardCallback = function (deferred) {
        var callback = function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event.message);
            }
        };
        return callback;
    };
    CrowdExchangeAppServices.factory('dataServices', function ($http, $q, $sce, $compile, $timeout) {
        return {
            getStories: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.getStories(request, getStandardCallback(deferred));
                return deferred.promise;
            },
            getStory: function (id, deep) {
                var deferred = $q.defer();
                CE_RemoteController.getStory(id, deep || false, getStandardCallback(deferred));
                return deferred.promise;
            },
            registerToActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.registerToActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            upsertStory: function (story) {
                var deferred = $q.defer();
                CE_RemoteController.upsertStory(story, getStandardCallback(deferred));
                return deferred.promise;
            },
            getDefaultSkills: function () {
                var deferred = $q.defer();
                CE_RemoteController.getDefaultSkills(getStandardCallback(deferred));
                return deferred.promise;
            },
            getActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.getActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            createActivity: function (activity) {
                var deferred = $q.defer();
                CE_RemoteController.createActivity(activity, getStandardCallback(deferred));
                return deferred.promise;
            },
            upsertActivity: function (activity) {
                var deferred = $q.defer();
                CE_RemoteController.upsertActivity(activity, getStandardCallback(deferred));
                return deferred.promise;
            },
            cancelActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.cancelActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            completeActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.completeActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            cancelStory: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.cancelStory(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            deleteDocument: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.deleteDocument(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            emailToMember: function (ids) {
                var deferred = $q.defer();
                CE_RemoteController.emailToMember(ids, getStandardCallback(deferred));
                return deferred.promise;
            },
            assignMember: function (activityId, userId) {
                var deferred = $q.defer();
                CE_RemoteController.assignMember(activityId, userId, getStandardCallback(deferred));
                return deferred.promise;
            },
            unassignMember: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.unassignMember(activityId, getStandardCallback(deferred));
                return deferred.promise;
            },
            getRecommendedMembers: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.getRecommendedMembers(activityId, getStandardCallback(deferred));
                return deferred.promise;
            },
            getRegistrants: function (activityId, page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getRegistrants(activityId, page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getAssignedMember: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.getAssignedMember(activityId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            deleteActivity: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.deleteActivity(activityId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getUnreadNotificationsCount: function () {
                var deferred = $q.defer();
                CE_RemoteController.getUnreadNotificationsCount(getStandardCallback(deferred));
                return deferred.promise;
            },
            getInboxNotifications: function (page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getInboxNotifications(page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getOutboxNotifications: function (page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getOutboxNotifications(page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            markNotificationAsRead: function (notificationId) {
                var deferred = $q.defer();
                CE_RemoteController.markNotificationAsRead(notificationId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            archiveNotification: function (notificationId) {
                var deferred = $q.defer();
                CE_RemoteController.archiveNotification(notificationId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchMembers: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchMembers(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchActivities: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchActivities(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchStories: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchStories(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            search: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.search(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getPublisherActivities: function () {
                var deferred = $q.defer();
                CE_RemoteController.getPublisherActivities(getStandardCallback(deferred));
                return deferred.promise;
            },
            uploadAttachment: function (att) {
                var attachment = new sforce.SObject('Attachment');
                attachment.Name = att.name;
                attachment.Description = att.description;
                attachment.ContentType = att.type;
                attachment.Body = att.body;
                attachment.ParentId = att.parentId;
                var deferred = $q.defer();
                var result = sforce.connection.create([attachment], {
                    // This method gets called when file upload is in progress
                    progress: function (oEvent) {
                        if (oEvent.lengthComputable) {
                            var percentComplete = parseInt(oEvent.loaded / oEvent.total) * 100;
                            deferred.notify(percentComplete);
                        }
                        else {
                            // Unable to compute progress information since the total size is unknown
                        }
                    },
                    onSuccess: function (success) {
                        deferred.resolve(success);
                    },
                    onFailure: function (failure) {
                        deferred.reject(failure);
                    }
                });
                return deferred.promise;
            },
            trustAsResourceUrl: function (url) {
                return $sce.trustAsResourceUrl(url);
            },
            renderStringTemplate: function (template, scope) {
                var deferred = $q.defer();
                $timeout(function () {
                    var linkFn = $compile(template);
                    var linkedContent = linkFn(scope);
                    scope.$apply();
                    deferred.resolve(linkedContent.html());
                }, 0);

                return deferred.promise;
            }

        };
    });
    CrowdExchangeAppServices.factory('dialogsService', ['dialogs', function (dialogs) {
        return {
            showArchiveNotificationConfirm: function () {
                return dialogs.create('archiveNotificationConfirm.html', 'ceConfirmDialogCtrl', {}, 'lg');
            },
            showRegistrationConfirm: function () {
                return dialogs.create('registrationConfirm.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showLoading: function () {
                return dialogs.create('loadingDialog.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showSavingDraftActivity: function () {
                return dialogs.create('savingActivityAsDraft.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showFileUploading: function (model) {
                return dialogs.create('fileUploadModal.html', 'ceConfirmDialogCtrl', model || {}, 'lg');
            },
            showCancelActivity: function (activityName) {
                return dialogs.create('cancelActivity.html', 'ceConfirmDialogCtrl', { activityName: activityName }, 'lg');
            },
            showAssignMember: function (activityName, userName) {
                return dialogs.create('assignMember.html', 'ceConfirmDialogCtrl', { activityName: activityName, userName: userName }, 'lg');
            },
            showPublisherSelectActivity: function () {
                return dialogs.create('publisherSelectActivity.html', 'pubSelectActivityCtrl', {}, 'lg');
            }
        };
    }]);
    CrowdExchangeAppServices.controller('pubSelectActivityCtrl', function ($log, $scope, $modalInstance, data, dataServices) {
        if (data) jQuery.extend($scope, data);
        $scope.isLoading = true;
        $scope.activities = [];
        dataServices.getPublisherActivities().then(function (data) {
            $scope.activities = data;
            $scope.isLoading = false;
        }, function (error) {
            $modalInstance.close(undefined);
        });
        $scope.selectActivity = function (activity) {
            $modalInstance.close(activity);
        }
        $scope.cancel = function () {
            $modalInstance.close(undefined);
        };

    }); // end customDialogCtrl
    CrowdExchangeAppServices.controller('ceConfirmDialogCtrl', function ($log, $scope, $modalInstance, data) {
        if (data) jQuery.extend($scope, data);
        $scope.no = function () {
            $modalInstance.close(false);
        };
        $scope.yes = function () {
            $modalInstance.close(true);
        }; // end done
    }); // end customDialogCtrl

    CrowdExchangeAppServices.config(function (dialogsProvider) {
        // this provider is only available in the 4.0.0+ versions of angular-dialog-service
        dialogsProvider.useBackdrop(false);
        dialogsProvider.useEscClose(true);
        dialogsProvider.useCopy(true);
        dialogsProvider.setSize('lg');
        dialogsProvider.useAnimation(true);
    }); // end config
})();
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
(function () {
    'use strict';
    var CrowdExchangeAppControllers = angular.module('CrowdExchangeAppControllers', ['ngRoute']);
    // Main controller for the header and footer areas
    CrowdExchangeAppControllers.controller('mainController', function ($scope, $location, $interval, dataServices) {
        $scope.notificationsCount = 0;
        $scope.user = GLOBAL_CONFIG.currentUser;
        $scope.$on('$locationChangeSuccess', function (event) {
            $scope.locationPath = $location.path().toLowerCase();
        });
        $scope.searchQuery = '';
        var updateInterval = 1000 * (GLOBAL_CONFIG.notificationsCounterUpdateInterval || 30); //If iterval wasn't set we set it to 30 seconds
        var updateNotificationsCounter = function () {
            dataServices.getUnreadNotificationsCount().then(function (count) {
                $scope.notificationsCount = count;
            });
        };
        $scope.search = function () {
            $location.path('/search').search({ q: $scope.searchQuery });
        }
        updateNotificationsCounter();
        $interval(function () {
            updateNotificationsCounter();
        }, updateInterval);
    });
    // Controller for the member's dashboard
    CrowdExchangeAppControllers.controller('memberDashboard', function ($scope, dialogs) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        $scope.isInitialized = true;
    });
    // Controller for the member's story details page
    CrowdExchangeAppControllers.controller('memberStoryDetails', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        $scope.vm = new StoryDetailsViewModel({
            id: $routeParams.id,
            service: dataServices,
            dialogs: dialogsService
        });
        $scope.isInitialized = true;
    });
    //Controller for the publisher's activity details page
    CrowdExchangeAppControllers.controller('publisherActivityDetailsAssignRegister', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        var tab = $routeParams.tab;
        if (tab) tab = tab.toLowerCase();
        dataServices.getActivity($routeParams.id).then(function (data) {
            $scope.vm = new ActivityViewModel(data, {
                service: dataServices,
                dialogs: dialogsService
            });
            if (tab) {
                if (tab === 'registrants')
                    $scope.vm.selectTab(1);
                else if (tab === 'submissions')
                    $scope.vm.selectTab(4);
            }
            $scope.isInitialized = true;
        });
    });
    //Controller for the member's activity details page
    CrowdExchangeAppControllers.controller('memberActivityAssignAssigned', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        var tab = $routeParams.tab;
        if (tab) tab = tab.toLowerCase();
        dataServices.getActivity($routeParams.id).then(function (data) {
            $scope.vm = new ActivityViewModel(data, {
                service: dataServices,
                dialogs: dialogsService
            });
            if (tab) {
                if (tab === 'registrants')
                    $scope.vm.selectTab(1);
                else if (tab === 'submissions')
                    $scope.vm.selectTab(4);
            }
            $scope.isInitialized = true;
        });
    });
    //Controller for the publisher's activity review details page
    CrowdExchangeAppControllers.controller('publisherActivityDetailsCompetitionReview', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        var tab = $routeParams.tab;
        if (tab) tab = tab.toLowerCase();
        dataServices.getActivity($routeParams.id).then(function (data) {
            $scope.vm = new ActivityViewModel(data, {
                service: dataServices,
                dialogs: dialogsService
            });
            if (tab) {
                if (tab === 'registrants')
                    $scope.vm.selectTab(1);
                else if (tab === 'submissions')
                    $scope.vm.selectTab(4);
            }
            $scope.isInitialized = true;
        });
    });
    //Controller for the Add/Edit Activity pages
    CrowdExchangeAppControllers.controller('publisherAddEditActivity', function ($scope, dataServices, dialogsService, isEdit, $routeParams, $location) {
        $scope.isInitialized = false;
        $scope.vm = {};
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        if (isEdit) {
            dataServices.getActivity($routeParams.id).then(function (data) {
                $scope.vm = new ActivityViewModel(data, {
                    service: dataServices,
                    dialogs: dialogsService,
                    navigation: $location
                });
                dataServices.getDefaultSkills().then(function (data) {
                    $scope.vm.setDefaultCodeTypes(data);
                    $scope.defaultSkills = data;
                });
                $scope.isInitialized = true;
            });
        } else {
            var vm = new ActivityViewModel(null, {
                service: dataServices,
                dialogs: dialogsService
            });
            $scope.vm = vm;
            dataServices.getStory($routeParams.id).then(function (data) {
                $scope.vm.story = data;
                $scope.isInitialized = true;
            });
            dataServices.getDefaultSkills().then(function (data) {
                $scope.vm.setDefaultCodeTypes(data);
                $scope.defaultSkills = data;
            });
        }
    });
    //Controller for the Create story wizard page
    CrowdExchangeAppControllers.controller('publisherCreateStory', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        var vm = new CreateStoryViewModel({
            service: dataServices,
            dialogs: dialogsService
        });
        $scope.defaultSkills = [];
        $scope.vm = vm;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.global = GLOBAL_CONFIG;
        dataServices.getDefaultSkills().then(function (data) {
            $scope.defaultSkills = data;
        });
        $scope.$watch('vm.story.activities.length', function () {
            $scope.vm.stepsCount = vm.story.activities.length + 2;
        });
        $scope.isInitialized = true;
    });
    //Contorller for the publisher's story details page
    CrowdExchangeAppControllers.controller('publisherStoryDetails', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.vm = new StoryPublisherDetailsViewModel({
            id: $routeParams.id,
            service: dataServices,
            dialogs: dialogsService
        });
        $scope.isInitialized = true;
    });
    //Controller for the stories list page
    CrowdExchangeAppControllers.controller('stories', function ($scope, dataServices) {
        $scope.isInitialized = false;
        $scope.Math = window.Math;
        $scope.today = new Date();
        $scope.user = GLOBAL_CONFIG.currentUser;
        $scope.vm = new StoriesViewModel(dataServices);
        $scope.isInitialized = true;
    });
    // Controller for the Notifications page
    CrowdExchangeAppControllers.controller('notifications', function ($scope, dataServices, dialogsService, $routeParams) {

        $scope.isInitialized = false;
        $scope.user = GLOBAL_CONFIG.currentUser;

        $scope.vm = new NotificationsViewModel({
            service: dataServices,
            dialogs: dialogsService
        });
        $scope.isInitialized = true;
    });
    //Controller for the stories list page
    CrowdExchangeAppControllers.controller('search', function ($scope, dataServices, dialogsService, $routeParams) {
        $scope.isInitialized = false;
        $scope.SearchTabs = SearchTabs;
        $scope.Math = window.Math;
        $scope.user = GLOBAL_CONFIG.currentUser;
        $scope.vm = new SearchViewModel({
            service: dataServices,
            dialogs: dialogsService
        });
        $scope.vm.oldQuery = $routeParams.q;
        $scope.vm.search();
        $scope.isInitialized = true;

    });
})();
(function () {
    'use strict';
    // create the module and name it CrowdExchangeApp
    var CrowdExchangeApp = angular.module('CrowdExchangeApp', ['ngRoute', 'CrowdExchangeAppServices', 'CrowdExchangeAppDirectives', 'CrowdExchangeAppControllers', 'ui.date', 'ngLocale', 'ui.select', 'angularUtils.directives.dirPagination']);
    CrowdExchangeApp.run(function ($rootScope) {
        $rootScope.GLOBAL = GLOBAL_CONFIG;
    });
    CrowdExchangeApp.config(function ($compileProvider) {
        $compileProvider.aHrefSanitizationWhitelist(/^\s*(https?|ftp|mailto|file|javascript):/);
    });
    // configure our routes
    CrowdExchangeApp.config(["$routeProvider", "$locationProvider", function ($routeProvider) {
        $routeProvider
            // route for the home page
            .when('/Stories', {
                templateUrl: '/apex/CrowdExchangeWebApp_Stories',
                controller: 'stories',
                caseInsensitiveMatch: true
            })
            // 
            .when('/memberStoryDetails/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_MemberStoryDetails',
                controller: 'memberStoryDetails',
                caseInsensitiveMatch: true
            })
            // 
            .when('/publisherActivityDetailsAssignRegister/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubActivityAssign',
                controller: 'publisherActivityDetailsAssignRegister',
                caseInsensitiveMatch: true
            })
            // 
            .when('/publisherActivityDetailsCompetitionReview/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubActivityReview',
                controller: 'publisherActivityDetailsCompetitionReview',
                caseInsensitiveMatch: true
            })
            .when('/memberActivityAssignAssigned/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_MemActivityAssigned',
                controller: 'memberActivityAssignAssigned',
                caseInsensitiveMatch: true
            })
            // 
            .when('/publisherAddActivity/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubAddActivity',
                controller: 'publisherAddEditActivity',
                caseInsensitiveMatch: true,
                resolve: {
                    isEdit: function () {
                        return false;
                    }
                }
            })
            .when('/publisherEditActivity/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubAddActivity',
                controller: 'publisherAddEditActivity',
                caseInsensitiveMatch: true,
                resolve: {
                    isEdit: function () {
                        return true;
                    }
                }
            })
            // 
            .when('/publisherCreateStory', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubCreateStory',
                controller: 'publisherCreateStory',
                caseInsensitiveMatch: true
            })
            // 
            .when('/publisherStoryDetails/:id', {
                templateUrl: '/apex/CrowdExchangeWebApp_PubStoryDetails',
                controller: 'publisherStoryDetails',
                caseInsensitiveMatch: true
            })
            // route for the notifications page
            .when('/Notifications', {
                templateUrl: '/apex/CrowdExchangeWebApp_Notifications',
                controller: 'notifications',
                caseInsensitiveMatch: true
            })
            //route for the search page
            .when('/search', {
                templateUrl: '/apex/CrowdExchangeWebApp_Search',
                controller: 'search',
                caseInsensitiveMatch: true
            })
            .otherwise({ redirectTo: '/Stories' });

    }]);

})();
