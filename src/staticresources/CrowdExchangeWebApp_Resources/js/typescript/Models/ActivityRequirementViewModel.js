var __extends = (this && this.__extends) || function (d, b) {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
    __.prototype = b.prototype;
    d.prototype = new __();
};
/**
 * ViewModel for the Activity's requirement
 */
var ActivityRequirementViewModel = (function (_super) {
    __extends(ActivityRequirementViewModel, _super);
    function ActivityRequirementViewModel() {
        _super.apply(this, arguments);
    }
    /**
     * Adds new child requirements
     * @returns {}
     */
    ActivityRequirementViewModel.prototype.addRequirement = function () {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = this.requirementNumber.split(".")[0] + "." + (this.childRequirements.length + 1);
        this.childRequirements.push(newRequirement);
    };
    /**
     * removes child requirement
     * @param indx index of the child requirement to remove
     * @returns {}
     */
    ActivityRequirementViewModel.prototype.removeRequirement = function (indx) {
        this.childRequirements.splice(indx, 1);
        var parentNumber = this.requirementNumber.split(".")[0];
        this.childRequirements.map(function (child, childIndx) { return child.requirementNumber = parentNumber + "." + (childIndx + 1); });
    };
    return ActivityRequirementViewModel;
})(ActivityRequirement);
//# sourceMappingURL=ActivityRequirementViewModel.js.map