/**************************************************
* User Service
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
*             and Sandip Dhara (sdhara@salesforce.com)
* Last Modified: 7/17/2015
* -------------------------------------------------
* Provides user specific functionality adding,
* updating, & deactivating users. It also allows
* for assigning, removing, and updating skills for
* users and internal projects in addition to adding,
* updating, or removing internal projects themselves.
**************************************************/
// NOTE: This class could be further broken down into three separate classes: UserService, SkillService, and InternalProjectService.
//       However, this has been decided against as the cohesion of this class is rather subjective and will not affect our long-term
//       maintenance and supportability.
public with sharing class UserService implements IUserService {
	public UserService() {}
	
	// custom exceptions
	public class NonExistentUserException extends Exception {}
	public class NonExistentIntProjException extends Exception {}
	public class NullArgumentException extends Exception {}
	public class NullObjectFieldException extends Exception {}
	
	/**************************************************
	* Get User Method 
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Gets the user object based on the requested user
	* ID.
	* -------------------------------------------------
	* @param userId - ID of user to retrieve
	* @return User - user object of requested user
	**************************************************/
	private User getUser(Id userId) {
		List<User> requestedUserList = new List<User>();
		
		requestedUserList = [SELECT Id, isActive FROM User where Id = :userId LIMIT 1];
	
		if (!requestedUserList.isEmpty()) {
			return requestedUserList.get(0);
		}
		
		return null;
	}
	
	/**************************************************
	* Create User Method
	* -------------------------------------------------
	* Creates a new user in the database.
	* -------------------------------------------------
	* @param user - user object to create in database
	* @return Id - user ID of created user
    * @throws DMLException, NullArgumentException
	**************************************************/
	public Id createUser(User user) {
		Id userId;
	
		if (user == null) {
			throw new NullArgumentException('Create User: Unable to create user because null user argument was used.');
		}
		
		// call method to commit new user to database
		userId = commitUser(user);
		// SD: I think you will need to setup the alias, communityName, etc. I would check with Ward, but I don't see him
		// SD: passing this to you.
		
		return userId;
	}
	
	/************************************************** 
	* Update User Method
	* -------------------------------------------------
	* Updates a user in the database.
	* -------------------------------------------------
	* @param user - user object to update in database
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void updateUser(User user) {	
		if (user == null) {
			throw new NullArgumentException('Update User: Unable to update user because null user argument was used.');
		}
		
		// call method to commit updated user
		commitUser(user);
	}
	
	/**************************************************
	* Disable User Method
	* -------------------------------------------------
	* Disables a user in the database.
	* -------------------------------------------------
	* @param userId - ID of user to disable in the 
	*                 database.
	* @throws DMLException, NonExistentUserException,
	*         NullArgumentException
	**************************************************/
	public void disableUser(Id userId) {
		if (userId == null) {
			throw new NullArgumentException('Disable User: Unable to disable user because null user ID argument was used.');
		}
		
		User userToDeactivate = getUser(userId);
		
		// if user exists then deactivate them and update database	
		if (userToDeactivate != null)
		{
			userToDeactivate.isActive = false;
            update userToDeactivate;
		} else {
			throw new NonExistentUserException('Disable User: Unable to disable user because user doesn\'t exist.');
		}
	}
	
	/**************************************************
	* Commit User Method
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Commits a user to the database.
	* @param user - user object to commit
	* @return Id - ID of commited user
	**************************************************/
	private Id commitUser(User user) {	
		// check to see if the user already exists
		if (getUser(user.id) != null) {
			update user;
		}
		else {
			insert user;
		}
		
		return user.Id;
	}
	
	/**************************************************
	* Get User Skills Method
	* -------------------------------------------------
	* Gets all applicable skills assigned to a user.
	* -------------------------------------------------
	* @param userId - ID of user for requested skills
	* @return List<UserSkill__c> - list of user skills
	* @throws DMLException, NonExistentUserException,
	*         NullArgumentException.
	**************************************************/
	public List<UserSkill__c> getUserSkills(Id userId) {
		if (userId == null) {
			throw new NullArgumentException('Get User Skills: Unable to get skills because null user ID argument was used.');
		}
		
		List<UserSkill__c> requestedSkills = new List<UserSkill__c>();
	
		if (userId != null) {
			requestedSkills = [SELECT Id, Name, Skill__c FROM UserSkill__c WHERE Member__c = :userId AND IsDeleted = false];	
		} else {
			throw new NonExistentUserException('Get User Skills: Unable to get skills as user doesn\'t exist.');
		}

		return requestedSkills;
	}
	
	/**************************************************
	* Add User Skills Method
	* -------------------------------------------------
	* Assigns skills to a user or users.
	* -------------------------------------------------
	* @param userSkills - list of user skills
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void addUserSkills(List<UserSkill__c> userSkills) {
		if (userSkills == null) {
			throw new NullArgumentException('Add User Skills: Unable to add skills because null skills list argument was used.');
		}
		else if (!userSkills.isEmpty()) {				
			insert userSkills;
		}
	}
	
	/**************************************************
	* Update User Skills Method
	* -------------------------------------------------
	* Updates a user or set of users' skills.
	* -------------------------------------------------
	* @param userSkills - list of user skills
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void updateUserSkills(List<UserSkill__c> userSkills) {
		if (userSkills == null) {
			throw new NullArgumentException('Update User Skills: Unable to update skills because null skills list argument was used.');
		}
		else if (!userSkills.isEmpty())
		{		
			upsert userSkills;
		}
	}
	
	/**************************************************
	* Remove User Skills Method
	* -------------------------------------------------
	* Removes skills assigned to a user or users.
	* -------------------------------------------------
	* @param userSkills - list of user skills to remove
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void removeUserSkills(List<UserSkill__c> userSkills) { 
		if (userSkills == null) {
			throw new NullArgumentException('Remove User Skills: Unable to remove skills because null skills list argument was used.');
		}
		else if (!userSkills.isEmpty()) {	
			delete userSkills;
		}
	}
	
	/**************************************************
	* Get Internal Project Skills Method
	* -------------------------------------------------
	* Gets skills associated with an internal project.
	* -------------------------------------------------
	* @param internalProjectId - ID of internal project
	*                            for requested skills
	* @return List<InternalProjectSkill__c> - list of
	*                                         skills
	* @throws DMLException, NullArgumentException
	**************************************************/
	public List<InternalProjectSkill__c> getIntProjSkills(Id internalProjectId) {
		if (internalProjectId == null) {
			throw new NullArgumentException('Get Internal Project Skills: Unable to get skills because null internal project ID argument was used.');
		}
		
		// create list to host requested skills
		List<InternalProjectSkill__c> projectSkills = new List<InternalProjectSkill__c>();
		
		if (internalProjectId != null) {
			projectSkills = [SELECT Id, Name, Skill__c, Skill__r.Name FROM InternalProjectSkill__c WHERE Internal_Project__c = :internalProjectId AND IsDeleted = false];	
		}
		
		return projectSkills;
	}
	
	/**************************************************
	* Add Internal Project Skills Method
	* -------------------------------------------------
	* Assigns skills to one or more internal projects.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills 
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void addIntProjSkills(List<InternalProjectSkill__c> intProjSkills) { 
		if (intProjSkills == null) {
			throw new NullArgumentException('Add Internal Project Skills: Unable to add skills because null skills list argument was used.');
		}
		else if (!intProjSkills.isEmpty()) {	
			insert intProjSkills;
		}
	}
	
	/**************************************************
	* Update Internal Project Skills Method
	* -------------------------------------------------
	* Updates skills assigned to internal project.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills 
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void updateIntProjSkills(List<InternalProjectSkill__c> intProjSkills) { 
		if (intProjSkills == null) {
			throw new NullArgumentException('Update Internal Project Skills: Unable to update skills because null skills list argument was used.');
		}
		else if (!intProjSkills.isEmpty()) {							
			upsert intProjSkills;
		}
	}
	
	/**************************************************
	* Remove Internal Projects Skills Method
	* -------------------------------------------------
	* Removes skills assigned to an internal project.
	* -------------------------------------------------
	* @param intProjSkills - list of internal project
	*                        skills 
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void removeIntProjSkills(List<InternalProjectSkill__c> intProjSkills) {
		if (intProjSkills == null) {
			throw new NullArgumentException('Remove Internal Project Skills: Unable to remove skills because null skills list argument was used.');
		}
		else if (!intProjSkills.isEmpty()) {	
			delete intProjSkills; 
		}
	}
	
	/**************************************************
	* Get Internal Project Method 
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Gets an internal project object.
	* -------------------------------------------------
	* @param internalProjectId - ID of internal project
	*                            to retrieve
	* @throws DMLException
	**************************************************/
	private Internal_Project__c getInternalProject(Id internalProjectId) {
		List<Internal_Project__c> requestedInternalProjectList = new List<Internal_Project__c>();
		requestedInternalProjectList = [SELECT Id, Description__c, Name FROM Internal_Project__c where Id = :internalProjectId AND IsDeleted = false LIMIT 1];
		
		if (!requestedInternalProjectList.isEmpty()) {
			Internal_Project__c requestedInternalProject = requestedInternalProjectList.get(0);
			return requestedInternalProject;
		}
		
		return null;
	}
	
	/**************************************************
	* Get User Internal Projects Method
	* -------------------------------------------------
	* Gets a list of internal projects assigned to user.
	* -------------------------------------------------
	* @param userId - ID of user to get internal projects
	* @return List<Internal_Project__c> - list of 
	*                                     internal projects
	* @throws DMLException, NonExistentUserException,
	* 		  NullArgumentException
	**************************************************/
	public List<Internal_Project__c> getUsrIntProjects(Id userId) {
		if (userId == null) {
			throw new NullArgumentException('Get Internal Projects: Unable to get internal projects because null user ID argument was used.');
		}
		
		// create variable to store user
		User user = getUser(userId);
		
		// create list to store requested internal projects
		List<Internal_Project__c> requestedUserInternalProjects = new List<Internal_Project__c>();
		
		// make sure user exists before attempting to return list of internal projects
		if (user != null) {
			requestedUserInternalProjects = [SELECT Id, Description__c, Name FROM Internal_Project__c WHERE Member__c = :userId AND IsDeleted = false];
		} else {
			throw new NonExistentUserException('Get Internal Projects: Unable to get internal projects as user doesn\'t exist.');
		}
		
		return requestedUserInternalProjects;
	}
	
	/**************************************************
	* Add User Internal Projects Method
	* -------------------------------------------------
	* Adds a list of internal projects to a user or 
	* users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	*                           to assign
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void addUsrIntProjects(List<Internal_Project__c> internalProjects) {
		if (internalProjects == null) {
			throw new NullArgumentException('Add Internal Projects: Unable to add internal projects because null internal projects list argument was used.');
		}
		else if (!internalProjects.isEmpty()) {			
			insert internalProjects;
		} 	
	}
	
	/**************************************************
	* Update User Internal Projects Method
	* -------------------------------------------------
	* Updates internal projects assigned to a user or
	* users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void updateUsrIntProjects(List<Internal_Project__c> internalProjects) {
		if (internalProjects == null) {
			throw new NullArgumentException('Update Internal Projects: Unable to update internal projects because null internal projects list argument was used.');
		}
		else if (!internalProjects.isEmpty()) {
			update internalProjects;
		}
	}
	
	/**************************************************
	* Remove User Internal Projects Method
	* -------------------------------------------------
	* Removes internal projects assigned to one or 
	* multiple users.
	* -------------------------------------------------
	* @param internalProjects - list of internal projects
	* @throws DMLException, NullArgumentException
	**************************************************/
	public void removeUsrIntProjects(List<Internal_Project__c> internalProjects) {
		if (internalProjects == null) {
			throw new NullArgumentException('Remove Internal Projects: Unable to remove internal projects because null internal projects list argument was used.');
		}
		else if (!internalProjects.isEmpty()) {	
			delete internalProjects;
		}
	}
}