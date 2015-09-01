 /**
 * Story Details ViewModel for the publisher
 */ 
class StoryPublisherDetailsViewModel extends StoryViewModel {
    service: any;
    dialogs: any;
    isEditMode: boolean = false;
    isInitialized: boolean = false;
    constructor(params: any) {
        super(<any>{ id: params.id });
        this.service = params.service;
        this.dialogs = params.dialogs;
        this.refresh();
        this.isActive = true;
    }
    /**
     * calculates how many days passed from the story start
     * @returns {} 
     */
    get daysPassed() {
        return moment.duration(moment().diff(moment(this.storyStart))).asDays();
    }
    /**
     * refreshes current story
     * @returns {} 
     */
    refresh() {
        this.service.getStory(this.id, true).then(data => {
            var vm = new StoryViewModel(data, { service: this.service, dialogs: this.dialogs });
            vm.setStartOffsets();
            if (this.service) {
                vm.activities.map(value => {
                    (<ActivityViewModel>value).chatterUrl = this.service.trustAsResourceUrl(GLOBAL_CONFIG.activityChatterUrl+"?id=" + value.id);
                });
            }
            copyFields(this, vm);
            this.isInitialized = true;
        }, data => { });;
    }
    /**
     * updates current story
     * @returns {} 
     */
    updateStory() {
        this.service.upsertStory({
            id: this.id,
            title: this.title,
            description: this.description,
            serviceOffering: this.serviceOffering
        }).then(data => {
            this.isEditMode = false;
        }, data=> { });
    }
    /**
     * Enable edit mode for the story
     * @returns {} 
     */
    editStory() {
        this.isEditMode = true;
    }
    cancelEditMode() {
        this.isEditMode = false;
    }
    /**
     * Canceles edit mode for the story
     * @returns {} 
     */
    closeStory() {
        this.dialogs.showRegistrationConfirm().result.then(result => {
            if (result) {
                this.service.cancelStory(this.id).then(data => {
                    window.location = window.location;
                }, data=> { });
            }
        });
       
    }
    /**
     * Sets current tab. 0 - story, 1-N+1 activities
     * @param indx 
     * @returns {} 
     */
    setActiveTab(indx: number) {
        
        if (indx >= 0 && indx <= this.activities.length) {
            this.isActive = false;
            this.activities.map(value => (<ActivityViewModel>value).isActive = false);
            if (indx === 0) this.isActive = true;

            else {
                this.isEditMode = false;
                (<ActivityViewModel>this.activities[indx - 1]).isActive = true;
            }
        }
    }
}