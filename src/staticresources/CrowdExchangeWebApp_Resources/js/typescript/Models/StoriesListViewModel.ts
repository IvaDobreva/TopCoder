 /**
 * Stories collection viewModel
 */ 
class StoriesListViewModel {
    stories: StoryViewModel[] = [];
    pageSize: number = 5;
    page: number = 1;
    totalPages: number = 1;
    totalItems: number = 0;
    isActive: Boolean = true;
    filter: StoriesFilterViewModel;
    fetchOnlyCompleted: boolean = false;
    isLoading: boolean = false;
    service: any;
    constructor(filter: StoriesFilterViewModel = new StoriesFilterViewModel(),fetchOnlyCompleted: boolean = false) {
        this.filter = filter;
        this.fetchOnlyCompleted = fetchOnlyCompleted;
    }
    /**
     * fetches stories with filter and pagination
     * @param fromStart 
     * @returns {} 
     */
    fetchStories(fromStart: boolean = false) {
        
        if (!this.filter)
            this.filter = new StoriesFilterViewModel();
        this.filter.showOnlyCompleted = this.fetchOnlyCompleted;
        if (this.isLoading) return;
        this.isLoading = true;
        if (fromStart) {
            this.page = 1;
            this.totalItems = 0;
            this.totalPages = 1;
            this.stories = [];
        }
        if (this.service != null && this.service.getStories != null) {
            this.service.getStories({
                page: this.page,
                pageSize: this.pageSize,
                filter: this.filter.getModel()
            }).then(data => {
                this.totalItems = data.totalItems;
                this.totalPages = data.totalPages;
                this.stories = data.stories.map((value, index, arr) => new StoryViewModel(value));
                this.isLoading = false;
            }, data => { this.isLoading = false; });;
        } else { this.isLoading = false;}
    }
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {} 
     */
    pageChanged(newPage: number) {
        this.fetchStories();
    }
    /**
     * Goes to the next page
     * @returns {} 
     */
    goToPage() {
        if (this.page === 1 || this.page === this.totalPages) return;
        this.fetchStories();
        this.fetchStories();
    }
}