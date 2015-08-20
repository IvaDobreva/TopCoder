/**
 * ViewModel for the Activity's requirement
 */ 
class ActivityRequirementViewModel extends ActivityRequirement {
    /**
     * Adds new child requirements
     * @returns {} 
     */
    addRequirement() {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = this.requirementNumber.split(".")[0] + "." + (this.childRequirements.length + 1);
        this.childRequirements.push(newRequirement);
    }
    /**
     * removes child requirement
     * @param indx index of the child requirement to remove
     * @returns {} 
     */
    removeRequirement(indx: number) {
        this.childRequirements.splice(indx, 1);
        var parentNumber = this.requirementNumber.split(".")[0];
        this.childRequirements.map((child, childIndx) => child.requirementNumber = parentNumber + "." + (childIndx + 1));
    }
}