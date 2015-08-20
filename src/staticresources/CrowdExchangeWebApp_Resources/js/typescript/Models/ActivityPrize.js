/**
* Class with info about Activity's award
*/
var ActivityPrize = (function () {
    function ActivityPrize(prize) {
        this.place = 1;
        this.amount = 0;
        if (prize) {
            this.id = prize.id;
            this.place = prize.place;
            this.amount = prize.amount;
        }
    }
    Object.defineProperty(ActivityPrize.prototype, "placeLabel", {
        /**
         * Makes places label
         * @returns {}
         */
        get: function () {
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
        },
        enumerable: true,
        configurable: true
    });
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction}
    */
    ActivityPrize.prototype.getModel = function () {
        return {
            id: this.id,
            place: this.place,
            amount: this.amount
        };
    };
    return ActivityPrize;
})();
//# sourceMappingURL=ActivityPrize.js.map