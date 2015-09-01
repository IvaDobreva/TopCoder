/**
 *  Model contains information about Activity's registration
 */
var ActivityRegistration = (function () {
    function ActivityRegistration(model) {
        this.user = new UserViewModel();
        if (model) {
            this.id = model.id;
            this.registrationDate = model.registrationDate;
            this.user = new UserViewModel(model.user);
        }
    }
    return ActivityRegistration;
})();
//# sourceMappingURL=ActivityRegistration.js.map