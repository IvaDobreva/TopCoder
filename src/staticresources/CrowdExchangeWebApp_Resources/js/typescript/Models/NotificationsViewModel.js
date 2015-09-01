var NotificationsViewModel = (function () {
    function NotificationsViewModel(props) {
        this.pageSize = 10;
        this.totalItems = 1;
        this.page = 1;
        this.isLoading = false;
        this._folderType = "inbox";
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.initialize();
        }
    }
    Object.defineProperty(NotificationsViewModel.prototype, "folderType", {
        get: function () { return this._folderType; },
        set: function (value) { this._folderType = value; this.folderChanged(); },
        enumerable: true,
        configurable: true
    });
    NotificationsViewModel.prototype.folderChanged = function () {
        this.page = 1;
        this.totalItems = 0;
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.initialize = function () {
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.pageChanged = function (newPage) {
        this.page = newPage;
        this.fetchNotifications();
    };
    NotificationsViewModel.prototype.fetchNotifications = function () {
        var _this = this;
        var promise = null;
        if (this._folderType === 'inbox') {
            promise = this.service.getInboxNotifications(this.page, this.pageSize);
        }
        else {
            promise = this.service.getOutboxNotifications(this.page, this.pageSize);
        }
        this.isLoading = true;
        promise.then(function (data) {
            _this.notifications = data.notifications.map(function (x) { return new NotificationViewModel(x, { service: _this.service, dialogs: _this.dialogs }); });
            _this.totalItems = data.totalItems;
            _this.isLoading = false;
        }, function (error) {
            _this.isLoading = false;
        });
    };
    NotificationsViewModel.prototype.archiveNotification = function (indx) {
        var _this = this;
        if (indx < 0 || indx >= this.notifications.length)
            return;
        this.dialogs.showArchiveNotificationConfirm().result.then(function (result) {
            if (result) {
                _this.isLoading = true;
                _this.service.archiveNotification(_this.notifications[indx].id).then(function (x) {
                    _this.fetchNotifications();
                }, function (error) { _this.isLoading = false; });
            }
        });
    };
    return NotificationsViewModel;
})();
//# sourceMappingURL=NotificationsViewModel.js.map