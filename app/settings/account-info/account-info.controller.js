import angular from 'angular'
import _ from 'lodash'

(function () {
  'use strict'

  angular.module('tc.settings').controller('AccountInfoController', AccountInfoController)

  AccountInfoController.$inject = ['userData', 'UserService', 'ProfileService', 'logger', 'ISO3166', 'toaster', '$scope', '$timeout', '$state']

  function AccountInfoController(userData, UserService, ProfileService, logger, ISO3166, toaster, $scope, $timeout, $state) {
    var vm = this
    vm.saveAccountInfo   = saveAccountInfo
    vm.updateCountry     = updateCountry
    vm.submitNewPassword = submitNewPassword
    vm.getAddr = getAddr

    activate()

    function activate() {
      vm.isSocialRegistrant = false
      vm.loading = true

      vm.formProcessing = {
        accountInfoForm: false,
        newPasswordForm: false
      }

      vm.userData = userData.clone()
      processData(vm.userData)

      UserService.getUserProfile({fields: 'credential'})
      .then(function(res) {
        vm.isSocialRegistrant = !res.credential.hasPassword
        vm.loading = false
      })
      .catch(function(err) {
        logger.info('Error fetching user profile. Redirecting to edit profile.')
        logger.error('Could not fetch user profile data', err)

        $state.go('settings.profile')

        vm.loading = false
      })

      vm.countries = ISO3166.getAllCountryObjects()
      vm.countryObj = ISO3166.getCountryObjFromAlpha3(vm.userData.homeCountryCode)

      // Timeout needed since newPasswordForm.currentPassword doesn't exist until later
      $timeout(function(){
        $scope.$watch('vm.currentPassword', function(newValue, oldValue) {
          if (vm.newPasswordForm && vm.newPasswordForm.currentPassword.$error.incorrect) {
            // If the API returns 'incorrect password',
            // remove the error once the user types again.
            if (newValue !== oldValue) {
              vm.newPasswordForm.currentPassword.$setValidity('incorrect', true)
            }
          }
        })
      }, 400)
    }

    function updateCountry(angucompleteCountryObj) {
      var countryCode = _.get(angucompleteCountryObj, 'originalObject.alpha3', undefined)

      var isValidCountry = _.isUndefined(countryCode) ? false : true
      vm.accountInfoForm.country.$setValidity('required', isValidCountry)
      vm.isValidCountry = isValidCountry
      if (isValidCountry) {
        vm.userData.homeCountryCode = countryCode
      }
    }

    function getAddr() {
      var add = vm.homeAddress
      if (add.streetAddr1 && add.city && add.zip) {
        add.type = add.type || 'home'
        return [add]
      } else {
        return []
      }
    }

    function saveAccountInfo() {
      vm.formProcessing.accountInfoForm = true
      vm.userData.addresses = getAddr()
      ProfileService.updateUserProfile(vm.userData)
      .then(function(data) {
        vm.formProcessing.accountInfoForm = false
        toaster.pop('success', 'Success!', 'Your account information was updated.')
        for (var k in vm.userData) userData[k] = vm.userData[k]
        vm.accountInfoForm.$setPristine()
      })
      .catch(function(err) {
        logger.error('Could not update user profile', err)

        vm.formProcessing.accountInfoForm = false

        toaster.pop('error', 'Whoops!', 'Something went wrong. Please try again later.')
      })
    }

    function processData(userData) {
      vm.homeAddress = _.find(userData.addresses, {type: 'HOME'}) || {}
    }

    function submitNewPassword() {
      vm.formProcessing.newPasswordForm = true

      UserService.updatePassword(vm.password, vm.currentPassword)
      .then(function(res) {
        vm.formProcessing.newPasswordForm = false
        vm.password = ''
        vm.currentPassword = ''
        toaster.pop('success', 'Success', 'Password successfully updated')
        vm.newPasswordForm.$setPristine()
        vm.currentPasswordFocus = false

        logger.info('Your password has been updated.')
      })
      .catch(function(err) {
        logger.error('Could not update password', err)

        vm.formProcessing.newPasswordForm = false
        vm.newPasswordForm.currentPassword.$setValidity('incorrect', false)
      })
    }
  }
})()
