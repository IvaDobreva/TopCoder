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
}