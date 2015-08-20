 /**
 * Story base class with basic properties
 */ 
class Story {
    id: string;
    title: string = "";
    description: string = "";
    serviceOffering: string = null;
    phase: string = "";
    activities: Array<Activity> = [];
    publisher: UserViewModel;
    constructor(story?: Story) {
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
    getModel() {
        return {
            id: this.id,
            title: this.title,
            description: this.description,
            serviceOffering: this.serviceOffering,
            status: this.phase,
            activities: this.activities.map(value=>value.getModel())
        };
    }
}