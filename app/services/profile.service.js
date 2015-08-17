(function() {
  'use strict';

  angular.module('tc.services').factory('ProfileService', ProfileService);

  ProfileService.$inject = ['CONSTANTS', 'ApiService', 'UserService', '$q'];

  function ProfileService(CONSTANTS, ApiService, UserService, $q) {

    var restangular = ApiService.restangularV3;

    var service = {
      // primary, for global use
      getUserProfile: getUserProfile,
      getUserSkills: getUserSkills,
      getUserFinancials: getUserFinancials,
      getUserStats: getUserStats,
      // auxiliary functions for profile
      getNumProjects: getNumProjects,
      getNumWins: getNumWins,
      getRanks: getRanks,
      getChallengeTypeStats: getChallengeTypeStats,
      getTracks: getTracks,
      getSubTracks: getSubTracks,
      // for profile - to be deprecated
      getMockMemberProfile: getMockMemberProfile
    };
    return service;

    ///////////////

    function getUserProfile(username) {
      return restangular.one('members', username).get();
    }

    function getUserSkills(username) {
      return restangular.one('members', username).one('skills').get();
    }

    function getUserFinancials(username) {
      return restangular.one('members', username).one('financial').get();
    }

    function getUserStats(username) {
      return restangular.one('members', username).one('stats').get();
    }

    function getNumProjects(stats) {
      return stats.developStats.challenges +
             stats.designStats.challenges +
             stats.dataScienceStats.challenges;
    }

    function getNumWins(stats) {
      return stats.developStats.wins +
             stats.designStats.wins +
             stats.dataScienceStats.wins;
    }

    function getRanks(stats) {
      if (!stats) {
        return [];
      }
      var dev = [], design = [], srm = [], marathon = [], copilot = [];
      if (stats.developStats && stats.developStats.rankStats) {
        dev = stats.developStats.rankStats.map(function(x) {
          return {
            'track': 'Develop',
            'subTrack': x.subTrackName.trim(),
            'rank': x.overallRank
          };
        });
      }
      // show # of wins for design
      if (stats.designStats && stats.designStats.submissionStats) {
        design = stats.designStats.submissionStats.map(function(x) {
          return {
            'track': 'Design',
            'subTrack': x.subTrackName,
            'rank': false,
            'wins': x.wins
          };
        });
      }
      if (stats.dataScienceStats && stats.dataScienceStats.srmStats && stats.dataScienceStats.srmStats.rankStats) {
        srm = stats.dataScienceStats.srmStats.rankStats.map(function(x) {
          return {
            'track': 'Data Science',
            'subTrack': 'SRM',
            'rank': x.rank
          };
        });
      }
      if (stats.dataScienceStats && stats.dataScienceStats.marathonMatchStats && stats.dataScienceStats.marathonMatchStats.rankStats) {
        marathon = stats.dataScienceStats.marathonMatchStats.rankStats.map(function(x) {
          return {
            'track': 'Data Science',
            'subTrack': 'Marathon',
            'rank': x.rank
          };
        });
      }
      if (stats.copilotStats) {
        copilot = stats.copilotStats;
        copilot.track = 'Co-Pilot';
      }
      var ans = dev.concat(design)
        .concat(srm)
        .concat(marathon)
        .concat(stats.copilotStats)
        .filter(function(x) {
          return x && (x.rank || x.wins || x.fulfillment);
        });
      return ans;
    }

    function getChallengeTypeStats(stats, track, type) {
      track = track.toLowerCase().replace(/ /g, '');
      type = type.toLowerCase().replace(/ /g, '');
      if (track == 'develop') {
        var ans = stats[track + 'Stats']['rankStats'].filter(function(x) {
          return type === x.subTrackName.toLowerCase().replace(/ /g, '');
        });
        ans[0].challenges = stats[track + 'Stats']['challengeStats'].filter(function(x) {
          return type === x.subTrackName.toLowerCase().replace(/ /g, '');
        })[0].challenges;
        ans[0].detailed = stats[track + 'Stats']['submissionStats'].filter(function(x) {
          return type === x.subTrackName.toLowerCase().replace(/ /g, '');
        })[0];
        return ans[0];

      } else if (track == 'design') {
        var ans = stats[track + 'Stats']['submissionStats'].filter(function(x) {
          return type === x.subTrackName.toLowerCase().replace(/ /g, '');
        });
        return ans[0];

      } else if (track == 'co-pilot') {
        var ans = stats.copilotStats;
        return ans;
      } else if (type == 'srm') {
        return stats.dataScienceStats.srmStats.rankStats[0];
      } else {
        return stats.dataScienceStats.marathonMatchStats.rankStats[0];
      }
    }

    function getSubTracks(stats, track) {
      track = track.toLowerCase().replace(/ /g, '');
      if (track == 'develop') {
        var ans = stats[track + 'Stats']['rankStats'].map(function(x) {
          return x.subTrackName;
        });
        return ans;
      } else if (track == 'design') {
        var ans = stats[track + 'Stats']['submissionStats'].map(function(x) {
          return x.subTrackName;
        });
        return ans;
      }
    }

    function getTracks(stats) {
      var tracks = [
        {
          'name': 'DEVELOP',
          'challenges': stats.developStats.challenges,
        },
        {
          'name': 'DESIGN',
          'challenges': stats.designStats.challenges,
        },
        {
          'name': 'DATA',
          'challenges': stats.dataScienceStats.challenges,
        }
      ].filter(function(track) {
        return track.challenges > 0;
      }).map(function(track) {
        return track.name;
      });
      return tracks;
    }

    function getMockMemberProfile() {
      if (!service.memberProfile) {
        service.memberProfile = {
          "links": [
            {
              "name": "Github",
              "logo": "git-logo.png",
              "properties": [
                {
                  "name": "Repos",
                  "value": 20
                },
                {
                  "name": "Followers",
                  "value": 10
                }
              ]
            },
            {
              "name": "Stack Overflow",
              "logo": "stackoverflow-logo.png",
              "properties": [
                {
                  "name": "Reputation",
                  "value": 200
                },
                {
                  "name": "Questions",
                  "value": 102
                },
                {
                  "name": "Answers",
                  "value": 2001
                }
              ]
            }
          ]
        };
      }
      return service.memberProfile;
    }
  }

})();
