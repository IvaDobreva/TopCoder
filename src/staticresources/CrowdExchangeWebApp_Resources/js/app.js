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
              //route for the Member Dashboard page
            .when('/memberdashboard', {      
                templateUrl: '/apex/CrowdExchangeWebApp_MemberDashboard',
                caseInsensitiveMatch: true
            })   
            //route for the Publisher Dashboard page
            .when('/publisherdashboard', {          
                templateUrl: '/apex/CrowdExchangeWebApp_PublisherDashboard',
                caseInsensitiveMatch: true  
            })
            //route for the Publisher Member Profile page
            .when('/publishermemberprofile/:userid', { 
                templateUrl: function(params){
                         return '/apex/CrowdExchangeWebApp_PubMemProfile?id='+params.userid
                    },
                caseInsensitiveMatch: true  
            }) 
            //route for the Member Member Profile page
            .when('/membermemberprofile/:userid', {  
                templateUrl: function(params){
                         return '/apex/CrowdExchangeWebApp_MemMemProfile?id='+params.userid
                    },                         
                caseInsensitiveMatch: true  
            })          
            //route for the Member My Profile page
            .when('/membermyprofile', {  
                templateUrl: '/apex/CrowdExchangeWebApp_MemberMyProfile',
                caseInsensitiveMatch: true  
            }) 
            //route for the Member My Profile page
            .when('/publishermyprofile', {    
                templateUrl: '/apex/CrowdExchangeWebApp_PublisherMyProfile',
                caseInsensitiveMatch: true    
            })
            //route for the Member Member Profile page
            .when('/memberpublisherprofile/:userid', {  
                templateUrl: function(params){
                         return '/apex/CrowdExchangeWebApp_MemPubProfile?id='+params.userid
                    },                         
                caseInsensitiveMatch: true  
            }) 
            .otherwise({ redirectTo: '/Stories' });

    }]);

})();