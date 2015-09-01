 /**
 * Class with info about Activity's milestone
 */ 
class ActivityMilestone {
    scheduledDate: any;
    completedDate: any;
    name: string;
    constructor(model?: any) {
        if (model) {
            this.scheduledDate = model.scheduledDate ? moment.utc(model.scheduledDate).toDate() : null;
            this.completedDate = model.completedDate ? moment.utc(model.completedDate).toDate() : null;
            this.name = model.name;
        }
    }
    /**
     * Calculates offset from other milestone in days 
     * @param milestone 
     * @returns {offset in days} 
     */
    getOffset(milestone: any) {
        if (!milestone) return 0;
        return (moment.duration(moment(this.scheduledDate).diff(moment(milestone.scheduledDate))).asDays());
    }
    /**
     * Getting DTO model
     * @returns {DTO model for RemoteAction} 
     */
    getModel() {
        var scheduled = moment(this.scheduledDate);
        var completed = moment(this.completedDate);
        return {
            name: this.name,
            scheduledDate: this.scheduledDate ? scheduled.subtract(scheduled.zone(), 'minutes').toDate().toUTCString() : undefined,
            completedDate: this.completedDate ? completed.subtract(completed.zone(), 'minutes').toDate().toUTCString() : undefined
        }
    }
}