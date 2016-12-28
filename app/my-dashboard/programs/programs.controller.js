import angular from 'angular'

(function() {
  'use strict'

  angular.module('tc.myDashboard').controller('ProgramsController', ProgramsController)

  ProgramsController.$inject = [
    'UserService',
    'MemberCertService',
    'CONSTANTS',
    'logger',
    'ChallengeService',
    '$q',
    '$rootScope'
  ]

  function ProgramsController (UserService, MemberCertService, CONSTANTS, logger, ChallengeService, $q, $rootScope) {
    var vm = this
    vm.domain = CONSTANTS.domain
    vm.registered = false
    vm.loading = true
    vm.challenges = []
    vm.registerUser = registerUser
    var userId = UserService.getUserIdentity().userId

    activate()

    function activate() {

      MemberCertService.getMemberRegistration(userId, CONSTANTS.SWIFT_PROGRAM_ID)
      .then(function(res) {
        if (res == null) {
          vm.registered = false
          $rootScope.$on('IOS_REGISTER_USER', function() {
            vm.registerUser()
          })
          vm.loading = false
        } else {
          vm.registered = true
          loadChallenges()
        }
      })
      .catch(function(err) {
        vm.registered = false
        vm.loading = false

        logger.error('Could not get member cert registration data', err)
      })
    }



    function registerUser() {
      vm.loading = true
      return MemberCertService.registerMember(userId, CONSTANTS.SWIFT_PROGRAM_ID).then(function(data) {
        if (data && data.eventId && data.userId) {
          vm.registration = data
          vm.registered = true
          loadChallenges()
        } else {
          vm.loading = false
        }
      })
    }

    function loadChallenges() {
      ChallengeService.getChallenges({
        filter: 'platforms=ios&technologies=swift&status=active',
        limit: 3,
        offset: 0,
        orderBy: 'submissionEndDate asc'
      }).then(function(challenges) {
        if (challenges.length > 0) {
          vm.challenges = challenges.slice(0, 3)
          ChallengeService.processActiveDevDesignChallenges(vm.challenges)
        }
        vm.loading = false
      })
      .catch(function(err) {
        vm.loading = false

        logger.error('Could not get peer review (iOS and Swift) challenges', err)
      })
    }
  }
})()
