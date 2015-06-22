/**************************************************
* User Service
* -------------------------------------------------
* Created By: Daniel Eagle (daniel.eagle@hp.com)
*             and Sandip Dhara (sdhara@salesforce.com)
* Last Modified: 6/22/2015
* -------------------------------------------------
* Provides user specific functionality adding,
* updating, & deactivating users. It also allows
* for assigning, removing, and updating skills for
* users and internal projects in addition to adding,
* updating, or removing internal projects themselves.
**************************************************/

// SD Comments:
// I think you should split this out into 3 different services: UserService, SkillsService, and InternalProjectServices
// I don't really think the private methods are necessary, they don't really do anything except for execute the DML
// If you are going to use the private methods, they make sense for adding and updating. I would have the private method that determines
// whether or not to do the insert of update and then does it.
// The private method for delete since all it does is the delete.
// I think we need to confirm the data that will be send
// For createUser, I don't expect Ward to send you info like alias and communityName. You should verify this. If it's not send, the user won't save
// For adding skills and updating skills, I see them passing a list of skills__c or name of the skill, instead of userSkills__c
// If we do get to choose, what we want, I prefer Ids
// SD: Comments were also added inline

public with sharing class UserService {
	public UserService() {}
	
	// custom exceptions
	public class DuplicateUserException extends Exception {}
	public class NonExistentUserException extends Exception {}
	public class NonExistentInternalProjectException extends Exception {}
	public class NullArgumentException extends Exception {}
	
	/**************************************************
	* Get User Method 
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Queries the database and returns a user object 
	* based upon the passed in user ID. If no user is 
	* found, null is returned.
	**************************************************/
	private User getUser(Id userId)
	{
		List<User> requestedUserList = new List<User>();
		
		requestedUserList = [SELECT Id, isActive FROM User where Id = :userId LIMIT 1];
	
		if (!requestedUserList.isEmpty())
		{
			User requestedUser = requestedUserList[0];
			return requestedUser;
		}
		
		return null;
	}
	
	/**************************************************
	* Create User Method
	* -------------------------------------------------
	* Creates a new user in the database based upon the 
	* passed in user object and then returns the newly 
	* created user ID.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, DuplicateUserException,
	* NullArgumentException.
	**************************************************/
	public Id createUser(User user)
	{
		Id userId;
	
		if (user == null)
		{
			throw new NullArgumentException('Create User: Unable to create user because null user argument was used.');
		}
		
		// call method to commit new user to database with boolean value indicating user is new
		userId = commitUser(user, true);
		// SD: I think you will need to setup the alias, communityName, etc. I would check with Ward, but I don't see him
		// SD: passing this to you.
		
		return userId;
	}
	
	/************************************************** 
	* Update User Method
	* -------------------------------------------------
	* Updates a user in the database based upon the 
	* passed in user object.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	public void updateUser(User user)
	{	
		if (user == null)
		{
			throw new NullArgumentException('Update User: Unable to update user because null user argument was used.');
		}
		
		// call method to commit updated user to database with boolean value indicating user is not new
		commitUser(user, false);
	}
	
	/**************************************************
	* Disable User Method
	* -------------------------------------------------
	* Disables a user in the database based upon the 
	* passed in user ID.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	public void disableUser(Id userId)
	{
		if (userId == null)
		{
			throw new NullArgumentException('Disable User: Unable to disable user because null user ID argument was used.');
		}
		
		User userToDeactivate = getUser(userId);
		
		// if user exists then deactivate them and update database	
		if (userToDeactivate != null)
		{
			userToDeactivate.isActive = false;
            update userToDeactivate;
		}
		else
		{
			throw new NonExistentUserException('Disable User: Unable to disable user because user doesn\'t exist.');
		}
	}
	
	/**************************************************
	* Commit User Method
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Commits a user to the database based upon the 
	* passed in user object and boolean value indicating
	* if user is new or not and returns the user ID.
	**************************************************/
	private Id commitUser(User user, boolean isNewUser)
	{	
		// if user doesn't already exist and is a new user, insert them into the database
		if (getUser(user.Id) == null && isNewUser)
		{
			System.debug('Commit User: Inserting user.');
			insert user;
		}
		// if user already exists and isn't a new user, update the database
		else if (getUser(user.Id) != null && !isNewUser)
		{
			System.debug('Commit User: Updating user.');
			update user;
		}
		// if user doesn't already exist and isn't a new user, do nothing and print error
		else if (getUser(user.Id) == null && !isNewUser)
		{
			throw new NonExistentUserException('Commit User: Update failed as user doesn\'t exist.');
		}
		// if user already exists and is a new user, do nothing and print error
		else if (getUser(user.Id) != null && isNewUser)
		{
			throw new DuplicateUserException('Commit User: Create user failed as user already exists.');
		}
		
		return user.Id;
	}
	
	/**************************************************
	* Get User Skills Method
	* -------------------------------------------------
	* Queries the database and returns a list of user 
	* skills based upon the passed in user ID. If no 
	* skills are found, an empty list is returned.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	public List<UserSkill__c> getUserSkills(Id userId)
	{
		if (userId == null)
		{
			throw new NullArgumentException('Get User Skills: Unable to get skills because null user ID argument was used.');
		}
		
		List<UserSkill__c> requestedSkills = new List<UserSkill__c>();
	
		if (userId != null)
		{
			requestedSkills = [SELECT Id, Name, Skill__c FROM UserSkill__c WHERE Member__c = :userId AND IsDeleted = false];	
		}
		else
		{
			throw new NonExistentUserException('Get User Skills: Unable to get skills as user doesn\'t exist.');
		}

		return requestedSkills;
	}
	
	/**************************************************
	* Add User Skills Method
	* -------------------------------------------------
	* Adds skills to a user based upon the passed in
	* user ID and skills list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: Preventing duplicates can be done by creating a unique field and updated that field via a workflow rule
	// SD: This method won't work. Please see the method below, SD_AddUserSkills
	public void addUserSkills(Id userId, List<Skills__c> skills)
	{
		if (userId == null || skills == null)
		{
			throw new NullArgumentException('Add User Skills: Unable to add skills because null user ID or skills list argument was used.');
		}
		else if (!skills.isEmpty())
		{		
			// make sure user exists before attempting to add skills
			User user = getUser(userId);
			
			if (user != null)
			{				
				List<UserSkill__c> userSkillsToAdd = new List<UserSkill__c>(); 
				
				// enumerate over skills to be inserted and set the user ID
				for (Skills__c skill : skills)
				{
					UserSkill__c userSkill = new UserSkill__C();
					userSkill.Member__c = userId;
					userSkill.Skill__c = skill.Id;
					userSkillsToAdd.add(userSkill);
				}
				
				insert userSkillsToAdd;
			}
			else
			{
				throw new NonExistentUserException('Add User Skills: Adding skills failed as user doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Update User Skills Method
	* -------------------------------------------------
	* Updates user skills based upon the passed in user 
	* ID and skills list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: My assumption is that you will get a list of skills and that you will add/update the skills
	// SD: If the user already has the skill, then you update. If the skill doesn't exist, then you add the new skill
	// SD: Also, if it's up to us to define, I would prefer a list of skill Id's
	public void updateUserSkills(Id UserId, List<Skills__c> skills)
	{
		if (userId == null || skills == null)
		{
			throw new NullArgumentException('Update User Skills: Unable to update skills because null user ID or skills list argument was used.');
		}
		// if passed in skills aren't empty and user ID is valid, add them to cleansed list
		else if (!skills.isEmpty())
		{	
			if (userId != null)
			{			
				// List of Skills To Add/Update
				List<UserSkill__c> listSkillsToUpdate = new List<UserSkill__c>();
					
				// enumerate over skills to be updated and set the user ID
				for (Skills__c skill : skills)
				{
					UserSkill__c userSkill = new UserSkill__c();
					userSkill.Member__c = userId;
					userSkill.Skill__c = skill.Id;
					userSkill.Member_Skill__c = userId + '-' + skill.Id;
					listSkillsToUpdate.add(userSkill);
				}
				
				if (!listSkillsToUpdate.isEmpty())
				{
					upsert listSkillsToUpdate Member_Skill__c; 
				}
			}
			else
			{
				throw new NonExistentUserException('Update User Skills: Updating skills failed as user doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Remove User Skills Method
	* -------------------------------------------------
	* Removes skills based upon the passed in user ID
	* and skill list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// TODO: Find easier way to handle non-existent skills.
	public void removeUserSkills(Id userId, List<UserSkill__c> skills)
	// SD: I would prefer just the Ids, so a list of Ids. When we are deleting all, we need is the ID.
	// SD: Actually, if they are sending list of UserSkills, we don't technically need to userId.
	// SD: My guess is that you will get a list of skillIds, instead of userSkills.
	// SD; Also, does the interface allow for multiple skills to be deleted?
	{
		if (userId == null || skills == null)
		{
			throw new NullArgumentException('Remove User Skills: Unable to remove skills because null user ID or skills list argument was used.');
		}
		// if passed in skills aren't empty, set the user ID in each skill
		else if (!skills.isEmpty())
		{	
			if (userId != null)
			{
				// List of skills to delete
				List<Id> listIdsToDelete = new List<Id>();
				
				// Create list of UserSkillIds to delete
				for (UserSkill__c userSkill : skills)
				{
					if (userSkill.Id != null)
						listIdsToDelete.add(userSkill.Id);
				}
				
				// Remove skills from User
				List<UserSkill__c> skillsToDelete = [SELECT Id from UserSkill__c where Member__c = :userId AND Id in :listIdsToDelete];
				
				if (!skillsToDelete.isEmpty())
					delete skillsToDelete;
			}
			else
			{
				throw new NonExistentUserException('Remove User Skills: Removing skills failed as user doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Get Internal Project Skills Method
	* -------------------------------------------------
	* Queries the database and returns a list of 
	* internal project skills based upon the passed in 
	* internal project ID. If no skills are found, an 
	* empty list is returned.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentInternalProjectException,
	* NullArgumentException.
	**************************************************/
	public List<InternalProjectSkill__c> getInternalProjectSkills(Id internalProjectId)
	{
		if (internalProjectId == null)
		{
			throw new NullArgumentException('Get Internal Project Skills: Unable to get skills because null internal project ID argument was used.');
		}
		
		// create list to host requested skills
		List<InternalProjectSkill__c> projectSkills = new List<InternalProjectSkill__c>();
		
		if (internalProjectId != null)
		{
			projectSkills = [SELECT Id, Name, Skill__c, Skill__r.Name FROM InternalProjectSkill__c WHERE Internal_Project__c = :internalProjectId AND IsDeleted = false];	
		}
		
		return projectSkills;
	}
	
	/**************************************************
	* Add Internal Project Skills Method
	* -------------------------------------------------
	* Adds skills to an internal project based upon the 
	* passed in internal project ID and skills list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentInternalProjectException,
	* NullArgumentException.
	**************************************************/
	public void addInternalProjectSkills(Id internalProjectId, List<Skills__c> skills)
	// SD: I think that you will be able to add multiple skills to a project
	{
		if (internalProjectId == null || skills == null)
		{
			throw new NullArgumentException('Add Internal Project Skills: Unable to add skills because null internal project ID or skills list argument was used.');
		}
		else if (!skills.isEmpty())
		{	
			// check if internal project exists
			Internal_Project__c existingInternalProject = getInternalProject(internalProjectId);
			
			// List of skills to add to internal project
			List<InternalProjectSkill__c> internalProjectSkillsToAdd = new List<InternalProjectSkill__c>();
			
			if (existingInternalProject != null)
			{	
				// enumerate over skills to be inserted and set the internal project ID
				for (Skills__c skill : skills)
				{
					InternalProjectSkill__c iProjectSkill = new InternalProjectSkill__c();
					iProjectSkill.Internal_Project__c = internalProjectId;
					iProjectSkill.Skill__c = skill.Id;
					internalProjectSkillsToAdd.add(iProjectSkill);
				}

				if (!internalProjectSkillsToAdd.isEmpty())
					insert internalProjectSkillsToAdd;
			}
			else
			{
				throw new NonExistentInternalProjectException('Add Internal Project Skills: Adding skills failed as internal project doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Update Internal Project Skills Method
	* -------------------------------------------------
	* Updates internal project skills based upon the 
	* passed in internal project ID and skills list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentInternalProjectException,
	* NullArgumentException.
	**************************************************/
	public void updateInternalProjectSkills(Id internalProjectId, List<Skills__c> skills)
	{
		if (internalProjectId == null || skills == null)
		{
			throw new NullArgumentException('Update Internal Project Skills: Unable to update skills because null internal project ID or skills list argument was used.');
		}
		// if passed in skills aren't empty and internal project ID is valid, add them to cleansed list
		else if (!skills.isEmpty())
		{	
			// check if internal project exists
			Internal_Project__c existingInternalProject = getInternalProject(internalProjectId);
			
			if (existingInternalProject != null)
			{				
				// List of skills to add to internal project
				List<InternalProjectSkill__c> internalProjectSkillsToAdd = new List<InternalProjectSkill__c>();
				
				// enumerate over skills to be updated and set the internal project ID
				for (Skills__c skill : skills)
				{
					InternalProjectSkill__c iProjectSkill = new InternalProjectSkill__c();
					iProjectSkill.Internal_Project__c = internalProjectId;
					iProjectSkill.Skill__c = skill.Id;
					iProjectSkill.Internal_Project_Skill__c = internalProjectId + '-' + skill.Id;
					internalProjectSkillsToAdd.add(iProjectSkill);
				}

				if (!internalProjectSkillsToAdd.isEmpty())
					upsert internalProjectSkillsToAdd Internal_Project_Skill__c;
			}
			else
			{
				throw new NonExistentInternalProjectException('Update Internal Project Skills: Updating skills failed as internal project doesn\'t exist.');
			}
		}
	}
	
	
	/**************************************************
	* Remove Internal Projects Skills Method
	* -------------------------------------------------
	* Removes skills based upon the passed in internal
	* project ID and skill list.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentInternalProjectException,
	* NullArgumentException.
	**************************************************/
	public void removeInternalProjectSkills(Id internalProjectId, List<InternalProjectSkill__c> skills)
	{
		if (internalProjectId == null || skills == null)
		{
			throw new NullArgumentException('Remove Internal Project Skills: Unable to remove skills because null internal project ID or skills list argument was used.');
		}
		// if passed in skills aren't empty, set the internal project ID in each skill
		else if (!skills.isEmpty())
		{	
			// check if internal project exists
			Internal_Project__c existingInternalProject = getInternalProject(internalProjectId);
			
			if (existingInternalProject != null)
			{
				List<Id> internalProjectSkillsId = new List<Id>();
				
				for (InternalProjectSkill__c skill : skills)
				{
					internalProjectSkillsId.add(skill.Id);
				}

				List<InternalProjectSkill__c> internalProjectSkillsToRemove = [SELECT Id from InternalProjectSkill__c WHERE Id in :internalProjectSkillsId];
				if (!internalProjectSkillsToRemove.isEmpty())
					delete internalProjectSkillsToRemove;
			}
			else
			{
				throw new NonExistentInternalProjectException('Remove Internal Project Skills: Removing skills failed as internal project doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Get Internal Project Method 
	* (assumes clean data is passed)
	* -------------------------------------------------
	* Queries the database and returns an internal
	* project object based upon the passed in internal 
	* project ID. If no internal project is found, null 
	* is returned.
	**************************************************/
	private Internal_Project__c getInternalProject(Id internalProjectId)
	{
		List<Internal_Project__c> requestedInternalProjectList = new List<Internal_Project__c>();
		requestedInternalProjectList = [SELECT Id, Description__c, Name FROM Internal_Project__c where Id = :internalProjectId AND IsDeleted = false LIMIT 1];
		
		if (!requestedInternalProjectList.isEmpty())
		{
			Internal_Project__c requestedInternalProject = requestedInternalProjectList.get(0);
			return requestedInternalProject;
		}
		
		return null;
	}
	
	/**************************************************
	* Get Internal Projects Method
	* -------------------------------------------------
	* Queries the database and returns a list of
	* internal projects based upon the passed in user 
	* ID. If no internal projects are found, an empty
	* list is returned.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: I would consider adding Project related classes into it's own service, like ProjectService
	public List<Internal_Project__c> getInternalProjects(Id userId)
	{
		if (userId == null)
		{
			throw new NullArgumentException('Get Internal Projects: Unable to get internal projects because null user ID argument was used.');
		}
		
		// create variable to store user
		User user = getUser(userId);
		
		// create list to store requested internal projects
		List<Internal_Project__c> requestedUserInternalProjects = new List<Internal_Project__c>();
		
		// make sure user exists before attempting to return list of internal projects
		if (user != null)
		{
			requestedUserInternalProjects = [SELECT Id, Description__c, Name FROM Internal_Project__c WHERE Member__c = :userId AND IsDeleted = false];
		}
		else
		{
			throw new NonExistentUserException('Get Internal Projects: Unable to get internal projects as user doesn\'t exist.');
		}
		
		return requestedUserInternalProjects;
	}
	
	/**************************************************
	* Add Internal Projects Method
	* -------------------------------------------------
	* Adds a list of internal projects to the database
	* based on the passed user ID and internal projects.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: You don't really need to pass the userId, the userId should be part of the internalProjects object
	public void addInternalProjects(Id userId, List<Internal_Project__c> internalProjects)
	{
		if (userId == null || internalProjects == null)
		{
			throw new NullArgumentException('Add Internal Projects: Unable to add internal projects because null user ID or internal projects list argument was used.');
		}
		else if (!internalProjects.isEmpty())
		{
			List<Internal_Project__c> iProjectsToAdd = new List<Internal_Project__c>();
			insert internalProjects;
		}
		else
		{
			throw new NonExistentUserException('Add Internal Projects: Adding internal projects failed as user doesn\'t exist.');
		}		
	}
	
	/**************************************************
	* Update Internal Projects Method
	* -------------------------------------------------
	* Updates internal projects on the database assigned 
	* to user based on the passed user ID and internal 
	* projects.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: You need to pass the userId, it should already be part of the internal projects object
	public void updateInternalProjects(Id userId, List<Internal_Project__c> internalProjects)
	{
		if (userId == null || internalProjects == null)
		{
			throw new NullArgumentException('Update Internal Projects: Unable to update internal projects because null user ID or internal projects list argument was used.');
		}
		else if (!internalProjects.isEmpty())
		{
			// make sure user exists before attempting to update internal projects
			User userToUpdate = getUser(userId);
			
			if (userToUpdate != null)
			{				
				update internalProjects;
			}
			else
			{
				throw new NonExistentUserException('Update Internal Projects: Updating internal projects failed as user doesn\'t exist.');
			}
		}
	}
	
	/**************************************************
	* Remove Internal Projects Method
	* -------------------------------------------------
	* Removes internal projects assigned to user from 
	* the database based on the passed user ID and 
	* internal projects.
	* -------------------------------------------------
	* The caller must handle the following exceptions:
	* DMLException, NonExistentUserException,
	* NullArgumentException.
	**************************************************/
	// SD: All you really need is the internal project Id, you don't really need the userId
	// SD: Also, for deletes, I would prefer, just a list of Ids
	public void removeInternalProjects(Id userId, List<Internal_Project__c> internalProjects)
	{
		if (userId == null || internalProjects == null)
		{
			throw new NullArgumentException('Remove Internal Projects: Unable to remove internal projects because null user ID or internal projects list argument was used.');
		}
		// if passed in internal projects aren't empty, set the user ID in each internal project
		else if (!internalProjects.isEmpty())
		{	
			// make sure user exists before attempting to remove internal projects
			User userToUpdate = getUser(userId);
			
			if (userToUpdate != null)
			{
				List<Id> projectIdsToDelete = new List<Id>();
				
				for (Internal_Project__c internalProject : internalProjects)
				{
					projectIdsToDelete.add(internalProject.Id);
				}
				
				List<Internal_Project__c> projectsToDelete = [SELECT Id FROM Internal_Project__c WHERE Member__c = :userId AND
															 Id in :projectIdsToDelete];
															 
				if (!projectsToDelete.isEmpty())
					delete projectsToDelete;			
			}
			else
			{
				throw new NonExistentUserException('Remove Internal Projects: Removing internal projects failed as user doesn\'t exist.');
			}
		}
	}
}