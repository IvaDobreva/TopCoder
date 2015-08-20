var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
* Base Story ViewModel
*/
var StoryViewModel = (function (_super) {
    __extends(StoryViewModel, _super);
    function StoryViewModel(story, props) {
        _super.call(this, story);
        this.isActive = true;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        var activities = this.activities || [];
        this.activities = [];
        for (var i = 0; i < activities.length; i++) {
            this.activities.push(new ActivityViewModel(activities[i], props));
        }
    }
    /**
     * Adds activity to the story
     * @param index activity index to clone
     * @returns {}
     */
    StoryViewModel.prototype.addActivity = function (index) {
        //if index is provided clone activity and add to the end
        if (index !== undefined) {
            if (index >= 0 && index < this.activities.length) {
                var activity = this.activities[index];
                this.activities.push(activity.clone());
            }
        }
        else {
            //otherwise just add basic empty activity
            this.activities.push(new ActivityViewModel());
        }
    };
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {}
     */
    StoryViewModel.prototype.removeActivity = function (index) {
        var _this = this;
        if (index !== undefined && index >= 0 && index < this.activities.length) {
            var activityId = this.activities[index].id;
            if (activityId) {
                var dialog = this.dialogs.showLoading();
                this.service.deleteActivity(activityId).then(function (data) {
                    _this.activities.splice(index, 1);
                    dialog.close();
                }, function (error) { dialog.close(); });
            }
            else {
                this.activities.splice(index, 1);
            }
        }
    };
    /**
     * Sets active tab.
     * @param indx tab index. -1 - story, 0-N activity
     * @returns {}
     */
    StoryViewModel.prototype.setActiveTab = function (indx) {
        if (indx < -1 || indx >= this.activities.length)
            return;
        this.isActive = false;
        for (var i = 0; i < this.activities.length; i++) {
            this.activities[i].isActive = false;
        }
        if (indx < 0)
            this.isActive = true;
        else
            this.activities[indx].isActive = true;
    };
    /**
     * Sets start offsets for all activities
     * @returns {}
     */
    StoryViewModel.prototype.setStartOffsets = function () {
        if (!this.activities || !this.activities.length)
            return;
        var minDate = moment(this.activities[0].milestones[0].scheduledDate);
        var maxDate = moment(this.activities[0].milestones[this.activities[0].milestones.length - 1].scheduledDate);
        for (var i = 1; i < this.activities.length; i++) {
            var pubDate = moment(this.activities[i].milestones[0].scheduledDate);
            var endDate = moment(this.activities[i].milestones[this.activities[i].milestones.length - 1].scheduledDate);
            if (pubDate.diff(minDate) < 0)
                minDate = pubDate;
            if (endDate.diff(maxDate) > 0)
                maxDate = endDate;
        }
        this.storyStart = minDate.toDate();
        this.storyEnd = maxDate.toDate();
        for (var i = 1; i < this.activities.length; i++) {
            this.activities[i].startOffset = moment.duration(moment(this.activities[i].milestones[0].scheduledDate).diff(minDate)).asDays();
        }
    };
    Object.defineProperty(StoryViewModel.prototype, "storyDuration", {
        /**
         * rcalculates story's duration in days
         * @returns {}
         */
        get: function () {
            this.setStartOffsets();
            var ms = moment(this.storyEnd).diff(moment(this.storyStart));
            var d = moment.duration(ms);
            return d.asDays();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "totalBudget", {
        /**
         * calculates story's cost
         * @returns {}
         */
        get: function () {
            var budget = 0;
            for (var i = 0; i < this.activities.length; i++) {
                var activity = this.activities[i];
                if (activity.noPrizes)
                    continue;
                if (activity.prizes)
                    for (var j = 0; j < activity.prizes.length; j++) {
                        budget += activity.prizes[j].amount;
                    }
            }
            return budget;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "registrationsCount", {
        /**
         * calculates total registrations number for the story
         * @returns {}
         */
        get: function () {
            var count = 0;
            this.activities.map(function (value) { return count += value.registrationsCount; });
            return count;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(StoryViewModel.prototype, "submissionsCount", {
        /**
         * calculates total submissions number for the story
         * @returns {}
         */
        get: function () {
            var count = 0;
            this.activities.map(function (value) { return count += value.submissionsCount; });
            return count;
        },
        enumerable: true,
        configurable: true
    });
    return StoryViewModel;
})(Story);
//# sourceMappingURL=StoryViewModel.js.map