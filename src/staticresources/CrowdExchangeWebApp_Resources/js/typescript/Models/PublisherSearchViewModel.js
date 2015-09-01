var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
var PaginatedSearchViewModel = (function () {
    function PaginatedSearchViewModel(props) {
        this.isLoading = false;
        this.pageSize = 10;
        this.totalItems = 1;
        this.page = 1;
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    return PaginatedSearchViewModel;
})();
var SearchViewModel = (function () {
    function SearchViewModel(props) {
        this.isLoading = false;
        this.query = "";
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
    }
    SearchViewModel.prototype.search = function (query) {
    };
    return SearchViewModel;
})();
var AllResultsSearchViewModel = (function (_super) {
    __extends(AllResultsSearchViewModel, _super);
    function AllResultsSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    AllResultsSearchViewModel.prototype.search = function (query) {
    };
    return AllResultsSearchViewModel;
})(PaginatedSearchViewModel);
var MembersSearchViewModel = (function (_super) {
    __extends(MembersSearchViewModel, _super);
    function MembersSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    MembersSearchViewModel.prototype.search = function (query) {
    };
    return MembersSearchViewModel;
})(PaginatedSearchViewModel);
var StoriesSearchViewModel = (function (_super) {
    __extends(StoriesSearchViewModel, _super);
    function StoriesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    StoriesSearchViewModel.prototype.search = function (query) {
    };
    return StoriesSearchViewModel;
})(PaginatedSearchViewModel);
var ActivitiesSearchViewModel = (function (_super) {
    __extends(ActivitiesSearchViewModel, _super);
    function ActivitiesSearchViewModel(props) {
        _super.call(this, props);
        this.results = [];
    }
    ActivitiesSearchViewModel.prototype.search = function (query) {
    };
    return ActivitiesSearchViewModel;
})(PaginatedSearchViewModel);
//# sourceMappingURL=PublisherSearchViewModel.js.map