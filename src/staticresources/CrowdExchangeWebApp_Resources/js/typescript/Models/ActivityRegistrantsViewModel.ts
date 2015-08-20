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