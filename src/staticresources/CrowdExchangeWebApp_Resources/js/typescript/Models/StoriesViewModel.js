/**
* Stories page ViewModel
*/
var StoriesViewModel = (function () {
    function StoriesViewModel(dataServices) {
        this.filter = new StoriesFilterViewModel();
        this.activeStories = new StoriesListViewModel(this.filter);
        this.activeStories.service = dataServices;
        this.activeStories.fetchStories();
        this.activeStories.isActive = true;
        this.completedStories = new StoriesListViewModel(this.filter, true);
        this.completedStories.service = dataServices;
        this.filter.showOnlyCompleted = true;
        this.completedStories.fetchStories();
        this.showTab(1);
    }
    /**
     * resets filter
     * @returns {}
     */
    StoriesViewModel.prototype.resetFilter = function () {
        this.filter.clear();
        this.filter.isActive = false;
        this.activeStories.fetchStories();
        this.completedStories.fetchStories();
    };
    /**
     * fetch filtered stories
     * @returns {}
     */
    StoriesViewModel.prototype.filterStories = function () {
        this.activeStories.fetchStories(true);
        this.completedStories.fetchStories(true);
    };
    /**
     * show particular tab
     * @param indx tab index. 1 - active stories, 2 - completed stories
     * @returns {}
     */
    StoriesViewModel.prototype.showTab = function (indx) {
        this.activeStories.isActive = indx === 1;
        this.completedStories.isActive = indx === 2;
    };
    return StoriesViewModel;
})();
//# sourceMappingURL=StoriesViewModel.js.map