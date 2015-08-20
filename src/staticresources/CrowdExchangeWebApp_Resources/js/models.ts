/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/moment/moment.d.ts"/>
/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/angularjs/angular.d.ts"/>
/// <reference path="../../../../../../Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/moment/moment.d.ts" />
/// <reference path="../../../../../../Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/angularjs/angular.d.ts" />
/// <reference path="../../../../../../Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/underscore/underscore.d.ts" />
declare var GLOBAL_CONFIG: any;
declare var copyFields: any;
copyFields = (d, b) => {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
};
//funciton for wrapping SFDC Remote methods in promise
var getStandardCallback = deferred => {
    var callback = (result, event) => {
        if (event.status) {
            deferred.resolve(result);
        } else {
            deferred.reject(event.message);
        }
    };
    return callback;
};
/**
 * User view model
 */
class UserViewModel {
    role: string;
    firstName: string;
    lastName: string;
    organization: string;
    id: string;
    photoUrl: string;
    constructor(model?: UserViewModel) {
        if (model) {
            jQuery.extend(this, model);
        }

    }
    get fullName(): string {
        return ((this.firstName || "") + " " + (this.lastName || "")).trim();
    }
}
/**
 *  Model contains information about Activity's registration
 */
class ActivityRegistration {
    id: string;
    registrationDate: Date;
    user: UserViewModel = new UserViewModel();
    constructor(model?: ActivityRegistration) {
        if (model) {
            this.id = model.id;
            this.registrationDate = model.registrationDate;
            this.user = new UserViewModel(model.user);
        }
    }
}
/**
 *  Model holds information about Activity's submission
 */
class ActivitySubmission {
    id: string;
    submissionnDate: Date;
    user: UserViewModel = new UserViewModel();
    constructor(model?: ActivitySubmission) {
        if (model) {
            this.id = model.id;
            this.submissionnDate = model.submissionnDate;
            this.user = new UserViewModel(model.user);
        }
    }
}
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
/**
 * Class with basic info about skill(Activity's, User's and standard)
 */
class CodeType {
    constructor(name?: string, id?: string, skillId?: string) {
        
        this.name = name;
        this.id = id;
        this.skillId = skillId;
    }
    name: string;
    id: string;
    skillId:string;
}
/**
 * Class with info about Activity's milestone
 */
class ActivityMilestone {
    scheduledDate: any;
    completedDate: any;
    name: string;
    constructor(model?: any) {
        if (model) {
            this.scheduledDate = model.scheduledDate ? moment.utc(model.scheduledDate).toDate() : null;
            this.completedDate = model.completedDate ? moment.utc(model.completedDate).toDate() : null;
            this.name = model.name;
        }
    }
    /**
     * Calculates offset from other milestone in days 
     * @param milestone 
     * @returns {offset in days} 
     */
    getOffset(milestone: any) {
        if (!milestone) return 0;
        return (moment.duration(moment(this.scheduledDate).diff(moment(milestone.scheduledDate))).asDays());
    }
    /**
     * Getting DTO model
     * @returns {DTO model for RemoteAction} 
     */
    getModel() {
        var scheduled = moment(this.scheduledDate);
        var completed = moment(this.completedDate);
        return {
            name: this.name,
            scheduledDate: this.scheduledDate ? scheduled.subtract(scheduled.zone(), 'minutes').toDate().toUTCString() : undefined,
            completedDate: this.completedDate ? completed.subtract(completed.zone(), 'minutes').toDate().toUTCString() : undefined
        }
    }
}
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
            this.codeTypes = activity.codeTypes.length ? activity.codeTypes.map(value=> new CodeType(value.name,value.skillId,value.id)) : undefined;
            this.milestones = activity.milestones.map(value=>new ActivityMilestone(value));
            this.noPrizes = activity.noPrizes;
            this.requirements = activity.requirements.map(value=> new ActivityRequirement(value));
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
/**
 * Class with basic info about Activity's document(Attachment)
 */
class ActivityDocument {
    id: string;
    description: string;
    name: string;
    createdDate: Date;
}
/**
 * Class with info about Activity's award
 */
