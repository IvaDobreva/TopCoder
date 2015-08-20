/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/moment/moment.d.ts"/>
/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/angularjs/angular.d.ts"/>
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/moment/moment.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/angularjs/angular.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/underscore/underscore.d.ts" />
copyFields = function (d, b) {
    for (var p in b)
        if (b.hasOwnProperty(p))
            d[p] = b[p];
    function __() { this.constructor = d; }
};
/**
 * User view model
 */
var UserViewModel = (function () {
    function UserViewModel(model) {
        if (model) {
            jQuery.extend(this, model);
        }
    }
    Object.defineProperty(UserViewModel.prototype, "fullName", {
        get: function () {
            return ((this.firstName || "") + " " + (this.lastName || "")).trim();
        },
        enumerable: true,
        configurable: true
    });
    return UserViewModel;
})();
//# sourceMappingURL=UserViewModel.js.map