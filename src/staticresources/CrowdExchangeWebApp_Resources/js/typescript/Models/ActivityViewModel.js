var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
 * Main Activity viewModel
 */
var ActivityViewModel = (function (_super) {
    __extends(ActivityViewModel, _super);
    function ActivityViewModel(activity, props) {
        _super.call(this, activity);
        this.isActive = false;
        this.activeTab = 0;
        this.startOffset = 0;
        this.fileToUpload = { file: null, description: "", fileName: "" };
        this.defaultSkills = [];
        if (activity && activity.requirements) {
            delete this.requirements;
            this.requirements = activity.requirements.map(function (value) { return new ActivityRequirementViewModel(value); });
        }
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.navigation = props.navigation;
            this.registrants = new ActivityRegistrantsViewModel(this.id, props);
            this.recomendations = new ActivityRecomendedMembersViewModel(this.id, props);
            this.registrants.totalRegistrants = this.registrationsCount;
            if (this.service && activity) {
                this.chatterUrl = this.service.trustAsResourceUrl(GLOBAL_CONFIG.activityChatterUrl + "?id=" + this.id);
            }
        }
    }
    /**
     * returnes duration for the particular milestone
     * @param indx index of milestone
     * @returns {}
     */
    ActivityViewModel.prototype.milestoneDuration = function (indx) {
        if (indx === this.milestones.length - 1)
            return 0;
        var ms = 0;
        ms = moment(this.milestones[indx + 1].scheduledDate).diff(moment(this.milestones[indx].scheduledDate));
        return moment.duration(ms).asDays();
    };
    /**
     *  Milestonechanged Callback
     * @param indx index of the milestone that was changed
     * @param newValue new value
     * @param oldValue previous value
     * @returns {void}
     */
    ActivityViewModel.prototype.milestoneChanged = function (indx, newValue, oldValue) {
        var difference = moment.duration(moment(newValue).diff(moment(oldValue))).asDays();
        if (difference > 0) {
            for (var i = indx + 1; i < this.milestones.length; i++) {
                var newDate = moment(this.milestones[i].scheduledDate).add(difference, 'days');
                this.milestones[i].scheduledDate = newDate.toDate();
            }
        }
    };
    /**
     * removes the requirement from the activity
     * @param indx index of reuirement
     * @returns {}
     */
    ActivityViewModel.prototype.removeRequirement = function (indx) {
        this.requirements.splice(indx, 1);
        this.requirements.map(function (parent, parentIndx) {
            parent.requirementNumber = (parentIndx + 1) + ".0";
            parent.childRequirements.map(function (child, childIndx) { return child.requirementNumber = (parentIndx + 1) + "." + (childIndx + 1); });
        });
    };
    /**
     * selects tab
     * 0 - activity details, 1 -registrants, 2 - recomended members,
     * 3 - chatter, 4 - submissions, 5 - review
     * @param indx tab index to go to
     * @returns {}
     */
    ActivityViewModel.prototype.selectTab = function (indx) {
        this.activeTab = indx;
        switch (indx) {
            case 1:
                this.registrants.initialize();
                this.fetchAssignedMember();
                break;
            case 2:
                this.recomendations.initialize();
                break;
            case 3:
                break;
            case 4:
                break;
            case 5:
                break;
            default:
        }
    };
    /**
     * registers current user to the activity
     * @returns {}
     */
    ActivityViewModel.prototype.registerToActivity = function () {
        var _this = this;
        this.dialogs.showRegistrationConfirm().result.then(function (result) {
            if (result) {
                _this.service.registerToActivity(_this.id).then(function (data) {
                    _this.isRegistered = true;
                }, function (data) { });
            }
        });
    };
    /**
     * sets default skills collection
     * @param types array of default skills
     * @returns {}
     */
    ActivityViewModel.prototype.setDefaultCodeTypes = function (types) {
        var _this = this;
        var codeTypes = this.codeTypes;
        this.codeTypes = [];
        var selected = [];
        var defaultSkills = [];
        _.map(types, function (item) {
            var obj = _.extend(new CodeType(item.name, item.skillId, item.id), _.findWhere(codeTypes, { id: item.skillId }));
            delete obj.$$hashKey;
            defaultSkills.push(obj);
            if (obj.skillId)
                selected.push(obj);
            return obj;
        });
        this.defaultSkills = defaultSkills;
        setTimeout(function () {
            _this.codeTypes = selected;
        }, 500);
    };
    /**
     * adds a requirement to the current activity
     * @returns {}
     */
    ActivityViewModel.prototype.addRequirement = function () {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = (this.requirements.length + 1) + ".0";
        this.requirements.push(newRequirement);
    };
    /**
     * adds a award to the current activity
     * @returns {}
     */
    ActivityViewModel.prototype.addPrize = function () {
        if (this.noPrizes)
            return;
        var newPrize = new ActivityPrize();
        newPrize.place = this.prizes.length + 1;
        this.prizes.push(newPrize);
    };
    /**
     * removes the award from the current activity
     * @param indx index of the award to remove
     * @returns {}
     */
    ActivityViewModel.prototype.removePrize = function (indx) {
        if (this.noPrizes)
            return;
        this.prizes.splice(indx, 1);
        for (var i = this.prizes.length; i > 0; i--) {
            this.prizes[i - 1].place = i;
        }
    };
    Object.defineProperty(ActivityViewModel.prototype, "activityDuration", {
        /**
         * calculates activity's duration
         * @returns {}
         */
        get: function () {
            return this.milestones[this.milestones.length - 1].getOffset(this.milestones[0]);
        },
        enumerable: true,
        configurable: true
    });
    /**
     * uploads document for the current activity
     * @returns {}
     */
    ActivityViewModel.prototype.uploadFile = function () {
        var _this = this;
        var dialog = this.dialogs.showLoading();
        if (this.fileToUpload.file) {
            var file = {
                description: this.fileToUpload.description,
                name: this.fileToUpload.fileName,
                body: this.fileToUpload.file.substring(this.fileToUpload.file.indexOf('base64') + 7),
                parentId: this.id
            };
            delete this.fileToUpload;
            this.fileToUpload = {};
            this.service.uploadAttachment(file).then(function (data) {
                dialog.close();
                if (data[0].success) {
                    var newDocument = new ActivityDocument();
                    newDocument.id = data[0].id;
                    newDocument.description = file.description;
                    newDocument.name = file.name;
                    newDocument.createdDate = new Date();
                    _this.documents.push(newDocument);
                }
            }, function (data) {
                dialog.close();
            }, function (progress) {
                dialog.close();
            });
        }
    };
    /**
     * file selected callback
     * @param fileInput input[type=file]
     * @returns {}
     */
    ActivityViewModel.prototype.addFile = function (fileInput) {
        this.fileToUpload.file = fileInput.files.length ? fileInput.files[0] : null;
    };
    ActivityViewModel.prototype.deleteDocument = function (indx) {
        var _this = this;
        if (indx < 0 || indx >= this.documents.length)
            return;
        var document = this.documents[indx];
        if (document) {
            this.dialogs.showRegistrationConfirm().result.then(function (result) {
                if (result) {
                    var dialog = _this.dialogs.showLoading();
                    _this.service.deleteDocument(document.id).then(function (data) {
                        _this.documents.splice(indx, 1);
                        dialog.close();
                    }, function (data) { dialog.close(); });
                }
            });
        }
    };
    /**
     * assigned member to the current activity
     * @param registration
     * @returns {}
     */
    ActivityViewModel.prototype.assignMember = function (registration) {
        var _this = this;
        this.dialogs.showAssignMember(this.title, registration.user.firstName + ' ' + registration.user.lastName).result.then(function (result) {
            if (result) {
                _this.service.assignMember(_this.id, registration.user.id).then(function (user) {
                    _this.assignedMember = registration.user;
                    _this.assignedMemberRegistration = registration;
                }, function (error) {
                });
            }
        });
    };
    /**
     * removes assignment from the activity
     * @returns {}
     */
    ActivityViewModel.prototype.unassignMember = function () {
        var _this = this;
        this.service.unassignMember(this.id).then(function () {
            _this.assignedMember = null;
        }, function (error) {
        });
    };
    /**
     * saves the activity as a draft
     * @returns {}
     */
    ActivityViewModel.prototype.saveAsDraft = function () {
        this.phase = "Draft";
        this.upsert();
    };
    /**
     * publish activity
     * @returns {}
     */
    ActivityViewModel.prototype.publish = function () {
        var _this = this;
        this.upsert(function () {
            if (_this.navigation)
                _this.navigation.path("/publisherActivityDetailsAssignRegister/" + _this.id);
        });
    };
    /**
     * upserts current activity to the SFDC
     * @returns {}
     */
    ActivityViewModel.prototype.upsert = function (callback) {
        var _this = this;
        if (callback === void 0) { callback = null; }
        var dialog = this.phase === 'Draft' ? this.dialogs.showSavingDraftActivity() : this.dialogs.showLoading();
        if (this.id) {
            this.service.upsertActivity(this.getModel()).then(function (data) {
                dialog.close();
                if (callback)
                    callback();
            }, function (data) { dialog.close(); });
        }
        else {
            this.service.createActivity({
                title: this.title,
                description: this.description,
                challengeType: this.challengeType,
                storyId: this.story.id,
                phase: this.phase
            }).then(function (data) {
                _this.id = data.id;
                dialog.close();
            }, function (data) { dialog.close(); });
        }
    };
    /**
     * canceles activity
     * @returns {}
     */
    ActivityViewModel.prototype.cancelActivity = function () {
        var _this = this;
        this.dialogs.showCancelActivity(this.title).result.then(function (result) {
            if (result) {
                var dialogs = _this.dialogs.showLoading();
                _this.service.cancelActivity(_this.id).then(function (data) {
                    _this.phase = 'Canceled';
                    dialogs.close();
                }, function (data) {
                    dialogs.close();
                });
            }
        });
    };
    /**
     * completes activity
     * @returns {}
     */
    ActivityViewModel.prototype.completeActivity = function () {
        var _this = this;
        var dialogs = this.dialogs.showLoading();
        this.service.completeActivity(this.id).then(function (data) {
            _this.phase = 'Completed';
            dialogs.close();
            window.location = window.location;
        }, function (data) {
            dialogs.close();
        });
    };
    /**
     * clones current activity
     * @returns {}
     */
    ActivityViewModel.prototype.clone = function () {
        return new ActivityViewModel(angular.fromJson(angular.toJson(this)));
    };
    ActivityViewModel.prototype.fetchAssignedMember = function () {
        var _this = this;
        this.service.getAssignedMember(this.id).then(function (data) {
            _this.assignedMemberRegistration = new ActivityRegistration(data);
        }, function (error) { });
    };
    return ActivityViewModel;
})(Activity);
//# sourceMappingURL=ActivityViewModel.js.map