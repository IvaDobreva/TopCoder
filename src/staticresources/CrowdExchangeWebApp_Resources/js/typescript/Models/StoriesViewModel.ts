 /**
 * Stories page ViewModel
 */ 
class StoriesViewModel {
    activeStories: StoriesListViewModel;
    completedStories: StoriesListViewModel;
    filter: StoriesFilterViewModel = new StoriesFilterViewModel();

    constructor(dataServices: any) {
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
    resetFilter() {
        this.filter.clear();
        this.filter.isActive = false;
        this.activeStories.fetchStories();
        this.completedStories.fetchStories();
    }
    /**
     * fetch filtered stories
     * @returns {} 
     */
    filterStories() {
        this.activeStories.fetchStories(true);
        this.completedStories.fetchStories(true);
    }
    /**
     * show particular tab
     * @param indx tab index. 1 - active stories, 2 - completed stories
     * @returns {} 
     */
    showTab(indx: number) {
        this.activeStories.isActive = indx === 1;
        this.completedStories.isActive = indx === 2;
    }
}