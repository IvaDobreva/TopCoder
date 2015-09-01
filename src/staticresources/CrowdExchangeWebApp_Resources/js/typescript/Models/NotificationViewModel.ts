class NotificationViewModel {
    id: string;
    dateSent: Date;
    text: string;
    subject: string;
    type: string;
    status: string;
    isRead: boolean = false;
    isOpen: boolean = false;
    sender: UserViewModel;
    recipients: UserViewModel[] = [];
    service: any;
    dialogs: any;

    constructor(model?: NotificationViewModel, props?:any) {
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
            if (model.recipients) this.recipients = model.recipients.map(x => new UserViewModel(x));
        }
    }
    openClose() {
        this.isOpen = !this.isOpen;
        if (!this.isRead && this.isOpen) {
            this.service.markNotificationAsRead(this.id).then(x => {
                this.isRead = true;
            }, error=>{});
        }
    }
}