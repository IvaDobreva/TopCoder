import angular from 'angular'

(function() {
  'use strict'

  // @desc links data card directive
  // @example <external-links-data></external-links-data>
  angular.module('tcUIComponents').directive('externalLinksData', externalLinksData)

  function externalLinksData() {
    var directive = {
      restrict: 'E',
      template: require('./external-links-data')(),
      scope: {
        linkedAccountsData: '=',
        editable: '=',
        userHandle: '@'
      },
      controller: ['logger', '$scope', '$window', '$filter', 'ExternalWebLinksService', 'toaster', 'ngDialog',
        function(logger, $scope, $window, $filter, ExternalWebLinksService, toaster, ngDialog) {
          $scope.deletionDialog = null

          $scope.openLink = function(account) {
            var url = null
            if (account) {
              if (account.data && account.data.profileURL && account.data.status !== 'PENDING') {
                url = account.data.profileURL
              }
              if (account.URL && account.status !== 'PENDING') {
                url = account.URL
              }
            }
            if (url) {
              $window.open($filter('urlProtocol')(url), '_blank')
            }
          }

          $scope.confirmDeletion = function(account) {
            // for non weblink provider, do nothing
            if (account.provider !== 'weblink') {
              return
            }
            // do nothing for pending state cards
            if (account.status === 'PENDING') {
              return
            }
            $scope.deletionDialog = ngDialog.open({
              plain: true,
              className: 'ngdialog-theme-default tc-dialog',
              template: require('./external-link-deletion-confirm')(),
              controller: 'ExternalLinkDeletionController',
              controllerAs: 'vm',
              resolve: {
                userHandle: function() {
                  return $scope.userHandle
                },
                account: function() {
                  return account
                },
                linkedAccountsData: function() {
                  return $scope.linkedAccountsData
                }
              }
            }).closePromise.then(function (data) {
              logger.debug('Closing deletion confirmation dialog.')
            })
          }
        }
      ]
    }
    return directive
  }
})()
