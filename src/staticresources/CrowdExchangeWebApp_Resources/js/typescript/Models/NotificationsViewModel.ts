class NotificationsViewModel {
    notifications: NotificationViewModel[];
    pageSize: number = 10;
    totalItems: number = 1;
    page: number = 1;
    service: any;
    dialogs: any;
    isLoading: boolean = false;
    private _folderType: string = "inbox";
    constructor(props?: any) {
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.initialize();
        }
    }
    get folderType() { return this._folderType; }
    set folderType(value) { this._folderType = value; this.folderChanged(); }

    folderChanged() {
        this.page = 1;
        this.totalItems = 0;
        this.fetchNotifications();
    }
    initialize() {
        this.fetchNotifications();
    }
    pageChanged(newPage: number) {
        this.page = newPage;
        this.fetchNotifications();
    }
    fetchNotifications() {
        var promise = null;
        if (this._folderType === 'inbox') {
            promise = this.service.getInboxNotifications(this.page, this.pageSize);
        } else {
            promise = this.service.getOutboxNotifications(this.page, this.pageSize);
        }
        this.isLoading = true;
        promise.then((data) => {
            this.notifications = data.notifications.map(x => new NotificationViewModel(x, { service: this.service, dialogs: this.dialogs }));
            this.totalItems = data.totalItems;
            this.isLoading = false;
        }, error => {
            this.isLoading = false;
        }); 
    }
    archiveNotification(indx: number) {
        if (indx < 0 || indx >= this.notifications.length) return;
        this.dialogs.showArchiveNotificationConfirm().result.then(result => {
            if (result) {
                this.isLoading = true;
                this.service.archiveNotification(this.notifications[indx].id).then(x => {
                    this.fetchNotifications();
                }, error => { this.isLoading = false; });
            }
        });
        
    }
}