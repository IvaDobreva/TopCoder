
/**
 * Base class for the tabs viewmodels on search page
 */
class PaginatedSearchViewModel {
    query: string;
    isLoading: boolean = false;
    dialogs: any;
    protected  service: any;
    pageSize: number = 10;
    totalItems: number = 0;
    page: number = 1;
    constructor(props?: any) {
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
}
/**
 * Search page tabs
 */
enum SearchTabs {
    All,
    Stories,
    Activities,
    Members
}
/**
 *  Search page viewmodel
 */
class SearchViewModel {
    isLoading: boolean = false;
    dialogs: any;
    service: any;
    oldQuery: string = "";
    newQuery: string = "";
    currentTab: SearchTabs = SearchTabs.All;
    allResults: AllResultsSearchViewModel = new AllResultsSearchViewModel();
    members: MembersSearchViewModel = new MembersSearchViewModel();
    stories: StoriesSearchViewModel = new StoriesSearchViewModel();
    activities: ActivitiesSearchViewModel = new ActivitiesSearchViewModel();

    constructor(props?:any) {
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
    setCurrentTab(tab: SearchTabs) {
        this.currentTab = tab;
    }
    /**
     * fires search for all tabs
     * @returns {void} 
     */
    search() {
        if (!this.newQuery) this.newQuery = this.oldQuery;
        else this.oldQuery = this.newQuery;
        this.isLoading = true;
        this.allResults.search(this.newQuery, () => this.isLoading = false);
        this.members.search(this.newQuery);
        this.stories.search(this.newQuery);
        this.activities.search(this.newQuery);
    }
    /**
     * method for the publisher's "invite member" functionality
     * @param member member to invite
     * @returns {} 
     */
    inviteMember(member?: UserViewModel) {
        var subject = MEMBER_SEARCH_TEMPLATE.subject;
        var firstName = member ? member.firstName : "<enter member's name>";
        this.dialogs.showPublisherSelectActivity().result.then(result => {
            var activityName = result ? result.title : "<enter Activity's Name>";
            var body = MEMBER_SEARCH_TEMPLATE.body.replace("{{userFirstName}}", firstName).replace("{{activityName}}", activityName);
            window.location = <any>("mailto:" + member.email + "?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body));
        });
        
    }
}
/**
 * All results tab viewmodel
 */
class AllResultsSearchViewModel extends PaginatedSearchViewModel {
    results: any[] = [];

    constructor(props?: any) {
        super(props);
    }
    /**
     * searches all results for the provided query
     * @param query search term
     * @param callback callback function
     * @returns {void} 
     */
    search(query?: string, callback?: any) {
        if (query) this.query = query;
        this.fetchRecords(callback);
    }
    /**
     * fetches records from server
     * @param callback callback function
     * @returns {void} 
     */
    fetchRecords(callback?: any) {
        if (!this.query) return;
        this.isLoading = true;
        this.service.search({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize
        }).then(result => {
            this.totalItems = result.totalItems;
            this.results = result.records.map(result => {
                if (result.type === "user")
                    return new UserViewModel(result.item);
                else if (result.type === "activity")
                    return new ActivityViewModel(result.item); 
                else if (result.type === "story")
                    return new StoryViewModel(result.item);
                return result.item;
            });
            this.isLoading = false;
            if (callback) callback();
        }, error => { this.isLoading = false; if (callback) callback();});
    }
   /**
    * Page changed callback
    * @param newPage new page number
    * @returns {} 
    */
    pageChanged(newPage: number) {
        this.fetchRecords();
    }
}
/**
 * Members tab viewmodel
 */
class MembersSearchViewModel extends PaginatedSearchViewModel {
    results: UserViewModel[] = [];
    filter: MembersSeachFilter = new MembersSeachFilter();
    
    constructor(props?: any) {
        super(props);
    }
    /**
     * clears search filter
     * @returns {} 
     */
    clearFilter() {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    }
    /**
     * filters the results
     * @returns {} 
     */
    filterResults() {
        this.page = 1;
        this.search();
    }
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void} 
     */
    search(query?: string) {
        if (query) this.query = query;
        this.fetchMembers();
    }
    /**
     * fetches records from server
     * @returns {void} 
     */
    fetchMembers() {
        if (!this.query) return;
        this.isLoading = true;
        this.service.searchMembers({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(result => {
            this.totalItems = result.totalItems;
            this.results = result.members.map(x => new UserViewModel(x));
            this.isLoading = false;
        }, error => { this.isLoading = false; });
    }
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {} 
     */
    pageChanged(newPage: number) {
        this.fetchMembers();
    }
}
class StoriesSearchViewModel extends PaginatedSearchViewModel {
    results: UserViewModel[] = [];
    filter: StoriesSeachFilter = new StoriesSeachFilter();

    constructor(props?: any) {
        super(props);
    }
    /**
     * clears search filter
     * @returns {} 
     */
    clearFilter() {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    }
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void} 
     */
    search(query?: string) {
        if (query) this.query = query;
        this.fetchStories();
    }
    /**
     * filters the results
     * @returns {} 
     */
    filterResults() {
        this.page = 1;
        this.search();
    }
    /**
     * fetches records from server
     * @returns {void} 
     */
    fetchStories() {
        if (!this.query) return;
        this.isLoading = true;
        this.service.searchStories({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(result => {
            this.totalItems = result.totalItems;
            this.results = result.stories.map(x => new StoryViewModel(x));
            this.isLoading = false;
        }, error => { this.isLoading = false; });
    }
   /**
    * Page changed callback
    * @param newPage new page number
    * @returns {} 
    */
    pageChanged(newPage: number) {
        this.fetchStories();
    }
}
/**
 * Viewmodel for the activities tab on search page
 */
class ActivitiesSearchViewModel extends PaginatedSearchViewModel {
    results: UserViewModel[] = [];
    filter: ActivitiesSeachFilter = new ActivitiesSeachFilter();

    constructor(props?: any) {
        super(props);
    }
    /**
     * clears search filter
     * @returns {} 
     */
    clearFilter() {
        this.filter.isActive = false;
        this.filter.clear();
        this.filterResults();
    }
    /**
     * searches members for the provided query
     * @param query search term
     * @returns {void} 
     */
    search(query?: string) {
        if (query) this.query = query;
        this.fetchActivities();
    }
    /**
     * filters the results
     * @returns {} 
     */
    filterResults() {
        this.page = 1;
        this.search();
    }
    /**
     * fetches records from server
     * @returns {void} 
     */
    fetchActivities() {
        if (!this.query) return;
        this.isLoading = true;
        this.service.searchActivities({
            query: this.query,
            page: this.page,
            pageSize: this.pageSize,
            filter: this.filter.getModel()
        }).then(result => {
            this.totalItems = result.totalItems;
            this.results = result.activities.map(x => new ActivityViewModel(x,{dialogs: this.dialogs, service: this.service}));
            this.isLoading = false;
        }, error => { this.isLoading = false; });
    }
    /**
     * Page changed callback
     * @param newPage new page number
     * @returns {} 
     */
    pageChanged(newPage: number) {
        this.fetchActivities();
    }
}
/**
 * Stories tab filter viewModel
 */
class StoriesSeachFilter {
    title: string;
    description: string;
    serviceOffering: string = "all";
    status: string = "all"; 
    isActive: boolean = false;
    /**
     * Alter the visibility of the filter
     * @returns {} 
     */
    showHide() {
        this.isActive = !this.isActive;
    }
    /**
     * Clears filter fields
     * @returns {} 
     */
    clear() {
        this.title = "";
        this.description = "";
        this.serviceOffering = "all";
        this.status = "all";
    }
    /**
    * returns model of the current filter for sending to the server
    * @returns {} 
    */
    getModel() {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.serviceOffering === "all") delete model.serviceOffering;
        if (model.status === "all") delete model.status;
        return model;
    }
}
/**
 * Activities tab filter viewModel
 */
class ActivitiesSeachFilter {
    title: string;
    description: string;
    challengeType: string = "all";
    phase: string = "all";
    isActive: boolean = false;
    /**
     * Alter the visibility of the filter
     * @returns {} 
     */
    showHide() {
        this.isActive = !this.isActive;
    }
    /**
     * Clears filter fields
     * @returns {} 
     */
    clear() {
        this.title = "";
        this.description = "";
        this.challengeType = "all";
        this.phase = "all";
    }
    /**
    * returns model of the current filter for sending to the server
    * @returns {} 
    */
    getModel() {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        if (model.challengeType === "all") delete model.challengeType;
        if (model.phase === "all") delete model.phase;
        return model;
    }
}
/**
 * Members tab filter viewModel
 */
class MembersSeachFilter {
    firstName: string;
    lastName: string;
    organization: string;
    role: string;
    isActive: boolean = false;
    /**
     * Alter the visibility of the filter
     * @returns {} 
     */
    showHide() {
        this.isActive = !this.isActive;
    }
    /**
     * Clears filter fields
     * @returns {} 
     */
    clear() {
        this.firstName = "";
        this.lastName = "";
        this.organization = "";
        this.role = "";
    }
    /**
    * returns model of the current filter for sending to the server
    * @returns {} 
    */
    getModel() {
        var model = jQuery.extend(false, {}, this);
        delete model.isActive;
        return model;
    }
}