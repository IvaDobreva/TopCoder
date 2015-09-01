/**
* ViewModel for the list of activity's registrants
*/
var ActivityRegistrantsViewModel = (function () {
    function ActivityRegistrantsViewModel(activityId, props) {
        this.isInitialized = false;
        this.registrants = [];
        this.page = 1;
        this.pageSize = 8;
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
    ActivityRegistrantsViewModel.prototype.emailMember = function (userId) {
        this.service.emailToMember([userId]).then(function (data) {
        }, function (data) {
        });
    };
    /**
     * Page changed handler
     * @param newPage new page number
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.pageChanged = function (newPage) {
        this.fetchRegistrants();
    };
    /**
     * initialize collection
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.initialize = function () {
        if (this.isInitialized)
            return;
        this.isInitialized = true;
        this.fetchRegistrants();
    };
    /**
     * fetches current page of registrants
     * @returns {}
     */
    ActivityRegistrantsViewModel.prototype.fetchRegistrants = function () {
        var _this = this;
        this.service.getRegistrants(this.activityId, this.page, this.pageSize).then(function (data) {
            _this.registrants = data;
        }, function (data) {
        });
    };
    return ActivityRegistrantsViewModel;
})();
//# sourceMappingURL=ActivityRegistrantsViewModel.js.map