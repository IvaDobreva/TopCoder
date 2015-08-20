/**
 *  Model holds information about Activity's submission
 */
var ActivitySubmission = (function () {
    function ActivitySubmission(model) {
        this.user = new UserViewModel();
        if (model) {
            this.id = model.id;
            this.submissionnDate = model.submissionnDate;
            this.user = new UserViewModel(model.user);
        }
    }
    return ActivitySubmission;
})();
//# sourceMappingURL=ActivitySubmission.js.map