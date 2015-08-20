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