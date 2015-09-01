(function () {
    'use string';
    var CrowdExchangeAppServices = angular.module("CrowdExchangeAppServices", ['ui.bootstrap', 'dialogs.main']);
    //function for wrapping SFDC Remote methods in promise
    var getStandardCallback = function (deferred) {
        var callback = function (result, event) {
            if (event.status) {
                deferred.resolve(result);
            } else {
                deferred.reject(event.message);
            }
        };
        return callback;
    };
    CrowdExchangeAppServices.factory('dataServices', function ($http, $q, $sce, $compile, $timeout) {
        return {
            getStories: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.getStories(request, getStandardCallback(deferred));
                return deferred.promise;
            },
            getStory: function (id, deep) {
                var deferred = $q.defer();
                CE_RemoteController.getStory(id, deep || false, getStandardCallback(deferred));
                return deferred.promise;
            },
            registerToActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.registerToActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            upsertStory: function (story) {
                var deferred = $q.defer();
                CE_RemoteController.upsertStory(story, getStandardCallback(deferred));
                return deferred.promise;
            },
            getDefaultSkills: function () {
                var deferred = $q.defer();
                CE_RemoteController.getDefaultSkills(getStandardCallback(deferred));
                return deferred.promise;
            },
            getActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.getActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            createActivity: function (activity) {
                var deferred = $q.defer();
                CE_RemoteController.createActivity(activity, getStandardCallback(deferred));
                return deferred.promise;
            },
            upsertActivity: function (activity) {
                var deferred = $q.defer();
                CE_RemoteController.upsertActivity(activity, getStandardCallback(deferred));
                return deferred.promise;
            },
            cancelActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.cancelActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            completeActivity: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.completeActivity(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            cancelStory: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.cancelStory(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            deleteDocument: function (id) {
                var deferred = $q.defer();
                CE_RemoteController.deleteDocument(id, getStandardCallback(deferred));
                return deferred.promise;
            },
            emailToMember: function (ids) {
                var deferred = $q.defer();
                CE_RemoteController.emailToMember(ids, getStandardCallback(deferred));
                return deferred.promise;
            },
            assignMember: function (activityId, userId) {
                var deferred = $q.defer();
                CE_RemoteController.assignMember(activityId, userId, getStandardCallback(deferred));
                return deferred.promise;
            },
            unassignMember: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.unassignMember(activityId, getStandardCallback(deferred));
                return deferred.promise;
            },
            getRecommendedMembers: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.getRecommendedMembers(activityId, getStandardCallback(deferred));
                return deferred.promise;
            },
            getRegistrants: function (activityId, page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getRegistrants(activityId, page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getAssignedMember: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.getAssignedMember(activityId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            deleteActivity: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.deleteActivity(activityId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getUnreadNotificationsCount: function () {
                var deferred = $q.defer();
                CE_RemoteController.getUnreadNotificationsCount(getStandardCallback(deferred));
                return deferred.promise;
            },
            addSubmission: function(activityId, submissionNamw) {
				var deferred = $q.defer();
                CE_RemoteController.addSubmission(activityId || null, submissionNamw, getStandardCallback(deferred));
                return deferred.promise;
			},
			getSubmissions: function (activityId) {
                var deferred = $q.defer();
                CE_RemoteController.getSubmissions(activityId, getStandardCallback(deferred));
                return deferred.promise;
            },
			loadSubmissionRequirement: function (submissionId) {
                var deferred = $q.defer();
                CE_RemoteController.getSubmissionRequirements(submissionId, getStandardCallback(deferred));
                return deferred.promise;
            },
			upsertSubmissionReview: function (submission, submissionRequirements, markReviewComplete) {
                var deferred = $q.defer();
                CE_RemoteController.saveSubmissionReview(submission, submissionRequirements, markReviewComplete, getStandardCallback(deferred));
                return deferred.promise;
            },
			markReviewComplete: function (submissionId) {
                var deferred = $q.defer();
                CE_RemoteController.markReviewComplete(submissionId, getStandardCallback(deferred));
                return deferred.promise;
            },
			deleteSubmission: function (submissionId) {
                var deferred = $q.defer();
                CE_RemoteController.deleteSubmission(submissionId, getStandardCallback(deferred));
                return deferred.promise;
            },
            getInboxNotifications: function (page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getInboxNotifications(page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getOutboxNotifications: function (page, pageSize) {
                var deferred = $q.defer();
                CE_RemoteController.getOutboxNotifications(page || null, pageSize || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            markNotificationAsRead: function (notificationId) {
                var deferred = $q.defer();
                CE_RemoteController.markNotificationAsRead(notificationId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            archiveNotification: function (notificationId) {
                var deferred = $q.defer();
                CE_RemoteController.archiveNotification(notificationId || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchMembers: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchMembers(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchActivities: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchActivities(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            searchStories: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.searchStories(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            search: function (request) {
                var deferred = $q.defer();
                CE_RemoteController.search(request || null, getStandardCallback(deferred));
                return deferred.promise;
            },
            getPublisherActivities: function () {
                var deferred = $q.defer();
                CE_RemoteController.getPublisherActivities(getStandardCallback(deferred));
                return deferred.promise;
            },
            uploadAttachment: function (att) {
                var attachment = new sforce.SObject('Attachment');
                attachment.Name = att.name;
                attachment.Description = att.description;
                attachment.ContentType = att.type;
                attachment.Body = att.body;
                attachment.ParentId = att.parentId;
                var deferred = $q.defer();
                var result = sforce.connection.create([attachment], {
                    // This method gets called when file upload is in progress
                    progress: function (oEvent) {
                        if (oEvent.lengthComputable) {
                            var percentComplete = parseInt(oEvent.loaded / oEvent.total) * 100;
                            deferred.notify(percentComplete);
                        }
                        else {
                            // Unable to compute progress information since the total size is unknown
                        }
                    },
                    onSuccess: function (success) {
                        deferred.resolve(success);
                    },
                    onFailure: function (failure) {
                        deferred.reject(failure);
                    }
                });
                return deferred.promise;
            },
            trustAsResourceUrl: function (url) {
                return $sce.trustAsResourceUrl(url);
            },
            renderStringTemplate: function (template, scope) {
                var deferred = $q.defer();
                $timeout(function () {
                    var linkFn = $compile(template);
                    var linkedContent = linkFn(scope);
                    scope.$apply();
                    deferred.resolve(linkedContent.html());
                }, 0);

                return deferred.promise;
            }

        };
    });
    CrowdExchangeAppServices.factory('dialogsService', ['dialogs', function (dialogs) {
        return {
            showArchiveNotificationConfirm: function () {
                return dialogs.create('archiveNotificationConfirm.html', 'ceConfirmDialogCtrl', {}, 'lg');
            },
            showRegistrationConfirm: function () {
                return dialogs.create('registrationConfirm.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showLoading: function () {
                return dialogs.create('loadingDialog.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showSavingDraftActivity: function () {
                return dialogs.create('savingActivityAsDraft.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
            showFileUploading: function (percents, filesize) {
                return dialogs.create('fileUploadModal.html', 'ceConfirmDialogCtrl', {percents:percents, filesize:filesize}, 'lg');
            },
            showCancelActivity: function (activityName) {
                return dialogs.create('cancelActivity.html', 'ceConfirmDialogCtrl', { activityName: activityName }, 'lg');
            },
            showAssignMember: function (activityName, userName) {
                return dialogs.create('assignMember.html', 'ceConfirmDialogCtrl', { activityName: activityName, userName: userName }, 'lg');
            },
            showPublisherSelectActivity: function () {
                return dialogs.create('publisherSelectActivity.html', 'pubSelectActivityCtrl', {}, 'lg');
            },
            showActivitySubmitModel : function (activityViewModel) {
                return dialogs.create('activitySubmitModal.html','ceActivitySubmitCtrl', {vm: activityViewModel},'sm');
            },
			      showReviewSaving: function (activityViewModel) {
                return dialogs.create('reviewSavingDialog.html', 'ceReviewSavingDialogCtrl', {vm: activityViewModel}, 'sm');
            },
			      showReviewError: function () {
                return dialogs.create('reviewErrorDialog.html', 'ceConfirmDialogCtrl', {}, 'sm');
            },
			      showReviewScoreError: function () {
                return dialogs.create('reviewScoreErrorDialog.html', 'ceConfirmDialogCtrl', {}, 'sm');
            }
        };
    }]);
    CrowdExchangeAppServices.controller('pubSelectActivityCtrl', function ($log, $scope, $modalInstance, data, dataServices) {
        if (data) jQuery.extend($scope, data);
        $scope.isLoading = true;
        $scope.activities = [];
        dataServices.getPublisherActivities().then(function (data) {
            $scope.activities = data;
            $scope.isLoading = false;
        }, function (error) {
            $modalInstance.close(undefined);
        });
        $scope.selectActivity = function (activity) {
            $modalInstance.close(activity);
        }
        $scope.cancel = function () {
            $modalInstance.close(undefined);
        };

    }); // end customDialogCtrl
    CrowdExchangeAppServices.controller('ceConfirmDialogCtrl', function ($log, $scope, $modalInstance, data) {
        if (data) jQuery.extend($scope, data);
        $scope.no = function () {
            $modalInstance.close(false);
        };
        $scope.yes = function () {
            $modalInstance.close(true);
        }; // end done
    }); // end customDialogCtrl
    
    CrowdExchangeAppServices.controller('ceReviewSavingDialogCtrl', function ($log, $scope, $modalInstance, data) {
        if (data) jQuery.extend($scope, data);
        $scope.no = function () {
            $modalInstance.close(false);
        };
        $scope.yes = function () {
            $modalInstance.close(true);
			this.vm.updateReview(false);
        }; // end done
    }); // end ceReviewSavingDialogCtrl	
	
	CrowdExchangeAppServices.controller('ceActivitySubmitCtrl', function ($log, $scope, $modalInstance, data) {
        if (data) jQuery.extend($scope, data);
        $scope.no = function () {
            $modalInstance.close(false);
        };
        $scope.yes = function () {
            $modalInstance.close(true);			
        }; // end done		
		
		$scope.fileToUpload = { file: null, description: "", fileName: "" };	
		/**
		 * uploads Submission for the current activity
		 * @returns {}
		 */
		$scope.uploadSubmittedFile = function () {						
			$modalInstance.close(false);
			if (this.fileToUpload.file) {				
				var file = {
					description: this.fileToUpload.description,
					name: this.fileToUpload.fileName,
					body: this.fileToUpload.file.substring(this.fileToUpload.file.indexOf('base64') + 7)					
				};				
				var dialog = this.vm.dialogs.showFileUploading(40, file.body.size);
				delete this.fileToUpload;
				this.fileToUpload = {};									
				var _this = this.vm;				
				_this.service.addSubmission(_this.id, file.name).then(function (data) {					
					file.parentId = data.id;		
					_this.service.uploadAttachment(file).then(function (data) {						
						if (data[0].success) {
							var newDocument = new SubmissionDocument();
							newDocument.id = data[0].id;
							newDocument.description = file.description;
							newDocument.name = file.name;
							newDocument.createdDate = new Date();
							_this.submissions.submissions.push(newDocument);
							_this.recentSubmission = newDocument;
						}
						_this.showNewSubmission = true;
						_this.selectTab(4);						
						dialog.close();
					});
				}, function (data) {
					dialog.close();
				}, function (progress) {
					dialog.close();
				});
			}
		};		
    }); // end customDialogCtrl

    CrowdExchangeAppServices.config(function (dialogsProvider) {
        // this provider is only available in the 4.0.0+ versions of angular-dialog-service
        dialogsProvider.useBackdrop(false);
        dialogsProvider.useEscClose(true);
        dialogsProvider.useCopy(true);
        dialogsProvider.setSize('lg');
        dialogsProvider.useAnimation(true);
    }); // end config
})();