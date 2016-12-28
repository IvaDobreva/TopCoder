import angular from 'angular'

(function() {
  'use strict'

  angular.module('tc.services').factory('UserPreferencesService', UserPreferencesService)

  UserPreferencesService.$inject = ['$http', 'logger', 'Restangular', 'CONSTANTS', 'ApiService', '$q']

  function UserPreferencesService($http, logger, Restangular, CONSTANTS, ApiService, $q) {
    var preferencesApi = ApiService.getApiServiceProvider('PREFERENCES')
    var service = {
      getEmailPreferences: getEmailPreferences,
      saveEmailPreferences: saveEmailPreferences
    }
    return service

    function getEmailPreferences(user) {
      return $q(function(resolve, reject) {
        preferencesApi.one('users', user.userId)
        .one('preferences', 'email').get()
        .then(function(resp) {
          resolve(resp.subscriptions)
        })
        .catch(function(err) {
          if (err.status === 404) {
            logger.debug('Member subscription not found')
            resolve()
            return
          }
          logger.error('Error getting member to subscription list', err)

          var errorStatus = 'FATAL_ERROR'
          reject({
            status: errorStatus,
            msg: err.errorMessage
          })
        })
      })
    }


    function saveEmailPreferences(user, preferences) {
      var settings = {
        firstName: user.firstName,
        lastName: user.lastName,
        subscriptions: {}
      }
      if (!preferences) {
        settings.subscriptions['TOPCODER_NL_GEN'] = true
      } else {
        settings.subscriptions = preferences
      }
      return $q(function(resolve, reject) {
        preferencesApi.one('users', user.userId)
        .customPUT({ param: settings }, 'preferences/email')
        .then(function(resp) {
          resolve(resp.subscriptions)
        })
        .catch(function(err) {
          logger.error('Error adding member to subscription list', err)

          var errorStatus = 'FATAL_ERROR'

          reject({
            status: errorStatus,
            msg: err.errorMessage
          })
        })
      })
    }
  }
})()
