/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/moment/moment.d.ts"/>
/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/angularjs/angular.d.ts"/>
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/moment/moment.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/angularjs/angular.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/underscore/underscore.d.ts" />
copyFields = function (d, b) {
    for (var p in b)
        if (b.hasOwnProperty(p))
            d[p] = b[p];
    function __() { this.constructor = d; }
};
/**
 * User view model
 */
var UserViewModel = (function () {
    function UserViewModel(model) {
        if (model) {
            jQuery.extend(this, model);
        }
    }
    Object.defineProperty(UserViewModel.prototype, "fullName", {
        get: function () {
            return ((this.firstName || "") + " " + (this.lastName || "")).trim();
        },
        enumerable: true,
        configurable: true
    });
    return UserViewModel;
})();
//# sourceMappingURL=UserViewModel.js.map
/**
* Class with basic info about activity
*/
var Activity = (function () {
    function Activity(activity) {
        this.title = "";
        this.description = "";
        this.challengeType = "Assigned";
        this.phase = "";
        this.codeTypes = [];
        this.noPrizes = false;
        this.requirements = [];
        this.prizes = [new ActivityPrize()];
        this.documents = [];
        this.registrationsCount = 0;
        this.submissionsCount = 0;
        if (activity) {
            this.id = activity.id;
            this.title = activity.title;
            this.challengeType = activity.challengeType;
            if (activity.codeTypes)
                this.codeTypes = activity.codeTypes.length ? activity.codeTypes.map(function (value) { return new CodeType(value.name, value.skillId, value.id); }) : undefined;
            if (activity.milestones)
                this.milestones = activity.milestones.map(function (value) { return new ActivityMilestone(value); });
            this.noPrizes = activity.noPrizes;
            if (activity.requirements)
                this.requirements = activity.requirements.map(function (value) { return new ActivityRequirement(value); });
            if (activity.prizes)
                this.prizes = activity.prizes.map(function (value) { return new ActivityPrize(value); });
            this.story = activity.story;
            this.documents = activity.documents;
            this.description = jQuery("<div/>").html(activity.description).text(); // unescape xml encoded HTML
            this.phase = activity.phase;
            this.registrationsCount = activity.registrationsCount;
            this.submissionsCount = activity.submissionsCount;
            this.isRegistered = activity.isRegistered;
            if (activity.assignedMember)
                this.assignedMember = new UserViewModel(activity.assignedMember);
        }
        if (!this.milestones || !this.milestones.length) {
            var date = moment();
            this.milestones = [];
            for (var i = 0; i < GLOBAL_CONFIG.milestones.length; i++) {
                var milestone = new ActivityMilestone(GLOBAL_CONFIG.milestones[i]);
                var addDays = i == 0 ? 0 : GLOBAL_CONFIG.milestones[i - 1]['defaultDuration'];
                milestone.scheduledDate = date.add(addDays, 'days').clone().toDate();
                this.milestones.push(milestone);
            }
        }
    }
    /**
     * Getting DTO model
     * @returns {DTO model for RemoteAction}
     */
    Activity.prototype.getModel = function () {
        return {
            id: this.id,
            title: this.title,
            description: this.description,
            challengeType: this.challengeType,
            phase: this.phase,
            codeTypes: this.codeTypes ? this.codeTypes.map(function (value) { return new CodeType(value.name, value.skillId, value.id); }) : [],
            milestones: this.milestones.map(function (value) { return value.getModel(); }),
            isRegistered: this.isRegistered,
            noPrizes: this.noPrizes,
            requirements: this.requirements.map(function (value) { return value.getModel(); }),
            prizes: this.noPrizes ? [] : this.prizes.map(function (value) { return value.getModel(); })
        };
    };
    return Activity;
})();
//# sourceMappingURL=Activity.js.map
/**
* Story base class with basic properties
*/
var Story = (function () {
    function Story(story) {
        this.title = "";
        this.description = "";
        this.serviceOffering = null;
        this.phase = "";
        this.activities = [];
        if (story) {
            this.activities = story.activities;
            this.title = story.title;
            this.description = jQuery("<div/>").html(story.description).text();
            this.serviceOffering = story.serviceOffering;
            this.id = story.id;
            this.phase = story.phase;
            this.publisher = new UserViewModel(story.publisher);
        }
    }
    /**
     *  Getting DTO model
     * @returns {DTO model for RemoteAction}
     */
    Story.prototype.getModel = function () {
        return {
            id: this.id,
            title: this.title,
            description: this.description,
            serviceOffering: this.serviceOffering,
            status: this.phase,
            activities: this.activities.map(function (value) { return value.getModel(); })
        };
    };
    return Story;
})();
//# sourceMappingURL=Story.js.map
/**
* Class with basic info about skill(Activity's, User's and standard)
*/
var CodeType = (function () {
    function CodeType(name, id, skillId) {
        this.name = name;
        this.id = id;
        this.skillId = skillId;
    }
    return CodeType;
})();
//# sourceMappingURL=CodeType.js.map
/**
* Class with basic info about Activity's document(Attachment)
*/
var ActivityDocument = (function () {
    function ActivityDocument() {
    }
    return ActivityDocument;
})();
//# sourceMappingURL=ActivityDocument.js.map
/**
* Class with info about Activity's milestone
*/
var ActivityMilestone = (function () {
    function ActivityMilestone(model) {
        if (model) {
            this.scheduledDate = model.scheduledDate ? moment.utc(model.scheduledDate).toDate() : null;
            this.completedDate = model.completedDate ? moment.utc(model.completedDate).toDate() : null;
            this.name = model.name;
        }
    }
    /**
     * Calculates offset from other milestone in days
     * @param milestone
     * @returns {offset in days}
     */
    ActivityMilestone.prototype.getOffset = function (milestone) {
        if (!milestone)
            return 0;
        return (moment.duration(moment(this.scheduledDate).diff(moment(milestone.scheduledDate))).asDays());
    };
    /**
     * Getting DTO model
     * @returns {DTO model for RemoteAction}
     */
    ActivityMilestone.prototype.getModel = function () {
        var scheduled = moment(this.scheduledDate);
        var completed = moment(this.completedDate);
        return {
            name: this.name,
            scheduledDate: this.scheduledDate ? scheduled.subtract(scheduled.zone(), 'minutes').toDate().toUTCString() : undefined,
            completedDate: this.completedDate ? completed.subtract(completed.zone(), 'minutes').toDate().toUTCString() : undefined
        };
    };
    return ActivityMilestone;
})();
//# sourceMappingURL=ActivityMilestone.js.map
/**
* Class with info about Activity's award
*/
var ActivityPrize = (function () {
    function ActivityPrize(prize) {
        this.place = 1;
        this.amount = 0;
        if (prize) {
            this.id = prize.id;
            this.place = prize.place;
            this.amount = prize.amount;
        }
    }
    Object.defineProperty(ActivityPrize.prototype, "placeLabel", {
        /**
         * Makes places label
         * @returns {}
         */
        get: function () {
            var appendix = '';
            switch (this.place) {
                case 1:
                    appendix = "st";
                    break;
                case 2:
                    appendix = "nd";
                    break;
                case 3:
                    appendix = "rd";
                    break;
                default:
                    appendix = "th";
            }
            return this.place + appendix;
        },
        enumerable: true,
        configurable: true
    });
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction}
    */
    ActivityPrize.prototype.getModel = function () {
        return {
            id: this.id,
            place: this.place,
            amount: this.amount
        };
    };
    return ActivityPrize;
})();
//# sourceMappingURL=ActivityPrize.js.map
/**
* ViewModel for the activity's recomended members collection
*/
var ActivityRecomendedMembersViewModel = (function () {
    function ActivityRecomendedMembersViewModel(activityId, props) {
        this.isInitialized = false;
        this.recomendedUsers = [];
        this._selectAll = false;
        this.activityId = activityId;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    Object.defineProperty(ActivityRecomendedMembersViewModel.prototype, "selectAll", {
        /**
         * returns select all property
         * @returns {}
         */
        get: function () {
            return this._selectAll;
        },
        /**
         * selects or deselects all members
         * @param value
         * @returns {}
         */
        set: function (value) {
            var _this = this;
            this._selectAll = value;
            this.recomendedUsers.map(function (usr) { return usr.selected = _this._selectAll; });
        },
        enumerable: true,
        configurable: true
    });
    /**
     * initialize collection
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.initialize = function () {
        var _this = this;
        if (this.isInitialized)
            return;
        this.isInitialized = true;
        this.service.getRecommendedMembers(this.activityId).then(function (data) {
            _this.recomendedUsers = data;
        }, function (data) {
            _this.isInitialized = false;
        });
    };
    /**
     * sends email to the selected members
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailSelected = function () {
        var ids = [];
        this.recomendedUsers.map(function (value) {
            if (value.selected)
                ids.push(value.id);
        });
        this.emailMembers(ids);
    };
    /**
     * sends email to the particular user
     * @param userId user's id
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailMember = function (userId) {
        this.emailMembers([userId]);
    };
    /**
     * sends email to the particular users
     * @param userIds array of users' ids
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailMembers = function (userIds) {
        this.service.emailToMember(userIds).then(function (data) {
        }, function (data) {
        });
    };
    return ActivityRecomendedMembersViewModel;
})();
//# sourceMappingURL=ActivityRecomendedMembersViewModel.js.map
/**
* ViewModel for the list of activity's registrants
*/
var ActivityRegistrantsViewModel = (function () {
    function ActivityRegistrantsViewModel(activityId, props) {
        this.isInitialized = false;
        this.registrants = [];
        this.page = 1;
        this.pageSize = 8;
        this.activityId = activityId;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    /**
     * sends email to the user
     * @param userId user's Id
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.emailMember = function (userId) {
        this.service.emailToMember([userId]).then(function (data) {
        }, function (data) {
        });
    };
    /**
     * Page changed handler
     * @param newPage new page number
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.pageChanged = function (newPage) {
        this.fetchRegistrants();
    };
    /**
     * initialize collection
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.initialize = function () {
        if (this.isInitialized)
            return;
        this.isInitialized = true;
        this.fetchRegistrants();
    };
    /**
     * fetches current page of registrants
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.fetchRegistrants = function () {
        var _this = this;
        this.service.getRegistrants(this.activityId, this.page, this.pageSize).then(function (data) {
            _this.registrants = data;
        }, function (data) {
        });
    };
    return ActivityRegistrantsViewModel;
})();
//# sourceMappingURL=ActivityRegistrantsViewModel.js.map
/**
 *  Model contains information about Activity's registration
 */
var ActivityRegistration = (function () {
    function ActivityRegistration(model) {
        this.user = new UserViewModel();
        if (model) {
            this.id = model.id;
            this.registrationDate = model.registrationDate;
            this.user = new UserViewModel(model.user);
        }
    }
    return ActivityRegistration;
})();
//# sourceMappingURL=ActivityRegistration.js.map
/**
* Class with info about Activity's requirement
*/
var ActivityRequirement = (function () {
    function ActivityRequirement(requirement) {
        this.childRequirements = [];
        this.requirementType = "";
        this.importance = "";
        this.description = "";
        if (requirement) {
            this.description = jQuery("<div/>").html(requirement.description).text();
            this.id = requirement.id;
            this.requirementType = requirement['type'];
            this.importance = requirement.importance;
            this.requirementNumber = requirement.requirementNumber;
            this.childRequirements = requirement.childRequirements.map(function (value) { return new ActivityRequirement(value); });
        }
    }
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction}
    */
    ActivityRequirement.prototype.getModel = function () {
        return {
            id: this.id,
            requirementNumber: this.requirementNumber,
            'type': this.requirementType,
            importance: this.importance,
            childRequirements: this.childRequirements.map(function (value) { return value.getModel(); }),
            description: this.description
        };
    };
    return ActivityRequirement;
})();
//# sourceMappingURL=ActivityRequirement.js.map
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
 * ViewModel for the Activity's requirement
 */
var ActivityRequirementViewModel = (function (_super) {
    __extends(ActivityRequirementViewModel, _super);
    function ActivityRequirementViewModel() {
        _super.apply(this, arguments);
    }
    /**
     * Adds new child requirements
     * @returns {}
     */
    ActivityRequirementViewModel.prototype.addRequirement = function () {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = this.requirementNumber.split(".")[0] + "." + (this.childRequirements.length + 1);
        this.childRequirements.push(newRequirement);
    };
    /**
     * removes child requirement
     * @param indx index of the child requirement to remove
     * @returns {}
     */
    ActivityRequirementViewModel.prototype.removeRequirement = function (indx) {
        this.childRequirements.splice(indx, 1);
        var parentNumber = this.requirementNumber.split(".")[0];
        this.childRequirements.map(function (child, childIndx) { return child.requirementNumber = parentNumber + "." + (childIndx + 1); });
    };
    return ActivityRequirementViewModel;
})(ActivityRequirement);
//# sourceMappingURL=ActivityRequirementViewModel.js.map
/**
 *  Model holds information about Activity's submission
 */
var ActivitySubmission = (function () {
    function ActivitySubmission(model) {
        this.user = new UserViewModel();
        if (model) {
            this.id = model.id;
            this.submissionnDate = model.submissionnDate;
            this.user = new UserViewModel(model.user);
        }
    }
    return ActivitySubmission;
})();
//# sourceMappingURL=ActivitySubmission.js.map
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
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
* Base Story ViewModel
*/
var StoryViewModel = (function (_super) {
    __extends(StoryViewModel, _super);
    function StoryViewModel(story, props) {
        _super.call(this, story);
        this.isActive = true;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        var activities = this.activities || [];
        this.activities = [];
        for (var i = 0; i < activities.length; i++) {
            this.activities.push(new ActivityViewModel(activities[i], props));
        }
    }
    /**
     * Adds activity to the story
     * @param index activity index to clone
     * @returns {}
     */
    StoryViewModel.prototype.addActivity = function (index) {
        //if index is provided clone activity and add to the end
        if (index !== undefined) {
            if (index >= 0 && index < this.activities.length) {
                var activity = this.activities[index];
                this.activities.push(activity.clone());
            }
        }
        else {
            //otherwise just add basic empty activity
            this.activities.push(new ActivityViewModel());
        }
    };
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {}
     */
    StoryViewModel.prototype.removeActivity = function (index) {
        var _this = this;
        if (index !== undefined && index >= 0 && index < this.activities.length) {
            var activityId = this.activities[index].id;
            if (activityId) {
                var dialog = this.dialogs.showLoading();
                this.service.deleteActivity(activityId).then(function (data) {
                    _this.activities.splice(index, 1);
                    dialog.close();
                }, function (error) { dialog.close(); });
            }
            else {
                this.activities.splice(index, 1);
            }
        }
    };
    /**
     * Sets active tab.
     * @param indx tab index. -1 - story, 0-N activity
     * @returns {}
     */
    StoryViewModel.prototype.setActiveTab = function (indx) {
        if (indx < -1 || indx >= this.activities.length)
            return;
        this.isActive = false;
        for (var i = 0; i < this.activities.length; i++) {
            this.activities[i].isActive = false;
        }
        if (indx < 0)
            this.isActive = true;
        else
            this.activities[indx].isActive = true;
    };
    /**
     * Sets start offsets for all activities
     * @returns {}
     */
    StoryViewModel.prototype.setStartOffsets = function () {
        if (!this.activities || !this.activities.length)
            return;
        var minDate = moment(this.activities[0].milestones[0].scheduledDate);
        var maxDate = moment(this.activities[0].milestones[this.activities[0].milestones.length - 1].scheduledDate);
        for (var i = 1; i < this.activities.length; i++) {
            var pubDate = moment(this.activities[i].milestones[0].scheduledDate);
            var endDate = moment(this.activities[i].milestones[this.activities[i].milestones.length - 1].scheduledDate);
            if (pubDate.diff(minDate) < 0)
                minDate = pubDate;
            if (endDate.diff(maxDate) > 0)
                maxDate = endDate;
        }
        this.storyStart = minDate.toDate();
        this.storyEnd = maxDate.toDate();
        for (var i = 1; i < this.activities.length; i++) {
            this.activities[i].startOffset = moment.duration(moment(this.activities[i].milestones[0].scheduledDate).diff(minDate)).asDays();
        }
    };
    Object.defineProperty(StoryViewModel.prototype, "storyDuration", {
        /**
         * rcalculates story's duration in days
         * @returns {}
         */
        get: function () {
            this.setStartOffsets();
            var ms = moment(this.storyEnd).diff(moment(this.storyStart));
            var d = moment.duration(ms);
            return d.asDays();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "totalBudget", {
        /**
         * calculates story's cost
         * @returns {}
         */
        get: function () {
            var budget = 0;
            for (var i = 0; i < this.activities.length; i++) {
                var activity = this.activities[i];
                if (activity.noPrizes)
                    continue;
                if (activity.prizes)
                    for (var j = 0; j < activity.prizes.length; j++) {
                        budget += activity.prizes[j].amount;
                    }
            }
            return budget;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "registrationsCount", {
        /**
         * calculates total registrations number for the story
         * @returns {}
         */
        get: function () {
            var count = 0;
            this.activities.map(function (value) { return count += value.registrationsCount; });
            return count;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "submissionsCount", {
        /**
         * calculates total submissions number for the story
         * @returns {}
         */
        get: function () {
            var count = 0;
            this.activities.map(function (value) { return count += value.submissionsCount; });
            return count;
        },
        enumerable: true,
        configurable: true
    });
    return StoryViewModel;
})(Story);
//# sourceMappingURL=StoryViewModel.js.map
/**
* ViewModel for the stories list filter
*/
var StoriesFilterViewModel = (function () {
    function StoriesFilterViewModel() {
        this.storyTitle = "";
        this.activityTitle = "";
        this.serviceOffering = "";
        this.activityPhase = "";
        this.showOnlyCompleted = false;
        this.isActive = false;
        this.clear();
    }
    StoriesFilterViewModel.prototype.clear = function () {
        this.storyTitle = "";
        this.activityTitle = "";
        this.serviceOffering = "";
        this.activityPhase = "";
    };
    StoriesFilterViewModel.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.serviceOffering === "all")
            delete model.serviceOffering;
        if (model.activityPhase === "all")
            delete model.activityPhase;
        return model;
    };
    return StoriesFilterViewModel;
})();
//# sourceMappingURL=StoriesFilterViewModel.js.map
/**
* ViewModel for th publisherCreateStory page
*/
var CreateStoryViewModel = (function () {
    function CreateStoryViewModel(props) {
        this.step = 1;
        this.story = new StoryViewModel(null, props);
        this.story.activities.push(new ActivityViewModel(null, props));
        this.stepsCount = this.story.activities.length + 2;
        this.service = props.service;
        this.dialogs = props.dialogs;
    }
    /**
     * Saves current step and goes to the next
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToNext = function () {
        if (this.step === this.story.activities.length + 2)
            return;
        this.saveCurrentStep(true);
    };
    /**
     * Publish story
     * @returns {}
     */
    CreateStoryViewModel.prototype.publish = function () {
        this.story.phase = "In Progress";
        this.saveCurrentStep(true, function () { return window.location = (document.location.href.match(/(^[^#]*)/)[0]); });
    };
    /**
     * Saves current step
     * @param goToNext determines if after save we should go to the next step
     * @param callback callback success function
     * @returns {}
     */
    CreateStoryViewModel.prototype.saveCurrentStep = function (goToNext, callback) {
        var _this = this;
        if (goToNext === void 0) { goToNext = false; }
        var dialog = this.dialogs.showLoading();
        //saving story
        if (this.step === 1 || this.step === this.story.activities.length + 2) {
            this.service.upsertStory({
                id: this.story.id,
                title: this.story.title,
                description: this.story.description,
                serviceOffering: this.story.serviceOffering
            }).then(function (data) {
                _this.story.id = data.id;
                if (goToNext)
                    _this.step = _this.step + 1;
                if (callback)
                    callback();
                dialog.close();
            }, function (data) { dialog.close(); });
        }
        else {
            //saving activity
            var activity = this.story.activities[this.step - 2];
            if (activity.id) {
                this.service.upsertActivity(activity.getModel()).then(function (data) {
                    if (goToNext)
                        _this.step = _this.step + 1;
                    dialog.close();
                }, function (data) { dialog.close(); });
            }
            else {
                this.service.createActivity({
                    title: activity.title,
                    description: activity.description,
                    challengeType: activity.challengeType,
                    storyId: this.story.id
                }).then(function (data) {
                    activity.id = data.id;
                    dialog.close();
                }, function (data) { dialog.close(); });
            }
        }
    };
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {}
     */
    CreateStoryViewModel.prototype.removeActivity = function (index) {
        var _this = this;
        this.dialogs.showRegistrationConfirm().result.then(function () {
            _this.story.removeActivity(index);
            if (index === _this.step + 1)
                _this.step = _this.step - 1;
        });
    };
    /**
     * Goes to the previous step
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToPrev = function () {
        if (this.step === 1)
            return;
        this.step = this.step - 1;
    };
    /**
     * Goes to the specific step
     * @param step
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToStep = function (step) {
        if (this.step < 2 || step < 1 || step > this.story.activities.length + 2)
            return;
        this.step = step;
    };
    return CreateStoryViewModel;
})();
//# sourceMappingURL=CreateStoryViewModel.js.map
/**
* Stories collection viewModel
*/
var StoriesListViewModel = (function () {
    function StoriesListViewModel(filter, fetchOnlyCompleted) {
        if (filter === void 0) { filter = new StoriesFilterViewModel(); }
        if (fetchOnlyCompleted === void 0) { fetchOnlyCompleted = false; }
        this.stories = [];
        this.pageSize = 5;
        this.page = 1;
        this.totalPages = 1;
        this.totalItems = 0;
        this.isActive = true;
        this.fetchOnlyCompleted = false;
        this.isLoading = false;
        this.filter = filter;
        this.fetchOnlyCompleted = fetchOnlyCompleted;
    }
    /**
     * fetches stories with filter and pagination
     * @param fromStart
     * @returns {}
     */
    StoriesListViewModel.prototype.fetchStories = function (fromStart) {
        var _this = this;
        if (fromStart === void 0) { fromStart = false; }
        if (!this.filter)
            this.filter = new StoriesFilterViewModel();
        this.filter.showOnlyCompleted = this.fetchOnlyCompleted;
        if (this.isLoading)
            return;
        this.isLoading = true;
        if (fromStart) {
            this.page = 1;
            this.totalItems = 0;
            this.totalPages = 1;
            this.stories = [];
        }
        if (this.service != null && this.service.getStories != null) {
            this.service.getStories({
                page: this.page,
                pageSize: this.pageSize,
                filter: this.filter.getModel()
            }).then(function (data) {
                _this.totalItems = data.totalItems;
                _this.totalPages = data.totalPages;
                _this.stories = data.stories.map(function (value, index, arr) { return new StoryViewModel(value); });
                _this.isLoading = false;
            }, function (data) { _this.isLoading = false; });
            ;
        }
        else {
            this.isLoading = false;
        }
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    StoriesListViewModel.prototype.pageChanged = function (newPage) {
        this.fetchStories();
    };
    /**
     * Goes to the next page
     * @returns {}
     */
    StoriesListViewModel.prototype.goToPage = function () {
        if (this.page === 1 || this.page === this.totalPages)
            return;
        this.fetchStories();
        this.fetchStories();
    };
    return StoriesListViewModel;
})();
//# sourceMappingURL=StoriesListViewModel.js.map
/**
* Stories page ViewModel
*/
var StoriesViewModel = (function () {
    function StoriesViewModel(dataServices) {
        this.filter = new StoriesFilterViewModel();
        this.activeStories = new StoriesListViewModel(this.filter);
        this.activeStories.service = dataServices;
        this.activeStories.fetchStories();
        this.activeStories.isActive = true;
        this.completedStories = new StoriesListViewModel(this.filter, true);
        this.completedStories.service = dataServices;
        this.filter.showOnlyCompleted = true;
        this.completedStories.fetchStories();
        this.showTab(1);
    }
    /**
     * resets filter
     * @returns {}
     */
    StoriesViewModel.prototype.resetFilter = function () {
        this.filter.clear();
        this.filter.isActive = false;
        this.activeStories.fetchStories();
        this.completedStories.fetchStories();
    };
    /**
     * fetch filtered stories
     * @returns {}
     */
    StoriesViewModel.prototype.filterStories = function () {
        this.activeStories.fetchStories(true);
        this.completedStories.fetchStories(true);
    };
    /**
     * show particular tab
     * @param indx tab index. 1 - active stories, 2 - completed stories
     * @returns {}
     */
    StoriesViewModel.prototype.showTab = function (indx) {
        this.activeStories.isActive = indx === 1;
        this.completedStories.isActive = indx === 2;
    };
    return StoriesViewModel;
})();
//# sourceMappingURL=StoriesViewModel.js.map
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
* ViewModel for the member story details page
*/
var StoryDetailsViewModel = (function (_super) {
    __extends(StoryDetailsViewModel, _super);
    function StoryDetailsViewModel(params) {
        _super.call(this, { id: params.id });
        this.service = params.service;
        this.dialogs = params.dialogs;
        this.refresh();
    }
    /**
     * refreshes current story
     * @returns {}
     */
    StoryDetailsViewModel.prototype.refresh = function () {
        var _this = this;
        this.service.getStory(this.id, true).then(function (data) {
            jQuery.extend(true, _this, new StoryViewModel(data));
        }, function (data) { });
        ;
    };
    /**
     * registers current user to the needed activity
     * @param activityId activity Id to register
     * @returns {}
     */
    StoryDetailsViewModel.prototype.registerToActivity = function (activityId) {
        var _this = this;
        if (!activityId)
            return;
        this.dialogs.showRegistrationConfirm().result.then(function (result) {
            if (result) {
                _this.service.registerToActivity(activityId).then(function (data) {
                    for (var i = 0; i < _this.activities.length; i++) {
                        var activity = _this.activities[i];
                        if (activity.id === activityId) {
                            activity.isRegistered = true;
                            break;
                        }
                    }
                }, function (data) { });
            }
        });
    };
    return StoryDetailsViewModel;
})(StoryViewModel);
//# sourceMappingURL=StoryDetailsViewModel.js.map
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
* Story Details ViewModel for the publisher
*/
var StoryPublisherDetailsViewModel = (function (_super) {
    __extends(StoryPublisherDetailsViewModel, _super);
    function StoryPublisherDetailsViewModel(params) {
        _super.call(this, { id: params.id });
        this.isEditMode = false;
        this.isInitialized = false;
        this.service = params.service;
        this.dialogs = params.dialogs;
        this.refresh();
        this.isActive = true;
    }
    Object.defineProperty(StoryPublisherDetailsViewModel.prototype, "daysPassed", {
        /**
         * calculates how many days passed from the story start
         * @returns {}
         */
        get: function () {
            return moment.duration(moment().diff(moment(this.storyStart))).asDays();
        },
        enumerable: true,
        configurable: true
    });
    /**
     * refreshes current story
     * @returns {}
     */
    StoryPublisherDetailsViewModel.prototype.refresh = function () {
        var _this = this;
        this.service.getStory(this.id, true).then(function (data) {
            var vm = new StoryViewModel(data, { service: _this.service, dialogs: _this.dialogs });
            vm.setStartOffsets();
            if (_this.service) {
                vm.activities.map(function (value) {
                    value.chatterUrl = _this.service.trustAsResourceUrl(GLOBAL_CONFIG.activityChatterUrl + "?id=" + value.id);
                });
            }
            copyFields(_this, vm);
            _this.isInitialized = true;
        }, function (data) { });
        ;
    };
    /**
     * updates current story
     * @returns {}
     */
    StoryPublisherDetailsViewModel.prototype.updateStory = function () {
        var _this = this;
        this.service.upsertStory({
            id: this.id,
            title: this.title,
            description: this.description,
            serviceOffering: this.serviceOffering
        }).then(function (data) {
            _this.isEditMode = false;
        }, function (data) { });
    };
    /**
     * Enable edit mode for the story
     * @returns {}
     */
    StoryPublisherDetailsViewModel.prototype.editStory = function () {
        this.isEditMode = true;
    };
    StoryPublisherDetailsViewModel.prototype.cancelEditMode = function () {
        this.isEditMode = false;
    };
    /**
     * Canceles edit mode for the story
     * @returns {}
     */
    StoryPublisherDetailsViewModel.prototype.closeStory = function () {
        var _this = this;
        this.dialogs.showRegistrationConfirm().result.then(function (result) {
            if (result) {
                _this.service.cancelStory(_this.id).then(function (data) {
                    window.location = window.location;
                }, function (data) { });
            }
        });
    };
    /**
     * Sets current tab. 0 - story, 1-N+1 activities
     * @param indx
     * @returns {}
     */
    StoryPublisherDetailsViewModel.prototype.setActiveTab = function (indx) {
        if (indx >= 0 && indx <= this.activities.length) {
            this.isActive = false;
            this.activities.map(function (value) { return value.isActive = false; });
            if (indx === 0)
                this.isActive = true;
            else {
                this.isEditMode = false;
                this.activities[indx - 1].isActive = true;
            }
        }
    };
    return StoryPublisherDetailsViewModel;
})(StoryViewModel);
//# sourceMappingURL=StoryPublisherDetailsViewModel.js.map
var NotificationViewModel = (function () {
    function NotificationViewModel(model, props) {
        this.isRead = false;
        this.isOpen = false;
        this.recipients = [];
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        if (model) {
            this.id = model.id;
            this.dateSent = model.dateSent;
            this.text = model.text;
            this.subject = model.subject;
            this.type = model.type;
            this.status = model.status;
            this.isRead = model.isRead;
            this.sender = new UserViewModel(model.sender);
            if (model.recipients)
                this.recipients = model.recipients.map(function (x) { return new UserViewModel(x); });
        }
    }
    NotificationViewModel.prototype.openClose = function () {
        var _this = this;
        this.isOpen = !this.isOpen;
        if (!this.isRead && this.isOpen) {
            this.service.markNotificationAsRead(this.id).then(function (x) {
                _this.isRead = true;
            }, function (error) { });
        }
    };
    return NotificationViewModel;
})();
//# sourceMappingURL=NotificationViewModel.js.map
var NotificationsViewModel = (function () {
    function NotificationsViewModel(props) {
        this.pageSize = 10;
        this.totalItems = 1;
        this.page = 1;
        this.isLoading = false;
        this._folderType = "inbox";
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.initialize();
        }
    }
    Object.defineProperty(NotificationsViewModel.prototype, "folderType", {
        get: function () { return this._folderType; },
        set: function (value) { this._folderType = value; this.folderChanged(); },
        enumerable: true,
        configurable: true
    });
    NotificationsViewModel.prototype.folderChanged = function () {
        this.page = 1;
        this.totalItems = 0;
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.initialize = function () {
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.pageChanged = function (newPage) {
        this.page = newPage;
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.fetchNotifications = function () {
        var _this = this;
        var promise = null;
        if (this._folderType === 'inbox') {
            promise = this.service.getInboxNotifications(this.page, this.pageSize);
        }
        else {
            promise = this.service.getOutboxNotifications(this.page, this.pageSize);
        }
        this.isLoading = true;
        promise.then(function (data) {
            _this.notifications = data.notifications.map(function (x) { return new NotificationViewModel(x, { service: _this.service, dialogs: _this.dialogs }); });
            _this.totalItems = data.totalItems;
            _this.isLoading = false;
        }, function (error) {
            _this.isLoading = false;
        });
    };
    NotificationsViewModel.prototype.archiveNotification = function (indx) {
        var _this = this;
        if (indx < 0 || indx >= this.notifications.length)
            return;
        this.dialogs.showArchiveNotificationConfirm().result.then(function (result) {
            if (result) {
                _this.isLoading = true;
                _this.service.archiveNotification(_this.notifications[indx].id).then(function (x) {
                    _this.fetchNotifications();
                }, function (error) { _this.isLoading = false; });
            }
        });
    };
    return NotificationsViewModel;
})();
//# sourceMappingURL=NotificationsViewModel.js.map
var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
 * Base class for the tabs viewmodels on search page
 */
var PaginatedSearchViewModel = (function () {
    function PaginatedSearchViewModel(props) {
        this.isLoading = false;
        this.pageSize = 10;
        this.totalItems = 0;
        this.page = 1;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    return PaginatedSearchViewModel;
})();
/**
 * Search page tabs
 */
var SearchTabs;
(function (SearchTabs) {
    SearchTabs[SearchTabs["All"] = 0] = "All";
    SearchTabs[SearchTabs["Stories"] = 1] = "Stories";
    SearchTabs[SearchTabs["Activities"] = 2] = "Activities";
    SearchTabs[SearchTabs["Members"] = 3] = "Members";
})(SearchTabs || (SearchTabs = {}));
/**
 *  Search page viewmodel
 */
var SearchViewModel = (function () {
    function SearchViewModel(props) {
        this.isLoading = false;
        this.oldQuery = "";
        this.newQuery = "";
        this.currentTab = SearchTabs.All;
        this.allResults = new AllResultsSearchViewModel();
        this.members = new MembersSearchViewModel();
        this.stories = new StoriesSearchViewModel();
        this.activities = new ActivitiesSearchViewModel();
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        this.allResults = new AllResultsSearchViewModel(props);
        this.members = new MembersSearchViewModel(props);
        this.stories = new StoriesSearchViewModel(props);
        this.activities = new ActivitiesSearchViewModel(props);
    }
    /**
     * sets current tab
     * @param tab new tab
     * @returns {void}
     */
    SearchViewModel.prototype.setCurrentTab = function (tab) {
        this.currentTab = tab;
    };
    /**
     * fires search for all tabs
     * @returns {void}
     */
    SearchViewModel.prototype.search = function () {
        var _this = this;
        if (!this.newQuery)
            this.newQuery = this.oldQuery;
        else
            this.oldQuery = this.newQuery;
        this.isLoading = true;
        this.allResults.search(this.newQuery, function () { return _this.isLoading = false; });
        this.members.search(this.newQuery);
        this.stories.search(this.newQuery);
        this.activities.search(this.newQuery);
    };
    /**
     * method for the publisher's "invite member" functionality
     * @param member member to invite
     * @returns {}
     */
    SearchViewModel.prototype.inviteMember = function (member) {
        var subject = MEMBER_SEARCH_TEMPLATE.subject;
        var firstName = member ? member.firstName : "<enter member's name>";
        this.dialogs.showPublisherSelectActivity().result.then(function (result) {
            var activityName = result ? result.title : "<enter Activity's Name>";
            var body = MEMBER_SEARCH_TEMPLATE.body.replace("{{userFirstName}}", firstName).replace("{{activityName}}", activityName);
            window.location = ("mailto:" + member.email + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body));
        });
    };
    return SearchViewModel;
})();
/**
 * All results tab viewmodel
 */
var AllResultsSearchViewModel = (function (_super) {
    __extends(AllResultsSearchViewModel, _super);
    function AllResultsSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    /**
     * searches all results for the provided query
     * @param query search term
     * @param callback callback function
     * @returns {void}
     */
    AllResultsSearchViewModel.prototype.search = function (query, callback) {
        if (query)
            this.query = query;
        this.fetchRecords(callback);
    };
    /**
     * fetches records from server
     * @param callback callback function
     * @returns {void}
     */
    AllResultsSearchViewModel.prototype.fetchRecords = function (callback) {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.search({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.records.map(function (result) {
                if (result.type === "user")
                    return new UserViewModel(result.item);
                else if (result.type === "activity")
                    return new ActivityViewModel(result.item);
                else if (result.type === "story")
                    return new StoryViewModel(result.item);
                return result.item;
            });
            _this.isLoading = false;
            if (callback)
                callback();
        }, function (error) { _this.isLoading = false; if (callback)
            callback(); });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    AllResultsSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchRecords();
    };
    return AllResultsSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Members tab viewmodel
 */
var MembersSearchViewModel = (function (_super) {
    __extends(MembersSearchViewModel, _super);
    function MembersSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new MembersSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    MembersSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * filters the results
     * @returns {}
     */
    MembersSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    MembersSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchMembers();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    MembersSearchViewModel.prototype.fetchMembers = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchMembers({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.members.map(function (x) { return new UserViewModel(x); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    MembersSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchMembers();
    };
    return MembersSearchViewModel;
})(PaginatedSearchViewModel);
var StoriesSearchViewModel = (function (_super) {
    __extends(StoriesSearchViewModel, _super);
    function StoriesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new StoriesSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    StoriesSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    StoriesSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchStories();
    };
    /**
     * filters the results
     * @returns {}
     */
    StoriesSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    StoriesSearchViewModel.prototype.fetchStories = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchStories({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.stories.map(function (x) { return new StoryViewModel(x); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    StoriesSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchStories();
    };
    return StoriesSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Viewmodel for the activities tab on search page
 */
var ActivitiesSearchViewModel = (function (_super) {
    __extends(ActivitiesSearchViewModel, _super);
    function ActivitiesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new ActivitiesSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    ActivitiesSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchActivities();
    };
    /**
     * filters the results
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    ActivitiesSearchViewModel.prototype.fetchActivities = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchActivities({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.activities.map(function (x) { return new ActivityViewModel(x, { dialogs: _this.dialogs, service: _this.service }); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchActivities();
    };
    return ActivitiesSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Stories tab filter viewModel
 */
var StoriesSeachFilter = (function () {
    function StoriesSeachFilter() {
        this.serviceOffering = "all";
        this.status = "all";
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    StoriesSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    StoriesSeachFilter.prototype.clear = function () {
        this.title = "";
        this.description = "";
        this.serviceOffering = "all";
        this.status = "all";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    StoriesSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.serviceOffering === "all")
            delete model.serviceOffering;
        if (model.status === "all")
            delete model.status;
        return model;
    };
    return StoriesSeachFilter;
})();
/**
 * Activities tab filter viewModel
 */
var ActivitiesSeachFilter = (function () {
    function ActivitiesSeachFilter() {
        this.challengeType = "all";
        this.phase = "all";
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    ActivitiesSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    ActivitiesSeachFilter.prototype.clear = function () {
        this.title = "";
        this.description = "";
        this.challengeType = "all";
        this.phase = "all";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    ActivitiesSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.challengeType === "all")
            delete model.challengeType;
        if (model.phase === "all")
            delete model.phase;
        return model;
    };
    return ActivitiesSeachFilter;
})();
/**
 * Members tab filter viewModel
 */
var MembersSeachFilter = (function () {
    function MembersSeachFilter() {
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    MembersSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    MembersSeachFilter.prototype.clear = function () {
        this.firstName = "";
        this.lastName = "";
        this.organization = "";
        this.role = "";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    MembersSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        return model;
    };
    return MembersSeachFilter;
})();
//# sourceMappingURL=SearchViewModel.js.map
