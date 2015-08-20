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