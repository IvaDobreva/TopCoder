/**************************************************
* User Service Interface
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
* Last Modified: 7/10/2015
* -------------------------------------------------
* Establishs the contract for user specific 
* functionality adding, updating, & deactivating users. 
* It also allows for assigning, removing, and updating 
* skills for users and internal projects in addition 
* to adding, updating, or removing internal projects 
* themselves.
**************************************************/

public interface IUserService {
	
	/**************************************************
	* Create User Method
	* -------------------------------------------------
	* Creates a new user in the database.
	* -------------------------------------------------
	* @param user - user object to create in database
	* @return Id - user ID of created user
	**************************************************/
	Id createUser(User user);
	
	/************************************************** 
	* Update User Method
	* -------------------------------------------------
	* Updates a user in the database.
	* -------------------------------------------------
	* @param user - user object to update in database
	**************************************************/
	void updateUser(User user);
	
	/**************************************************
	* Disable User Method
	* -------------------------------------------------
	* Disables a user in the database.
	* -------------------------------------------------
	* @param userId - ID of user to disable in the 
	*                 database.
	**************************************************/
	void disableUser(Id userId);
	
	/**************************************************
	* Get User Skills Method
	* -------------------------------------------------
	* Gets all applicable skills assigned to a user.
	* -------------------------------------------------
	* @param userId - ID of user for requested skills
	* @return List<UserSkill__c> - list of user skills
	**************************************************/
	List<UserSkill__c> getUserSkills(Id userId);
	
	/**************************************************
	* Add User Skills Method
	* -------------------------------------------------
	* Assigns skills to a user or users.
	* -------------------------------------------------
	* @param userSkills - list of user skills
	**************************************************/
	void addUserSkills(List<UserSkill__c> userSkills);
	
	/**************************************************
	* Update User Skills Method
	* -------------------------------------------------
	* Updates a user or set of users' skills.
	* -------------------------------------------------
	* @param userSkills - list of user skills
	**************************************************/
	void updateUserSkills(List<UserSkill__c> userSkills);
	
	/**************************************************
	* Remove User Skills Method
	* -------------------------------------------------
	* Removes skills assigned to a user or users.
	* -------------------------------------------------
	* @param userSkills - list of user skills to remove
	**************************************************/
	void removeUserSkills(List<UserSkill__c> userSkills); 
	
	/**************************************************
	* Get Internal Project Skills Method
	* -------------------------------------------------
	* Gets skills associated with an internal project.
	* -------------------------------------------------
	* @param internalProjectId - ID of internal project
	*                            for requested skills
	* @return List<InternalProjectSkill__c> - list of
	*                                         skills
	**************************************************/
	List<InternalProjectSkill__c> getIntProjSkills(Id internalProjectId);
	
	/**************************************************
	* Add Internal Project Skills Method
	* -------------------------------------------------
	* Assigns skills to one or more internal projects.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills
	**************************************************/
	void addIntProjSkills(List<InternalProjectSkill__c> intProjSkills);
	
	/**************************************************
	* Update Internal Project Skills Method
	* -------------------------------------------------
	* Updates skills assigned to internal project.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills 
	**************************************************/
	void updateIntProjSkills(List<InternalProjectSkill__c> intProjSkills);
	
	/**************************************************
	* Remove Internal Projects Skills Method
	* -------------------------------------------------
	* Removes skills assigned to an internal project.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills 
	**************************************************/
	void removeIntProjSkills(List<InternalProjectSkill__c> intProjSkills);
	
	/**************************************************
	* Get User Internal Projects Method
	* -------------------------------------------------
	* Gets a list of internal projects assigned to user.
	* -------------------------------------------------
	* @param userId - ID of user to get internal projects
	* @return List<Internal_Project__c> - list of 
	*                                     internal projects
	**************************************************/
	List<Internal_Project__c> getUsrIntProjects(Id userId);
	
	/**************************************************
	* Add User Internal Projects Method
	* -------------------------------------------------
	* Adds a list of internal projects to a user or 
	* users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	*                           to assign
	**************************************************/
	void addUsrIntProjects(List<Internal_Project__c> internalProjects);
	
	/**************************************************
	* Update User Internal Projects Method
	* -------------------------------------------------
	* Updates internal projects assigned to a user or
	* users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	**************************************************/
	void updateUsrIntProjects(List<Internal_Project__c> internalProjects);
	
	/**************************************************
	* Remove User Internal Projects Method
	* -------------------------------------------------
	* Removes internal projects assigned to one or 
	* multiple users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	**************************************************/
	void removeUsrIntProjects(List<Internal_Project__c> internalProjects);
}