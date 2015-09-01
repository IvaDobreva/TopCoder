/**
* ViewModel for the activity's recomended members collection
*/
var ActivityRecomendedMembersViewModel = (function () {
    function ActivityRecomendedMembersViewModel(activityId, props) {
        this.isInitialized = false;
        this.recomendedUsers = [];
        this._selectAll = false;
        this.activityId = activityId;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    Object.defineProperty(ActivityRecomendedMembersViewModel.prototype, "selectAll", {
        /**
         * returns select all property
         * @returns {}
         */
        get: function () {
            return this._selectAll;
        },
        /**
         * selects or deselects all members
         * @param value
         * @returns {}
         */
        set: function (value) {
            var _this = this;
            this._selectAll = value;
            this.recomendedUsers.map(function (usr) { return usr.selected = _this._selectAll; });
        },
        enumerable: true,
        configurable: true
    });
    /**
     * initialize collection
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.initialize = function () {
        var _this = this;
        if (this.isInitialized)
            return;
        this.isInitialized = true;
        this.service.getRecommendedMembers(this.activityId).then(function (data) {
            _this.recomendedUsers = data;
        }, function (data) {
            _this.isInitialized = false;
        });
    };
    /**
     * sends email to the selected members
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailSelected = function () {
        var ids = [];
        this.recomendedUsers.map(function (value) {
            if (value.selected)
                ids.push(value.id);
        });
        this.emailMembers(ids);
    };
    /**
     * sends email to the particular user
     * @param userId user's id
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailMember = function (userId) {
        this.emailMembers([userId]);
    };
    /**
     * sends email to the particular users
     * @param userIds array of users' ids
     * @returns {}
     */
    ActivityRecomendedMembersViewModel.prototype.emailMembers = function (userIds) {
        this.service.emailToMember(userIds).then(function (data) {
        }, function (data) {
        });
    };
    return ActivityRecomendedMembersViewModel;
})();
//# sourceMappingURL=ActivityRecomendedMembersViewModel.js.map