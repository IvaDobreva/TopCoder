 /**
 * ViewModel for the stories list filter
 */
class StoriesFilterViewModel {
    storyTitle: string = "";
    activityTitle: string = "";
    serviceOffering: string = "";
    activityPhase: string = "";
    showOnlyCompleted: boolean = false;
    isActive: boolean = false;
    constructor() {
        this.clear();
    }

    clear() {
        this.storyTitle = "";
        this.activityTitle = "";
        this.serviceOffering = "";
        this.activityPhase = "";
    }
    getModel() {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.serviceOffering === "all") delete model.serviceOffering;
        if (model.activityPhase === "all") delete model.activityPhase;
        return model;
    }
}