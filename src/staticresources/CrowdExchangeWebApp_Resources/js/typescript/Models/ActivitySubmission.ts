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