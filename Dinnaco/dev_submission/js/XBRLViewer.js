'use strict';
// var app = angular.module('app', ['ngRoute','directives','ngDropdowns','ngDragDrop', 'angular.filter','ngSelectable', 'angular.less','bw.paging']);
var app = angular.module('app', ['ngRoute','directives','ngDropdowns','ngDragDrop', 'angular.filter']);

/**
 * app config route
 ***************************/

app.config(['$routeProvider',
    function($routeProvider) {
        var path = 'partials/';
        $routeProvider.
            when('/DashBoardPage', {
                templateUrl: path + 'DashBoardPage.html',
                controller: 'dashBoardPageCtrl'
            }).
            when('/DocummentDetailPage', {
                templateUrl: path + 'DocummentDetailPage.html',
                controller: 'documentDetailPageCtrl'
            }).
            when('/QueryStatusPage', {
                templateUrl: path + 'QueryStatusPage.html',
                controller: 'queryStatusPageCtrl'
            }).
            when('/FAQsPage', {
                templateUrl: path + 'FAQsPage.html',
                controller: 'fAQsPageCtrl'
            }).
            otherwise({
                redirectTo: '/DashBoardPage',
            });
    }
]);