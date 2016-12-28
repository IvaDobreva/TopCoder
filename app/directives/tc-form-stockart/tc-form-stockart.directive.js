import angular from 'angular'
import _ from 'lodash'

(function() {
  'use strict'

  angular.module('tcUIComponents').directive('tcFormStockart', tcFormStockart)

  function tcFormStockart() {
    return {
      restrict: 'E',
      require: '^form',
      template: require('./tc-form-stockart')(),
      scope: {
        formStockarts: '='
      },
      link: function(scope, element, attrs, formController) {
        scope.submissionForm = formController

      },
      controller: ['$scope', function($scope) {
        var stockartId = 0
        var emptyStockart = {
          sourceUrl: ''
        }

        // Initialize stockart form data
        $scope.formStockarts = { 0: _.assign({id: 0}, angular.copy(emptyStockart)) }

        $scope.urlRegEx = new RegExp(/^(http(s?):\/\/)?(www\.)?[a-zA-Z0-9\.\-\_]+(\.[a-zA-Z]{2,3})+(\/[a-zA-Z0-9\_\-\s\.\/\?\%\#\&\=]*)?$/)

        $scope.createAdditionalStockartFieldset = function() {
          var newId = ++stockartId

          $scope.formStockarts[newId] = _.assign({ id: newId }, angular.copy(emptyStockart))
        }

        $scope.deleteStockartFieldset = function(index) {

          // If only one stockart fieldset is there, just reset the values
          // so that ng-repeat doesn't refresh and there is no UI flickering
          if (Object.keys($scope.formStockarts).length === 1) {
            $scope.submissionForm['photoURL' + index].$setPristine()
            $scope.formStockarts[index] = angular.copy(emptyStockart)

          } else {
            delete $scope.formStockarts[index]
          }
        }

        $scope.isButtonDisabled = function() {
          return _.some($scope.formStockarts, function(stockart) {
            return !stockart.sourceUrl
          })
        }
      }]
    }
  }
})()
