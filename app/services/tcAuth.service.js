import angular from 'angular'
import { getCurrentUser, logout as doLogout } from './userv3.service.js'

(function() {
  'use strict'

  angular.module('tc.services').factory('TcAuthService', TcAuthService)

  TcAuthService.$inject = ['CONSTANTS', '$rootScope', '$q', 'logger', '$timeout', 'UserService', 'AuthTokenService', 'Helpers', 'ApiService', 'store', '$http']

  function TcAuthService(CONSTANTS, $rootScope, $q, logger, $timeout, UserService, AuthTokenService, Helpers, ApiService, store, $http) {
    var service = {
      logout: logout,
      isAuthenticated: isAuthenticated
    }
    return service

    function logout() {
      // logout of all browsers
      return doLogout().then(function() {
        $rootScope.$broadcast(CONSTANTS.EVENT_USER_LOGGED_OUT)
        // resolve the promise
        return true
      })
    }

    function isAuthenticated() {
      return !!getCurrentUser() && !!AuthTokenService.getV2Token() && !!AuthTokenService.getTCSSOToken()
    }

  }
})()
