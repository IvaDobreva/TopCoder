 /**
 * Class with info about Activity's award
 */ 
class ActivityPrize {
    id: string;
    place: number = 1;
    amount: number = 0;
    constructor(prize?: ActivityPrize) {
        if (prize) {
            this.id = prize.id;
            this.place = prize.place;
            this.amount = prize.amount;
        }
    }
    /**
     * Makes places label
     * @returns {} 
     */
    get placeLabel() {
        var appendix = '';
        switch (this.place) {
        case 1:
            appendix = "st";
            break;
        case 2:
            appendix = "nd";
            break;
        case 3:
            appendix = "rd";
            break;
        default:
            appendix = "th";
        }
        return this.place + appendix;
    }
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction} 
    */
    getModel() {
        return {
            id: this.id,
            place: this.place,
            amount: this.amount
        }
    }
}