class ActivityPrize {
    id: string;
    place: number = 1;
    amount: number = 0;
    constructor(prize?: ActivityPrize) {
        if (prize) {
            this.id = prize.id;
            this.place = prize.place;
            this.amount = prize.amount;
        }
    }
    /**
     * Makes places label
     * @returns {} 
     */
    get placeLabel() {
        var appendix = '';
        switch (this.place) {
            case 1:
                appendix = "st";
                break;
            case 2:
                appendix = "nd";
                break;
            case 3:
                appendix = "rd";
                break;
            default:
                appendix = "th";
        }
        return this.place + appendix;
    }
   /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction} 
    */
    getModel() {
        return {
            id: this.id,
            place: this.place,
            amount: this.amount
        }
    }
}
/**
 * Class with info about Activity's requirement
 */
class ActivityRequirement {
    id: string;
    childRequirements: Array<ActivityRequirement> = [];
    requirementNumber: string;
    requirementType: string = "";
    importance: string = "";
    description: string = "";
    constructor(requirement?: ActivityRequirement) {
        if (requirement) {
            this.description = jQuery("<div/>").html(requirement.description).text();
            this.id = requirement.id;
            this.requirementType = requirement['type'];
            this.importance = requirement.importance;
            this.requirementNumber = requirement.requirementNumber;
            this.childRequirements = requirement.childRequirements.map(value=> new ActivityRequirement(value));
        }
    }
   /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction} 
    */
    getModel() {
        return {
            id: this.id,
            requirementNumber: this.requirementNumber,
            'type': this.requirementType,
            importance: this.importance,
            childRequirements: this.childRequirements.map(value=> value.getModel()),
            description: this.description
        }
    }
}
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
        this.story = new StoryViewModel();
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
/**
 * Base Story ViewModel
 */
class StoryViewModel extends Story {
    isActive: boolean = true;
    storyStart: any;
    storyEnd: any;
    
