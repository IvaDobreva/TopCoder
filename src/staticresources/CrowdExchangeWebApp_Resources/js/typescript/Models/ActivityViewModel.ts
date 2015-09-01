 /**
  * Main Activity viewModel
  */ 
class ActivityViewModel extends Activity {
    chatterUrl: any;
    registrants: ActivityRegistrantsViewModel;
    recomendations: ActivityRecomendedMembersViewModel;
    isActive: boolean = false;
    activeTab: number = 0;
    startOffset: number = 0;
    fileToUpload: any = { file: null, description: "", fileName: "" };
    defaultSkills: any[] = [];
    service: any;
    dialogs: any;
    navigation: any;
    /**
     * returnes duration for the particular milestone
     * @param indx index of milestone
     * @returns {} 
     */
    milestoneDuration(indx: number) {
        if (indx === this.milestones.length - 1) return 0;
        var ms = 0;
        ms = moment(this.milestones[indx + 1].scheduledDate).diff(moment(this.milestones[indx].scheduledDate));
        return moment.duration(ms).asDays();
    }
    constructor(activity?: Activity,props?: any) {
        super(activity);
        if (activity && activity.requirements) {
            delete this.requirements;
            this.requirements = activity.requirements.map(value=> new ActivityRequirementViewModel(value));
        }
        if (props) {
            this.service = props.service;
            this.dialogs = props.dialogs;
            this.navigation = props.navigation;
            this.registrants = new ActivityRegistrantsViewModel(this.id, props);
            this.recomendations = new ActivityRecomendedMembersViewModel(this.id, props);
            this.registrants.totalRegistrants = this.registrationsCount;
            if (this.service&&activity) {
                this.chatterUrl = this.service.trustAsResourceUrl(GLOBAL_CONFIG.activityChatterUrl + "?id=" + this.id);
            }
        }
    }
    /**
     *  Milestonechanged Callback
     * @param indx index of the milestone that was changed
     * @param newValue new value
     * @param oldValue previous value
     * @returns {void} 
     */
    milestoneChanged(indx:number, newValue:any, oldValue:any) {
        var difference = moment.duration(moment(newValue).diff(moment(oldValue))).asDays();
        if (difference > 0) {
            for (let i = indx + 1; i < this.milestones.length; i++) {
                let newDate = moment(this.milestones[i].scheduledDate).add(difference, 'days');
                this.milestones[i].scheduledDate = newDate.toDate();
            }
        }
        
    }
    /**
     * removes the requirement from the activity
     * @param indx index of reuirement
     * @returns {} 
     */
    removeRequirement(indx: number) {
        this.requirements.splice(indx, 1);
        this.requirements.map((parent, parentIndx) => {
            parent.requirementNumber = (parentIndx + 1) + ".0";
            parent.childRequirements.map((child, childIndx) => child.requirementNumber = (parentIndx + 1) + "." + (childIndx + 1));
        });
    }
    /**
     * selects tab
     * 0 - activity details, 1 -registrants, 2 - recomended members, 
     * 3 - chatter, 4 - submissions, 5 - review
     * @param indx tab index to go to
     * @returns {} 
     */
    selectTab(indx:number) {
        this.activeTab = indx;
        switch (indx) {
        case 1:
            this.registrants.initialize();
            this.fetchAssignedMember();
            break;
        case 2:
            this.recomendations.initialize();
            break;
        case 3:
            break;
        case 4:
            break;
        case 5:
            break;
        default:
        }
    }
    /**
     * registers current user to the activity
     * @returns {} 
     */
    registerToActivity() {
        this.dialogs.showRegistrationConfirm().result.then(result => {
            if (result) {
                this.service.registerToActivity(this.id).then(data => {
                    this.isRegistered = true;
                }, data=> { });
            }
        });
    } 
    /**
     * sets default skills collection
     * @param types array of default skills
     * @returns {} 
     */
    setDefaultCodeTypes(types: any[]) {
        var codeTypes = this.codeTypes;
        this.codeTypes = [];
        var selected = [];
        var defaultSkills = [];
        _.map(types, item => {
            var obj = _.extend(new CodeType(item.name, item.skillId, item.id), _.findWhere(codeTypes, { id: item.skillId }));
            delete obj.$$hashKey;
            defaultSkills.push(obj);
            if (obj.skillId) selected.push(obj);
            return obj;
        });
        
        this.defaultSkills = defaultSkills;
        setTimeout(() => {
            this.codeTypes = selected;
        }, 500);
    }
    /**
     * adds a requirement to the current activity
     * @returns {} 
     */
    addRequirement() {
        var newRequirement = new ActivityRequirementViewModel();
        newRequirement.requirementNumber = (this.requirements.length+1)+".0";
        this.requirements.push(newRequirement);
    }
    /**
     * adds a award to the current activity
     * @returns {} 
     */
    addPrize() {
        if (this.noPrizes) return;
        var newPrize = new ActivityPrize();
        newPrize.place = this.prizes.length + 1;
        this.prizes.push(newPrize);
    }
    /**
     * removes the award from the current activity
     * @param indx index of the award to remove
     * @returns {} 
     */
    removePrize(indx: number) {
        if (this.noPrizes) return;
        this.prizes.splice(indx, 1);
        for (var i = this.prizes.length; i > 0; i--) {
            this.prizes[i - 1].place = i;
        }
    }
    /**
     * calculates activity's duration
     * @returns {} 
     */
    get activityDuration() {
        return this.milestones[this.milestones.length - 1].getOffset(this.milestones[0]);
    }
    /**
     * uploads document for the current activity
     * @returns {} 
     */
    uploadFile() {
        var dialog = this.dialogs.showLoading();
        if (this.fileToUpload.file) {
            var file = {
                description: this.fileToUpload.description,
                name: this.fileToUpload.fileName,
                body: this.fileToUpload.file.substring(this.fileToUpload.file.indexOf('base64')+7),
                parentId: this.id
            };
            delete this.fileToUpload;
            this.fileToUpload = {};
            this.service.uploadAttachment(file).then(data => {
                
                dialog.close();
                if (data[0].success) {
                    var newDocument = new ActivityDocument();
                    newDocument.id = data[0].id;
                    newDocument.description = file.description;
                    newDocument.name = file.name;
                    newDocument.createdDate = new Date();
                    this.documents.push(newDocument);
                }
            }, data => {
                dialog.close();
            }, progress => {
                dialog.close(); 
            });
        }
        
    }
    /**
     * file selected callback
     * @param fileInput input[type=file]
     * @returns {} 
     */
    addFile(fileInput:any) {
        this.fileToUpload.file = fileInput.files.length ? fileInput.files[0] : null;
    }
    deleteDocument(indx: number) {
        if (indx < 0 || indx >= this.documents.length)
            return;
        var document = this.documents[indx];
        if (document) {
            this.dialogs.showRegistrationConfirm().result.then(result => {
                if (result) {
                    var dialog = this.dialogs.showLoading();
                    this.service.deleteDocument(document.id).then(data => {
                        this.documents.splice(indx, 1);
                        dialog.close();
                    }, data => { dialog.close(); });
                }
            });

        }
    }
    /**
     * assigned member to the current activity
     * @param registration 
     * @returns {} 
     */
    assignMember(registration: any) {
        this.dialogs.showAssignMember(this.title, registration.user.firstName + ' ' + registration.user.lastName).result.then(result => {
            if (result) {
                this.service.assignMember(this.id, registration.user.id).then((user) => {
                    this.assignedMember = registration.user;
                    this.assignedMemberRegistration = registration;
                }, error => {

                });
            }
        });  
    }
    /**
     * removes assignment from the activity
     * @returns {} 
     */
    unassignMember() {
        this.service.unassignMember(this.id).then(() => {
            this.assignedMember = null;
        }, error => {

        });
    }
    /**
     * saves the activity as a draft
     * @returns {} 
     */
    saveAsDraft() {
        this.phase = "Draft";
        this.upsert();
    }
    /**
     * publish activity
     * @returns {} 
     */
    publish() {
        this.upsert(() => {
            if (this.navigation) this.navigation.path("/publisherActivityDetailsAssignRegister/" + this.id);
        });
        
    }
    /**
     * upserts current activity to the SFDC
     * @returns {} 
     */
    private upsert(callback: any = null) {
        var dialog = this.phase === 'Draft' ? this.dialogs.showSavingDraftActivity() : this.dialogs.showLoading();
        if (this.id) {
            this.service.upsertActivity(this.getModel()).then(data => {
                dialog.close();
                if (callback) callback();
            }, data => { dialog.close(); });
        } else {
            this.service.createActivity({
                title: this.title,
                description: this.description,
                challengeType: this.challengeType,
                storyId: this.story.id,
                phase: this.phase
            }).then(data => {
                this.id = data.id;
                dialog.close();
            }, data => { dialog.close(); });
        }
    }
    /**
     * canceles activity
     * @returns {} 
     */
    cancelActivity() {
        this.dialogs.showCancelActivity(this.title).result.then(result => {
            if (result) {
                var dialogs = this.dialogs.showLoading();
                this.service.cancelActivity(this.id).then(data => {
                    this.phase = 'Canceled';
                    dialogs.close();
                }, data => {
                    dialogs.close();
                });
            }
        });
        
    }
    /**
     * completes activity
     * @returns {} 
     */
    completeActivity() {
        var dialogs = this.dialogs.showLoading();
        this.service.completeActivity(this.id).then(data => {
            this.phase = 'Completed';
            dialogs.close();
            window.location = window.location;
        }, data => {
            dialogs.close();
        });
    }
    /**
     * clones current activity
     * @returns {} 
     */
    clone() {
        return new ActivityViewModel(angular.fromJson(angular.toJson(this)));
    }

    fetchAssignedMember() {
        this.service.getAssignedMember(this.id).then(data => {
            this.assignedMemberRegistration = new ActivityRegistration(data);
        },error=>{});

    }

    assignedMemberRegistration: ActivityRegistration;
}