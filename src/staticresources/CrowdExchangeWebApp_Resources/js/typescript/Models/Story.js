/**
* Story base class with basic properties
*/
var Story = (function () {
    function Story(story) {
        this.title = "";
        this.description = "";
        this.serviceOffering = null;
        this.phase = "";
        this.activities = [];
        if (story) {
            this.activities = story.activities;
            this.title = story.title;
            this.description = jQuery("<div/>").html(story.description).text();
            this.serviceOffering = story.serviceOffering;
            this.id = story.id;
            this.phase = story.phase;
            this.publisher = new UserViewModel(story.publisher);
        }
    }
    /**
     *  Getting DTO model
     * @returns {DTO model for RemoteAction}
     */
    Story.prototype.getModel = function () {
        return {
            id: this.id,
            title: this.title,
            description: this.description,
            serviceOffering: this.serviceOffering,
            status: this.phase,
            activities: this.activities.map(function (value) { return value.getModel(); })
        };
    };
    return Story;
})();
//# sourceMappingURL=Story.js.map