    constructor(story?: Story, props?: any) {
        super(story);
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
            this.activities.splice(index, 1);
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
/**
 * Story Details VIewModel for the publisher
 */
class StoryPublisherDetailsViewModel extends StoryViewModel {
    service: any;
    dialogs: any;
    isEditMode: boolean = false;
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
/**
 * ViewModel for the list of activity's registrants
 */
class ActivityRegistrantsViewModel {
    isInitialized: boolean = false;
    assignedUsers: ActivityRegistration;
    registrants: ActivityRegistration[] = [];
    page: number = 1;
    pageSize: number = 8;
    totalRegistrants: number;
    activityId: string;
    service: any;
    dialogs: any;

    constructor(activityId: string, props: any) {
        this.activityId = activityId;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    /**
     * sends email to the user
     * @param userId user's Id
     * @returns {} 
     */
    emailMember(userId: string) {
        this.service.emailToMember([userId]).then(data => {

        }, data => {

            });
    }
    /**
     * Page changed handler
     * @param newPage new page number
     * @returns {} 
     */
    pageChanged(newPage: number) {
        this.fetchRegistrants();
    }
    /**
     * initialize collection
     * @returns {} 
     */
    initialize() {
        if (this.isInitialized) return;
        this.isInitialized = true;
        this.fetchRegistrants();
    }
    /**
     * fetches current page of registrants
     * @returns {} 
     */
    fetchRegistrants() {
        this.service.getRegistrants(this.activityId, this.page, this.pageSize).then(data => {
            this.registrants = data;

        }, data => {

            });
    }
}
/**
 * ViewModel for the activity's recomended members collection
 */
class ActivityRecomendedMembersViewModel {
    isInitialized: boolean = false;
    recomendedUsers: any[] = [];
    activityId: string;
    service: any;
    dialogs: any;
    private _selectAll: boolean = false;
    /**
     * selects or deselects all members
     * @param value 
     * @returns {} 
     */
    set selectAll(value: boolean ) {
        this._selectAll = value;
        this.recomendedUsers.map(usr => usr.selected = this._selectAll);
    }
    /**
     * returns select all property
     * @returns {} 
     */
    get selectAll(): boolean {
        return this._selectAll;
    }
    constructor(activityId: string, props: any) {
        this.activityId = activityId;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    /**
     * initialize collection
     * @returns {} 
     */
    initialize() {
        if (this.isInitialized) return;
        this.isInitialized = true;
        this.service.getRecommendedMembers(this.activityId).then(data => {
            this.recomendedUsers = data;
        }, data => {
                this.isInitialized = false;
            });
    }
    /**
     * sends email to the selected members
     * @returns {} 
     */
    emailSelected() {
        var ids = [];
        this.recomendedUsers.map(value => {
            if (value.selected)
                ids.push(value.id);
        });
        this.emailMembers(ids);
    }
    /**
     * sends email to the particular user
     * @param userId user's id
     * @returns {} 
     */
    emailMember(userId: string) {
        this.emailMembers([userId]);
    }
    /**
     * sends email to the particular users
     * @param userIds array of users' ids
     * @returns {} 
     */
    emailMembers(userIds: string[]) {
        this.service.emailToMember(userIds).then(data => {

        }, data => {

            });
    }
}/**
  * Main Activity viewModel
  */
class ActivityViewModel extends Activity {
    chatterUrl: any;
    registrants: ActivityRegistrantsViewModel;
    recomendations: ActivityRecomendedMembersViewModel;
    isActive: boolean = false;
    activeTab: number = 0;
    startOffset: number = 0;
    fileToUpload: any = { file: null, description: "", fileName: "" };
    defaultSkills: any[] = [];
    service: any;
    dialogs: any;
    /**
     * returnes duration for the particular milestone
     * @param indx index of milestone
     * @returns {} 
     */
    milestoneDuration(indx: number) {
        if (indx === this.milestones.length - 1) return 0;
        var ms = 0;
        ms = moment(this.milestones[indx + 1].scheduledDate).diff(moment(this.milestones[indx].scheduledDate));
        return moment.duration(ms).asDays();
    }
    constructor(activity?: Activity,props?: any) {
        super(activity);
        if (activity) {
            delete this.requirements;
            this.requirements = activity.requirements.map(value=> new ActivityRequirementViewModel(value));
        }
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.registrants = new ActivityRegistrantsViewModel(this.id, props);
            this.recomendations = new ActivityRecomendedMembersViewModel(this.id, props);
            this.registrants.totalRegistrants = this.registrationsCount;
            if (this.service&&activity) {
                this.chatterUrl = this.service.trustAsResourceUrl(GLOBAL_CONFIG.activityChatterUrl + "?id=" + this.id);
            }
        }
    }
    /**
     * removes the requirement from the activity
     * @param indx index of reuirement
     * @returns {} 
     */
    removeRequirement(indx: number) {
        this.requirements.splice(indx, 1);
        this.requirements.map((parent, parentIndx) => {
            parent.requirementNumber = (parentIndx + 1) + ".0";
            parent.childRequirements.map((child, childIndx) => child.requirementNumber = (parentIndx + 1) + "." + (childIndx + 1));
        });
    }
    /**
     * selects tab
     * 0 - activity details, 1 -registrants, 2 - recomended members, 
     * 3 - chatter, 4 - submissions, 5 - review
     * @param indx tab index to go to
     * @returns {} 
     */
    selectTab(indx:number) {
        this.activeTab = indx;
        switch (indx) {
            case 1:
                this.registrants.initialize();
                break;
            case 2:
                this.recomendations.initialize();
                break;
            case 3:
                break;
            case 4:
                break;
            case 5:
                break;
        default:
        }
    }
    /**
     * registers current user to the activity
     * @returns {} 
     */
    registerToActivity() {
        this.dialogs.showRegistrationConfirm().result.then(result => {
            if (result) {
                this.service.registerToActivity(this.id).then(data => {
                    this.isRegistered = true;
                }, data=> { });
            }
        });
    } 
    /**
     * sets default skills collection
     * @param types array of default skills
     * @returns {} 
     */
    setDefaultCodeTypes(types: any[]) {
        var codeTypes = this.codeTypes;
        this.codeTypes = [];
        var selected = [];
        _.map(types, item => {
            var obj = _.extend(new CodeType(item.name, item.skillId, item.id), _.findWhere(codeTypes, { id: item.skillId }));
            delete obj.$$hashKey;
            this.defaultSkills.push(obj);
            if (obj.skillId) selected.push(obj);
            return obj;
        });
        setTimeout(() => {
            selected.map(v=> this.codeTypes.push(v));
        }, 100);
    }
    /**
     * adds a requirement to the current activity
     * @returns {} 
     */
    addRequirement() {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = (this.requirements.length+1)+".0";
        this.requirements.push(newRequirement);
    }
    /**
     * adds a award to the current activity
     * @returns {} 
     */
    addPrize() {
        if (this.noPrizes) return;
        var newPrize = new ActivityPrize();
        newPrize.place = this.prizes.length + 1;
        this.prizes.push(newPrize);
    }
    /**
     * removes the award from the current activity
     * @param indx index of the award to remove
     * @returns {} 
     */
    removePrize(indx: number) {
        if (this.noPrizes) return;
        this.prizes.splice(indx, 1);
        for (var i = this.prizes.length; i > 0; i--) {
            this.prizes[i - 1].place = i;
        }
    }
    /**
     * calculates activity's duration
     * @returns {} 
     */
    get activityDuration() {
        return this.milestones[this.milestones.length - 1].getOffset(this.milestones[0]);
    }
    /**
     * uploads document for the current activity
     * @returns {} 
     */
    uploadFile() {
        var dialog = this.dialogs.showLoading();
        if (this.fileToUpload.file) {
            var file = {
                description: this.fileToUpload.description,
                name: this.fileToUpload.fileName,
                body: this.fileToUpload.file.substring(this.fileToUpload.file.indexOf('base64')+7),
                parentId: this.id
            };
            delete this.fileToUpload;
            this.fileToUpload = {};
            this.service.uploadAttachment(file).then(data => {
                
                dialog.close();
                if (data[0].success) {
                    var newDocument = new ActivityDocument();
                    newDocument.id = data[0].id;
                    newDocument.description = file.description;
                    newDocument.name = file.name;
                    newDocument.createdDate = new Date();
                    this.documents.push(newDocument);
                }
            }, data => {
                    dialog.close();
            }, progress => {
                    dialog.close(); 
            });
        }
        
    }
    /**
     * file selected callback
     * @param fileInput input[type=file]
     * @returns {} 
     */
    addFile(fileInput:any) {
        this.fileToUpload.file = fileInput.files.length ? fileInput.files[0] : null;
    }
    deleteDocument(indx: number) {
        if (indx < 0 || indx >= this.documents.length)
            return;
        var document = this.documents[indx];
        if (document) {
            this.dialogs.showRegistrationConfirm().result.then(result => {
                if (result) {
                    var dialog = this.dialogs.showLoading();
                    this.service.deleteDocument(document.id).then(data => {
                        this.documents.splice(indx, 1);
                        dialog.close();
                    }, data => { dialog.close(); });
                }
            });

        }
    }
    /**
     * assigned member to the current activity
     * @param user 
     * @returns {} 
     */
    assignMember(user: any) {
        this.dialogs.showAssignMember(this.title, user.firstName + ' ' + user.lastName).result.then(result => {
            if (result) {
                this.service.assignMember(this.id, user.id).then((user) => {
                    this.assignedMember = user;
                }, error => {

                });
            }
        });  
    }
    /**
     * removes assignment from the activity
     * @returns {} 
     */
    unassignMember() {
        this.service.unassignMember(this.id).then(() => {
            this.assignedMember = null;
        }, error => {

        });
    }
    /**
     * saves the activity as a draft
     * @returns {} 
     */
    saveAsDraft() {
        this.phase = "Draft";
        this.upsert();
    }
    /**
     * publish activity
     * @returns {} 
     */
    publish() {
        this.phase = "Public";
        this.upsert();
    }
    /**
     * upserts current activity to the SFDC
     * @returns {} 
     */
    private upsert() {
        var dialog = this.phase === 'Draft' ? this.dialogs.showSavingDraftActivity() : this.dialogs.showLoading();
        if (this.id) {
            this.service.upsertActivity(this.getModel()).then(data => {
                dialog.close();
            }, data => { dialog.close(); });
        } else {
            this.service.createActivity({
                title: this.title,
                description: this.description,
                challengeType: this.challengeType,
                storyId: this.story.id,
                phase: this.phase
            }).then(data => {
                this.id = data.id;
                dialog.close();
            }, data => { dialog.close(); });
        }
    }
    /**
     * canceles activity
     * @returns {} 
     */
    cancelActivity() {
        this.dialogs.showCancelActivity(this.title).result.then(result => {
            if (result) {
                var dialogs = this.dialogs.showLoading();
                this.service.cancelActivity(this.id).then(data => {
                    this.phase = 'Canceled';
                    dialogs.close();
                }, data => {
                        dialogs.close();
                });
            }
        });
        
    }
    /**
     * completes activity
     * @returns {} 
     */
    completeActivity() {
        var dialogs = this.dialogs.showLoading();
        this.service.completeActivity(this.id).then(data => {
            this.phase = 'Completed';
            dialogs.close();
            window.location = window.location;
        }, data => {
            dialogs.close();
        });
    }
    /**
     * clones current activity
     * @returns {} 
     */
    clone() {
        return new ActivityViewModel(angular.fromJson(angular.toJson(this)));
    }
}
/**
 * ViewModel for the Activity's requirement
 */
class ActivityRequirementViewModel extends ActivityRequirement {
    /**
     * Adds new child requirements
     * @returns {} 
     */
    addRequirement() {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = this.requirementNumber.split(".")[0] + "." + (this.childRequirements.length + 1);
        this.childRequirements.push(newRequirement);
    }
    /**
     * removes child requirement
     * @param indx index of the child requirement to remove
     * @returns {} 
     */
    removeRequirement(indx: number) {
        this.childRequirements.splice(indx, 1);
        var parentNumber = this.requirementNumber.split(".")[0];
        this.childRequirements.map((child, childIndx) => child.requirementNumber = parentNumber + "." + (childIndx + 1));
    }
}
/**
 * Stories page ViewModel
 */
class StoriesViewModel {
    activeStories: StoriesListViewModel;
    completedStories: StoriesListViewModel;
    filter: StoriesFilterViewModel = new StoriesFilterViewModel();

    constructor(dataServices: any) {
        this.activeStories = new StoriesListViewModel(this.filter);
        this.activeStories.service = dataServices;
        this.activeStories.fetchStories();
        this.activeStories.isActive = true;
        this.completedStories = new StoriesListViewModel(this.filter, true);
        this.completedStories.service = dataServices;
        this.filter.showOnlyCompleted = true;
        this.completedStories.fetchStories();
        this.showTab(1);
    }
    /**
     * resets filter
     * @returns {} 
     */
    resetFilter() {
        this.filter.clear();
        this.filter.isActive = false;
        this.activeStories.fetchStories();
        this.completedStories.fetchStories();
    }
    /**
     * fetch filtered stories
     * @returns {} 
     */
    filterStories() {
        this.activeStories.fetchStories(true);
        this.completedStories.fetchStories(true);
    }
    /**
     * show particular tab
     * @param indx tab index. 1 - active stories, 2 - completed stories
     * @returns {} 
     */
    showTab(indx: number) {
        this.activeStories.isActive = indx === 1;
        this.completedStories.isActive = indx === 2;
    }
}
/**
 * Stories collection viewModel
 */
class StoriesListViewModel {
    stories: StoryViewModel[] = [];
    pageSize: number = 5;
    page: number = 1;
    totalPages: number = 1;
    totalItems: number = 0;
    isActive: Boolean = true;
    filter: StoriesFilterViewModel;
    fetchOnlyCompleted: boolean = false;
    isLoading: boolean = false;
    service: any;
    constructor(filter: StoriesFilterViewModel = new StoriesFilterViewModel(),fetchOnlyCompleted: boolean = false) {
        this.filter = filter;
        this.fetchOnlyCompleted = fetchOnlyCompleted;
    }
    /**
     * fetches stories with filter and pagination
     * @param fromStart 
     * @returns {} 
     */
    fetchStories(fromStart: boolean = false) {
        
        if (!this.filter)
            this.filter = new StoriesFilterViewModel();
        this.filter.showOnlyCompleted = this.fetchOnlyCompleted;
        if (this.isLoading) return;
        this.isLoading = true;
        if (fromStart) {
            this.page = 1;
            this.totalItems = 0;
            this.totalPages = 1;
            this.stories = [];
        }
        if (this.service != null && this.service.getStories != null) {
            this.service.getStories({
                page: this.page,
                pageSize: this.pageSize,
                filter: this.filter.getModel()
            }).then(data => {
                this.totalItems = data.totalItems;
                this.totalPages = data.totalPages;
                this.stories = data.stories.map((value, index, arr) => new StoryViewModel(value));
                this.isLoading = false;
            }, data => { this.isLoading = false; });;
        } else { this.isLoading = false;}
    }
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {} 
     */
    pageChanged(newPage: number) {
        this.fetchStories();
    }
    /**
     * Goes to the next page
     * @returns {} 
     */
    goToPage() {
        if (this.page === 1 || this.page === this.totalPages) return;
        this.fetchStories();
        this.fetchStories();
    }
}
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
