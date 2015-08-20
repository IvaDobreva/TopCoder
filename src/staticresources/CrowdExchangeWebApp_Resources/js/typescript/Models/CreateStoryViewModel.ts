 /**
 * ViewModel for th publisherCreateStory page
 */ 
class CreateStoryViewModel {
    step: number = 1;
    dateOptions: any;
    story: StoryViewModel;
    stepsCount: number;
    service: any;
    dialogs: any;
    constructor(props: any) {
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
    goToNext() {
        if (this.step === this.story.activities.length + 2) return;
        this.saveCurrentStep(true);

    }
    /**
     * Publish story
     * @returns {} 
     */
    publish() {
        this.story.phase = "In Progress";
        this.saveCurrentStep(true,() => window.location = <any>(document.location.href.match(/(^[^#]*)/)[0]) );
    }
    /**
     * Saves current step 
     * @param goToNext determines if after save we should go to the next step
     * @param callback callback success function 
     * @returns {} 
     */
    saveCurrentStep(goToNext: boolean = false, callback?: any) {
        var dialog = this.dialogs.showLoading();
        //saving story
        if (this.step === 1 || this.step === this.story.activities.length + 2) {
            this.service.upsertStory({
                id: this.story.id,
                title: this.story.title,
                description: this.story.description,
                serviceOffering: this.story.serviceOffering
            }).then(data => {
                this.story.id = data.id;
                if (goToNext)
                    this.step = this.step + 1;
                if (callback)
                    callback();
                dialog.close();
            }, data => { dialog.close(); });
        } else {
            //saving activity
            var activity = this.story.activities[this.step - 2];
            if (activity.id) {
                this.service.upsertActivity(activity.getModel()).then(data => {
                    if (goToNext)
                        this.step = this.step + 1;
                    dialog.close();
                }, data => { dialog.close(); });
            } else {
                this.service.createActivity({
                    title: activity.title,
                    description: activity.description,
                    challengeType: activity.challengeType,
                    storyId: this.story.id
                }).then(data => {
                    activity.id = data.id;
                    dialog.close();
                }, data => { dialog.close(); });
            }
        }
    }
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {} 
     */
    removeActivity(index: number) {
        this.dialogs.showRegistrationConfirm().result.then(() => {
            this.story.removeActivity(index);
            if (index === this.step + 1)this.step = this.step - 1;
        });

    }
    /**
     * Goes to the previous step
     * @returns {} 
     */
    goToPrev() {
        if (this.step === 1) return;
        this.step = this.step - 1;
    }
    /**
     * Goes to the specific step
     * @param step 
     * @returns {} 
     */
    goToStep(step: number) {
        if (this.step < 2 || step < 1 || step > this.story.activities.length + 2) return;
        this.step = step;
    }
}