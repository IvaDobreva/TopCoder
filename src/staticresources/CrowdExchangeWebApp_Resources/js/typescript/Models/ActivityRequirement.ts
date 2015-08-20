 /**
 * Class with info about Activity's requirement
 */ 
class ActivityRequirement {
    id: string;
    childRequirements: Array<ActivityRequirement> = [];
    requirementNumber: string;
    requirementType: string = "";
    importance: string = "";
    description: string = "";
    constructor(requirement?: ActivityRequirement) {
        if (requirement) {
            this.description = jQuery("<div/>").html(requirement.description).text();
            this.id = requirement.id;
            this.requirementType = requirement['type'];
            this.importance = requirement.importance;
            this.requirementNumber = requirement.requirementNumber;
            this.childRequirements = requirement.childRequirements.map(value=> new ActivityRequirement(value));
        }
    }
    /**
    * Getting DTO model
    * @returns {DTO model for RemoteAction} 
    */
    getModel() {
        return {
            id: this.id,
            requirementNumber: this.requirementNumber,
            'type': this.requirementType,
            importance: this.importance,
            childRequirements: this.childRequirements.map(value=> value.getModel()),
            description: this.description
        }
    }
}