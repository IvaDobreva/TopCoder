/**
* ViewModel for th publisherCreateStory page
*/
var CreateStoryViewModel = (function () {
    function CreateStoryViewModel(props) {
        this.step = 1;
        this.story = new StoryViewModel(null, props);
        this.story.activities.push(new ActivityViewModel(null, props));
        this.stepsCount = this.story.activities.length + 2;
        this.service = props.service;
        this.dialogs = props.dialogs;
    }
    /**
     * Saves current step and goes to the next
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToNext = function () {
        if (this.step === this.story.activities.length + 2)
            return;
        this.saveCurrentStep(true);
    };
    /**
     * Publish story
     * @returns {}
     */
    CreateStoryViewModel.prototype.publish = function () {
        this.story.phase = "In Progress";
        this.saveCurrentStep(true, function () { return window.location = (document.location.href.match(/(^[^#]*)/)[0]); });
    };
    /**
     * Saves current step
     * @param goToNext determines if after save we should go to the next step
     * @param callback callback success function
     * @returns {}
     */
    CreateStoryViewModel.prototype.saveCurrentStep = function (goToNext, callback) {
        var _this = this;
        if (goToNext === void 0) { goToNext = false; }
        var dialog = this.dialogs.showLoading();
        //saving story
        if (this.step === 1 || this.step === this.story.activities.length + 2) {
            this.service.upsertStory({
                id: this.story.id,
                title: this.story.title,
                description: this.story.description,
                serviceOffering: this.story.serviceOffering
            }).then(function (data) {
                _this.story.id = data.id;
                if (goToNext)
                    _this.step = _this.step + 1;
                if (callback)
                    callback();
                dialog.close();
            }, function (data) { dialog.close(); });
        }
        else {
            //saving activity
            var activity = this.story.activities[this.step - 2];
            if (activity.id) {
                this.service.upsertActivity(activity.getModel()).then(function (data) {
                    if (goToNext)
                        _this.step = _this.step + 1;
                    dialog.close();
                }, function (data) { dialog.close(); });
            }
            else {
                this.service.createActivity({
                    title: activity.title,
                    description: activity.description,
                    challengeType: activity.challengeType,
                    storyId: this.story.id
                }).then(function (data) {
                    activity.id = data.id;
                    dialog.close();
                }, function (data) { dialog.close(); });
            }
        }
    };
    /**
     * removes avtivity
     * @param index index of activity to remove
     * @returns {}
     */
    CreateStoryViewModel.prototype.removeActivity = function (index) {
        var _this = this;
        this.dialogs.showRegistrationConfirm().result.then(function () {
            _this.story.removeActivity(index);
            if (index === _this.step + 1)
                _this.step = _this.step - 1;
        });
    };
    /**
     * Goes to the previous step
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToPrev = function () {
        if (this.step === 1)
            return;
        this.step = this.step - 1;
    };
    /**
     * Goes to the specific step
     * @param step
     * @returns {}
     */
    CreateStoryViewModel.prototype.goToStep = function (step) {
        if (this.step < 2 || step < 1 || step > this.story.activities.length + 2)
            return;
        this.step = step;
    };
    return CreateStoryViewModel;
})();
//# sourceMappingURL=CreateStoryViewModel.js.map