 /**
 * Class with basic info about skill(Activity's, User's and standard)
 */ 
class CodeType {
    constructor(name?: string, id?: string, skillId?: string) {
        
        this.name = name;
        this.id = id;
        this.skillId = skillId;
    }
    name: string;
    id: string;
    skillId:string;
}