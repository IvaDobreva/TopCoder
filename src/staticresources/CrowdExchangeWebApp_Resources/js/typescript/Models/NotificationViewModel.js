var NotificationViewModel = (function () {
    function NotificationViewModel(model, props) {
        this.isRead = false;
        this.isOpen = false;
        this.recipients = [];
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
        }
        if (model) {
            this.id = model.id;
            this.dateSent = model.dateSent;
            this.text = model.text;
            this.subject = model.subject;
            this.type = model.type;
            this.status = model.status;
            this.isRead = model.isRead;
            this.sender = new UserViewModel(model.sender);
            if (model.recipients)
                this.recipients = model.recipients.map(function (x) { return new UserViewModel(x); });
        }
    }
    NotificationViewModel.prototype.openClose = function () {
        var _this = this;
        this.isOpen = !this.isOpen;
        if (!this.isRead && this.isOpen) {
            this.service.markNotificationAsRead(this.id).then(function (x) {
                _this.isRead = true;
            }, function (error) { });
        }
    };
    return NotificationViewModel;
})();
//# sourceMappingURL=NotificationViewModel.js.map