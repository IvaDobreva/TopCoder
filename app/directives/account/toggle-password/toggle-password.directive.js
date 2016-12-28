import angular from 'angular'

(function() {
  'use strict'

  angular.module('tcUIComponents').directive('togglePassword', togglePassword)

  function togglePassword() {
    return {
      restrict: 'E',
      require: '^form',
      template: require('./toggle-password')(),
      link: function(scope, element, attrs, formController) {
        var vm = scope.vm
        scope.currentPasswordDefaultPlaceholder = attrs.placeholder || 'Password'
        scope.currentPasswordPlaceholder = scope.currentPasswordDefaultPlaceholder
        vm.currentPassword = ''

        var currentPasswordInput = element.children()[0]

        element.bind('click', function(event) {
          currentPasswordInput.focus()
        })

        element.bind('keyup', function(event) {
          if (event.keyCode === 13) {
            currentPasswordInput.blur()
          }
        })

        vm.onCPFocus = function(event) {
          scope.currentPasswordPlaceholder = ''
          element.addClass('focus')
        }

        vm.onCPBlur = function(event) {
          var relatedTarget = angular.element(event.relatedTarget)
          element.removeClass('focus')

          // If you are blurring from the password input and clicking the checkbox
          if (relatedTarget.attr('type') === 'checkbox' && relatedTarget.attr('id') === 'currentPasswordCheckbox') {
            scope.currentPasswordPlaceholder = ''
            currentPasswordInput.focus()
          } else {
            if (vm.currentPassword === '' || vm.currentPassword === undefined) {
              scope.currentPasswordPlaceholder = scope.currentPasswordDefaultPlaceholder
              formController.currentPassword.$setPristine()
            }
          }
        }

        vm.toggleTypeAttribute = function() {
          var $currentPasswordInput = angular.element(currentPasswordInput)

          if ($currentPasswordInput.attr('type') === 'text') {
            $currentPasswordInput.attr('type', 'password')
          } else {
            $currentPasswordInput.attr('type', 'text')
          }
        }
      }
    }
  }
})()
