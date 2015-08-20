/**
* Class with info about Activity's requirement
*/
var ActivityRequirement = (function () {
    function ActivityRequirement(requirement) {
        this.childRequirements = [];
        this.requirementType = "";
        this.importance = "";
        this.description = "";
        if (requirement) {
            this.description = jQuery("<div/>").html(requirement.description).text();
            this.id = requirement.id;
            this.requirementType = requirement['type'];
            this.importance = requirement.importance;
            this.requirementNumber = requirement.requirementNumber;
            this.childRequirements = requirement.childRequirements.map(function (value) { return new ActivityRequirement(value); });
        }
    }
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction}
    */
    ActivityRequirement.prototype.getModel = function () {
        return {
            id: this.id,
            requirementNumber: this.requirementNumber,
            'type': this.requirementType,
            importance: this.importance,
            childRequirements: this.childRequirements.map(function (value) { return value.getModel(); }),
            description: this.description
        };
    };
    return ActivityRequirement;
})();
//# sourceMappingURL=ActivityRequirement.js.map