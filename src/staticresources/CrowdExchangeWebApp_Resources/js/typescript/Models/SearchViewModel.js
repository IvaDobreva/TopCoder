var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
 * Base class for the tabs viewmodels on search page
 */
var PaginatedSearchViewModel = (function () {
    function PaginatedSearchViewModel(props) {
        this.isLoading = false;
        this.pageSize = 10;
        this.totalItems = 0;
        this.page = 1;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    return PaginatedSearchViewModel;
})();
/**
 * Search page tabs
 */
var SearchTabs;
(function (SearchTabs) {
    SearchTabs[SearchTabs["All"] = 0] = "All";
    SearchTabs[SearchTabs["Stories"] = 1] = "Stories";
    SearchTabs[SearchTabs["Activities"] = 2] = "Activities";
    SearchTabs[SearchTabs["Members"] = 3] = "Members";
})(SearchTabs || (SearchTabs = {}));
/**
 *  Search page viewmodel
 */
var SearchViewModel = (function () {
    function SearchViewModel(props) {
        this.isLoading = false;
        this.oldQuery = "";
        this.newQuery = "";
        this.currentTab = SearchTabs.All;
        this.allResults = new AllResultsSearchViewModel();
        this.members = new MembersSearchViewModel();
        this.stories = new StoriesSearchViewModel();
        this.activities = new ActivitiesSearchViewModel();
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        this.allResults = new AllResultsSearchViewModel(props);
        this.members = new MembersSearchViewModel(props);
        this.stories = new StoriesSearchViewModel(props);
        this.activities = new ActivitiesSearchViewModel(props);
    }
    /**
     * sets current tab
     * @param tab new tab
     * @returns {void}
     */
    SearchViewModel.prototype.setCurrentTab = function (tab) {
        this.currentTab = tab;
    };
    /**
     * fires search for all tabs
     * @returns {void}
     */
    SearchViewModel.prototype.search = function () {
        var _this = this;
        if (!this.newQuery)
            this.newQuery = this.oldQuery;
        else
            this.oldQuery = this.newQuery;
        this.isLoading = true;
        this.allResults.search(this.newQuery, function () { return _this.isLoading = false; });
        this.members.search(this.newQuery);
        this.stories.search(this.newQuery);
        this.activities.search(this.newQuery);
    };
    /**
     * method for the publisher's "invite member" functionality
     * @param member member to invite
     * @returns {}
     */
    SearchViewModel.prototype.inviteMember = function (member) {
        var subject = MEMBER_SEARCH_TEMPLATE.subject;
        var firstName = member ? member.firstName : "<enter member's name>";
        this.dialogs.showPublisherSelectActivity().result.then(function (result) {
            var activityName = result ? result.title : "<enter Activity's Name>";
            var body = MEMBER_SEARCH_TEMPLATE.body.replace("{{userFirstName}}", firstName).replace("{{activityName}}", activityName);
            window.location = ("mailto:" + member.email + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body));
        });
    };
    return SearchViewModel;
})();
/**
 * All results tab viewmodel
 */
