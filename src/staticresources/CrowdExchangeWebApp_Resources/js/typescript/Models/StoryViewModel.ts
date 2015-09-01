 /**
 * Base Story ViewModel
 */ 
class StoryViewModel extends Story {
    isActive: boolean = true;
    storyStart: any;
    storyEnd: any;
    service: any;
    dialogs: any;
    constructor(story?: Story, props?: any) {
        super(story);
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            
        }
        var activities = this.activities || [];
        this.activities = [];
        for (var i = 0; i < activities.length; i++) {
            this.activities.push(new ActivityViewModel(activities[i],props));
        }
    }
    /**
     * Adds activity to the story
     * @param index activity index to clone
     * @returns {} 
     */
    addActivity(index?: number) {
        //if index is provided clone activity and add to the end
        if (index !== undefined) {
            if (index >= 0 && index < this.activities.length) {
                var activity = this.activities[index];
                this.activities.push((<ActivityViewModel>activity).clone());
            }
        } else {
            //otherwise just add basic empty activity
            this.activities.push(new ActivityViewModel());
        }
    }
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {} 
     */
    removeActivity(index:number) {
        if (index !== undefined && index >= 0 && index < this.activities.length) {
            var activityId = this.activities[index].id;
            if (activityId) {
                var dialog = this.dialogs.showLoading();
                this.service.deleteActivity(activityId).then(data => {
                    this.activities.splice(index, 1);
                    dialog.close();
                }, error=> { dialog.close(); });
            } else {
                this.activities.splice(index, 1);
            }
            
        }
    }
    /**
     * Sets active tab.
     * @param indx tab index. -1 - story, 0-N activity
     * @returns {} 
     */
    setActiveTab(indx: number) {
        if (indx < -1 || indx >= this.activities.length) return;
        this.isActive = false;
        for (var i = 0; i < this.activities.length; i++) {
            (<ActivityViewModel>this.activities[i]).isActive = false;
        }
        if (indx < 0) this.isActive = true;
        else (<ActivityViewModel>this.activities[indx]).isActive = true;
    }
    /**
     * Sets start offsets for all activities
     * @returns {} 
     */
    setStartOffsets() {
        if (!this.activities || !this.activities.length) return;
        var minDate = moment(this.activities[0].milestones[0].scheduledDate);
        var maxDate = moment(this.activities[0].milestones[this.activities[0].milestones.length-1].scheduledDate);
        for (var i = 1; i < this.activities.length; i++) {
            var pubDate = moment(this.activities[i].milestones[0].scheduledDate);
            var endDate = moment(this.activities[i].milestones[this.activities[i].milestones.length - 1].scheduledDate);
            if (pubDate.diff(minDate) < 0) minDate = pubDate;
            if (endDate.diff(maxDate) > 0) maxDate = endDate;
        }
        this.storyStart = minDate.toDate();
        this.storyEnd = maxDate.toDate();
        for (var i = 1; i < this.activities.length; i++) {
            (<ActivityViewModel>this.activities[i]).startOffset = moment.duration(moment(this.activities[i].milestones[0].scheduledDate).diff(minDate)).asDays();
        }

    }
    /**
     * rcalculates story's duration in days
     * @returns {} 
     */
    get storyDuration() {
        this.setStartOffsets();
        var ms = moment(this.storyEnd).diff(moment(this.storyStart));
        var d = moment.duration(ms);
        return d.asDays();
    }
    /**
     * calculates story's cost
     * @returns {} 
     */
    get totalBudget() {
        var budget = 0;
        for (var i = 0; i < this.activities.length; i++) {
            var activity = this.activities[i];
            if (activity.noPrizes) continue;
            if(activity.prizes)
                for (var j = 0; j < activity.prizes.length; j++) {
                    budget += activity.prizes[j].amount;
                }
        }
        return budget;
    }
    /**
     * calculates total registrations number for the story
     * @returns {} 
     */
    get registrationsCount():number {
        var count = 0;
        this.activities.map(value => count += value.registrationsCount);
        return count;
    }
    /**
     * calculates total submissions number for the story
     * @returns {} 
     */
    get submissionsCount(): number {
        var count = 0;
        this.activities.map(value => count += value.submissionsCount);
        return count;
    }
}