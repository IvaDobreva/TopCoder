/**
* Stories collection viewModel
*/
var StoriesListViewModel = (function () {
    function StoriesListViewModel(filter, fetchOnlyCompleted) {
        if (filter === void 0) { filter = new StoriesFilterViewModel(); }
        if (fetchOnlyCompleted === void 0) { fetchOnlyCompleted = false; }
        this.stories = [];
        this.pageSize = 5;
        this.page = 1;
        this.totalPages = 1;
        this.totalItems = 0;
        this.isActive = true;
        this.fetchOnlyCompleted = false;
        this.isLoading = false;
        this.filter = filter;
        this.fetchOnlyCompleted = fetchOnlyCompleted;
    }
    /**
     * fetches stories with filter and pagination
     * @param fromStart
     * @returns {}
     */
    StoriesListViewModel.prototype.fetchStories = function (fromStart) {
        var _this = this;
        if (fromStart === void 0) { fromStart = false; }
        if (!this.filter)
            this.filter = new StoriesFilterViewModel();
        this.filter.showOnlyCompleted = this.fetchOnlyCompleted;
        if (this.isLoading)
            return;
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
            }).then(function (data) {
                _this.totalItems = data.totalItems;
                _this.totalPages = data.totalPages;
                _this.stories = data.stories.map(function (value, index, arr) { return new StoryViewModel(value); });
                _this.isLoading = false;
            }, function (data) { _this.isLoading = false; });
            ;
        }
        else {
            this.isLoading = false;
        }
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    StoriesListViewModel.prototype.pageChanged = function (newPage) {
        this.fetchStories();
    };
    /**
     * Goes to the next page
     * @returns {}
     */
    StoriesListViewModel.prototype.goToPage = function () {
        if (this.page === 1 || this.page === this.totalPages)
            return;
        this.fetchStories();
        this.fetchStories();
    };
    return StoriesListViewModel;
})();
//# sourceMappingURL=StoriesListViewModel.js.map