/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/moment/moment.d.ts"/>
/// <reference path="C:\Users\Denis\Documents\Visual Studio 2013\Projects\CrowdSourcing\CrowdSourcing\Scripts/typings/angularjs/angular.d.ts"/>
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/moment/moment.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/angularjs/angular.d.ts" />
/// <reference path="C:/Users/Denis/Documents/Visual Studio 2013/Projects/CrowdSourcing/CrowdSourcing/Scripts/typings/underscore/underscore.d.ts" />
declare var GLOBAL_CONFIG: any;
declare var MEMBER_SEARCH_TEMPLATE: any;
declare var copyFields: any;
copyFields = (d, b) => {
    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    function __() { this.constructor = d; }
};
/**
 * User view model
 */
class UserViewModel {
    role: string;
    firstName: string;
    lastName: string;
    organization: string;
    email: string;
    id: string;
    photoUrl: string;
    constructor(model?: UserViewModel) {
        if (model) {
            jQuery.extend(this, model);
        }

    }
    get fullName(): string {
        return ((this.firstName || "") + " " + (this.lastName || "")).trim();
    }
}