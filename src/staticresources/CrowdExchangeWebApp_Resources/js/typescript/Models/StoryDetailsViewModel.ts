 /**
 * ViewModel for the member story details page
 */ 
class StoryDetailsViewModel extends StoryViewModel {
    service: any;
    dialogs: any;
    constructor(params:any) {
        super(<any>{ id: params.id });
        this.service = params.service;
        this.dialogs = params.dialogs;
        this.refresh();
    }
    /**
     * refreshes current story
     * @returns {} 
     */
    refresh() {
        this.service.getStory(this.id, true).then(data => {
            jQuery.extend(true, this, new StoryViewModel(data));
        }, data => { });;
    }
    /**
     * registers current user to the needed activity
     * @param activityId activity Id to register
     * @returns {} 
     */
    registerToActivity(activityId: string) {
        if (!activityId) return;
        this.dialogs.showRegistrationConfirm().result.then(result => {
            if (result) {
                this.service.registerToActivity(activityId).then(data => {
                    for (var i = 0; i < this.activities.length; i++) {
                        var activity = this.activities[i];
                        if (activity.id === activityId) {
                            activity.isRegistered = true;
                            break;
                        }
                    }
                }, data=> { });
            }
        });
    } 
}