var AllResultsSearchViewModel = (function (_super) {
    __extends(AllResultsSearchViewModel, _super);
    function AllResultsSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    /**
     * searches all results for the provided query
     * @param query search term
     * @param callback callback function
     * @returns {void}
     */
    AllResultsSearchViewModel.prototype.search = function (query, callback) {
        if (query)
            this.query = query;
        this.fetchRecords(callback);
    };
    /**
     * fetches records from server
     * @param callback callback function
     * @returns {void}
     */
    AllResultsSearchViewModel.prototype.fetchRecords = function (callback) {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.search({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.records.map(function (result) {
                if (result.type === "user")
                    return new UserViewModel(result.item);
                else if (result.type === "activity")
                    return new ActivityViewModel(result.item);
                else if (result.type === "story")
                    return new StoryViewModel(result.item);
                return result.item;
            });
            _this.isLoading = false;
            if (callback)
                callback();
        }, function (error) { _this.isLoading = false; if (callback)
            callback(); });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    AllResultsSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchRecords();
    };
    return AllResultsSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Members tab viewmodel
 */
var MembersSearchViewModel = (function (_super) {
    __extends(MembersSearchViewModel, _super);
    function MembersSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new MembersSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    MembersSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * filters the results
     * @returns {}
     */
    MembersSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    MembersSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchMembers();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    MembersSearchViewModel.prototype.fetchMembers = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchMembers({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.members.map(function (x) { return new UserViewModel(x); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    MembersSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchMembers();
    };
    return MembersSearchViewModel;
})(PaginatedSearchViewModel);
var StoriesSearchViewModel = (function (_super) {
    __extends(StoriesSearchViewModel, _super);
    function StoriesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new StoriesSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    StoriesSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    StoriesSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchStories();
    };
    /**
     * filters the results
     * @returns {}
     */
    StoriesSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    StoriesSearchViewModel.prototype.fetchStories = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchStories({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.stories.map(function (x) { return new StoryViewModel(x); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    StoriesSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchStories();
    };
    return StoriesSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Viewmodel for the activities tab on search page
 */
var ActivitiesSearchViewModel = (function (_super) {
    __extends(ActivitiesSearchViewModel, _super);
    function ActivitiesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
        this.filter = new ActivitiesSeachFilter();
    }
    /**
     * clears search filter
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.clearFilter = function () {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    };
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void}
     */
    ActivitiesSearchViewModel.prototype.search = function (query) {
        if (query)
            this.query = query;
        this.fetchActivities();
    };
    /**
     * filters the results
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.filterResults = function () {
        this.page = 1;
        this.search();
    };
    /**
     * fetches records from server
     * @returns {void}
     */
    ActivitiesSearchViewModel.prototype.fetchActivities = function () {
        var _this = this;
        if (!this.query)
            return;
        this.isLoading = true;
        this.service.searchActivities({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(function (result) {
            _this.totalItems = result.totalItems;
            _this.results = result.activities.map(function (x) { return new ActivityViewModel(x, { dialogs: _this.dialogs, service: _this.service }); });
            _this.isLoading = false;
        }, function (error) { _this.isLoading = false; });
    };
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {}
     */
    ActivitiesSearchViewModel.prototype.pageChanged = function (newPage) {
        this.fetchActivities();
    };
    return ActivitiesSearchViewModel;
})(PaginatedSearchViewModel);
/**
 * Stories tab filter viewModel
 */
var StoriesSeachFilter = (function () {
    function StoriesSeachFilter() {
        this.serviceOffering = "all";
        this.status = "all";
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    StoriesSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    StoriesSeachFilter.prototype.clear = function () {
        this.title = "";
        this.description = "";
        this.serviceOffering = "all";
        this.status = "all";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    StoriesSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.serviceOffering === "all")
            delete model.serviceOffering;
        if (model.status === "all")
            delete model.status;
        return model;
    };
    return StoriesSeachFilter;
})();
/**
 * Activities tab filter viewModel
 */
var ActivitiesSeachFilter = (function () {
    function ActivitiesSeachFilter() {
        this.challengeType = "all";
        this.phase = "all";
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    ActivitiesSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    ActivitiesSeachFilter.prototype.clear = function () {
        this.title = "";
        this.description = "";
        this.challengeType = "all";
        this.phase = "all";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    ActivitiesSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.challengeType === "all")
            delete model.challengeType;
        if (model.phase === "all")
            delete model.phase;
        return model;
    };
    return ActivitiesSeachFilter;
})();
/**
 * Members tab filter viewModel
 */
var MembersSeachFilter = (function () {
    function MembersSeachFilter() {
        this.isActive = false;
    }
    /**
     * Alter the visibility of the filter
     * @returns {}
     */
    MembersSeachFilter.prototype.showHide = function () {
        this.isActive = !this.isActive;
    };
    /**
     * Clears filter fields
     * @returns {}
     */
    MembersSeachFilter.prototype.clear = function () {
        this.firstName = "";
        this.lastName = "";
        this.organization = "";
        this.role = "";
    };
    /**
    * returns model of the current filter for sending to the server
    * @returns {}
    */
    MembersSeachFilter.prototype.getModel = function () {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        return model;
    };
    return MembersSeachFilter;
})();
//# sourceMappingURL=SearchViewModel.js.map