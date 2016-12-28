/*eslint no-undef:0*/
import angular from 'angular'

describe('JWT Interceptor Service', function() {
  var service
  var apiUrl = 'https://api.topcoder-dev.com/'

  var fakeAuthTokenService = {
      getV3Token: sinon.spy(function() {
        return 'v3Token'
      }),
      getV2Token: sinon.spy(function() {
        return 'v2Token'
      }),
      setV3Token: sinon.spy(function(token) {
        return
      }),
      refreshToken: function(idToken) {
        return idToken
      }
    },
    fakeTcAuthService = {
      isAuthenticated: function() {
        return false
      }
    },
    fakeState = {
      go: sinon.spy(function(param) {
        return
      }),
      href: sinon.spy(function(stateName, toParams, params) {
        return 'https://topcoder.com/' + stateName
      })
    },
    fakeWindow = {
      location: ''
    }

  beforeEach(function() {
    angular.mock.module('tc.services', function($provide) {
      $provide.value('AuthTokenService', fakeAuthTokenService)
      $provide.value('TcAuthService', fakeTcAuthService)
      $provide.value('$state', fakeState)
      $provide.value('$window', fakeWindow)
    })
    bard.inject(this, 'jwtHelper', 'CONSTANTS', 'AuthTokenService', '$state', '$window', 'JwtInterceptorService')
    service = JwtInterceptorService
  })

  it('should not add token for .html files', function() {
    var config = {
      url: apiUrl + '/test.html'
    }
    expect(service.getToken(config)).to.not.exist
  })

  describe('for un-authenticated users', function() {
    beforeEach(function() {
      bard.inject(this, 'TcAuthService')
      sinon.stub(TcAuthService, 'isAuthenticated').returns(false)
    })

    it('should not add token for /v3/challenges', function() {
      var config = {
        method: 'get',
        url: apiUrl + '/v3/challenges/?filter=status%3Dactive'
      }
      expect(service.getToken(config)).to.not.exist
      expect(TcAuthService.isAuthenticated).to.be.have.been.calledOnce
    })

    it('should not add token for /v3.0.0-beta/challenges', function() {
      var config = {
        method: 'get',
        url: apiUrl + '/v3.0.0-beta/challenges/?filter=status%3Dactive'
      }
      expect(service.getToken(config)).to.not.exist
      expect(TcAuthService.isAuthenticated).to.be.have.been.calledOnce
    })

    it('should return null as token for other endpoints', function() {
      var config = {
        method: 'get',
        url: apiUrl + '/v3/members/test'
      }
      var token = service.getToken(config)
      expect(TcAuthService.isAuthenticated).to.be.have.been.calledOnce
      expect(token).to.be.null
    })

    it('should return null as token for other endpoints', function() {
      var config = {
        method: 'get',
        url: apiUrl + '/v3.0.0-BETA/members/test'
      }
      var token = service.getToken(config)
      expect(TcAuthService.isAuthenticated).to.be.have.been.calledOnce
      expect(token).to.be.null
    })

    afterEach(function() {
      TcAuthService.isAuthenticated.restore()
    })
  })

})
