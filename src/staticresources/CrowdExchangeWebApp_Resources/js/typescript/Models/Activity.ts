 /**
 * Class with basic info about activity
 */ 
class Activity { 
    id: string;
    title: string = "";
    description: string ="";
    challengeType: string = "Assigned";
    phase: string = "";
    codeTypes: CodeType[] = [];
    story: Story;
    milestones: ActivityMilestone[];
    isRegistered: boolean;
    noPrizes: boolean = false;
    requirements: Array<ActivityRequirement> = [];
    prizes: Array<ActivityPrize> = [new ActivityPrize()];
    documents: ActivityDocument[] = [];
    registrationsCount: number = 0;
    submissionsCount: number = 0;
    assignedMember: UserViewModel;
    constructor(activity? : Activity) {
        if (activity) {
            this.id = activity.id;
            this.title = activity.title;
            this.challengeType = activity.challengeType;
            if (activity.codeTypes)
                this.codeTypes = activity.codeTypes.length ? activity.codeTypes.map(value=> new CodeType(value.name, value.skillId, value.id)) : undefined;
            if (activity.milestones)
                this.milestones = activity.milestones.map(value=>new ActivityMilestone(value));
            this.noPrizes = activity.noPrizes;
            if (activity.requirements)
                this.requirements = activity.requirements.map(value=> new ActivityRequirement(value));
            if (activity.prizes)
                this.prizes = activity.prizes.map(value=> new ActivityPrize(value));
            this.story = activity.story;
            this.documents = activity.documents;
            this.description = jQuery("<div/>").html(activity.description).text(); // unescape xml encoded HTML
            this.phase = activity.phase;
            this.registrationsCount = activity.registrationsCount;
            this.submissionsCount = activity.submissionsCount;
            this.isRegistered = activity.isRegistered;
            if(activity.assignedMember)
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
    getModel() {
        return {
            id: this.id,
            title: this.title,
            description: this.description,
            challengeType: this.challengeType,
            phase: this.phase,
            codeTypes: this.codeTypes ? this.codeTypes.map(value => new CodeType(value.name, value.skillId, value.id)) : [],
            milestones: this.milestones.map(value=> value.getModel()),
            isRegistered: this.isRegistered,
            noPrizes: this.noPrizes,
            requirements: this.requirements.map(value=> value.getModel()),
            prizes: this.noPrizes?[]:this.prizes.map(value=> value.getModel())
        }
    }
}