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
        $scope.search = function(){
            var query = ($scope.searchQuery+'') || '';
            query = query.trim();
            if(query) $location.path('/search').search({q: query});
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