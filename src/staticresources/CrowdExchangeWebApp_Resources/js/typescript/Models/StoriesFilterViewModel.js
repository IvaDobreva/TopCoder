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