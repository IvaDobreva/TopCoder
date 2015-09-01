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