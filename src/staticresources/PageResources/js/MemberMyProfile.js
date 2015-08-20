      var filename = '',fileData = '',bFilename = '',bFileData = '';
      var isProfilePicChanged = false;
      var profilePicCompleted = false;
      var isBannerPicChanged = false;
      var bannerPicCompleted = false;
      
      $(document).ready(function() {
          $('#darkLayer').hide();
          var tableTop = 210 - $('.text-module').height();                        
          var pixelValue = tableTop +'px';
          $('#InternalProjects').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
          $('#CurrentActivityTable').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
          $('#CompletedActivity').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
		  
		  var element = document.getElementById("CurrentActivityTable_wrapper");
          if (typeof(element) != 'undefined' && element != null)
          {
            document.getElementById("CurrentActivityTable_wrapper").style.top = pixelValue;
          }
          var element1 = document.getElementById("InternalProjects_wrapper");
          if (typeof(element1) != 'undefined' && element1 != null)
          {
            document.getElementById("InternalProjects_wrapper").style.top = pixelValue;
          }
          
      });
      
      //function for saving user details
      function callSave(){   
          $('#darkLayer').show();
          $('#CurrentActivityTable_wrapper').removeClass("changeBorder");
          $('#InternalProjects_wrapper').removeClass("changeBorder");
          isProfilePicChanged = false;
          profilePicCompleted = false;
          isBannerPicChanged = false;
          bannerPicCompleted = false;
                                                                                     
          filename = '',fileData = '',bFilename = '',bFileData = '';
          
          //Check if image is changes or not
          if($(".profilePicture")[0].files.length > 0){
              isProfilePicChanged = true;
          }else{
              profilePicCompleted = true;
          }
          if($(".bannerPicture")[0].files.length > 0){
              isBannerPicChanged = true;
          }else{
              bannerPicCompleted = true;
          }
          
          //if profile pic is changed
          if(isProfilePicChanged){
            var file = $(".profilePicture")[0].files[0]; 
            filename = file.name;
            var fileReader = new FileReader();
            fileReader.onloadend = function(e) {
                fileData = window.btoa(this.result);  //Base 64 encode the file before sending it
                profilePicCompleted = true;
                if(profilePicCompleted && bannerPicCompleted){
                    callSaveRemoteAction();
                }
            }  
            fileReader.readAsBinaryString(file);  
          }
          
          //if banned pic is changed
          if(isBannerPicChanged){
            var file = $(".bannerPicture")[0].files[0]; 
            bFilename = file.name;
            var fileReader = new FileReader();
            fileReader.onloadend = function(e) {
                bFileData = window.btoa(this.result);  //Base 64 encode the file before sending it
                bannerPicCompleted = true;
                if(profilePicCompleted && bannerPicCompleted){
                    callSaveRemoteAction();
                }
            }  
            fileReader.readAsBinaryString(file);  
          }  
          
          //If no pic is changed                
          if(!isProfilePicChanged && !isBannerPicChanged){
              callSaveRemoteAction();
          }
          
      }
      
      function changeBorder(){
          if($('.saveSkill').hasClass('hide')){
              $('#CurrentActivityTable_wrapper').addClass("changeBorder");
              $('#InternalProjects_wrapper').addClass("changeBorder");
          }
      }
      
      //User skill object
      function CE_UserSkill__c(){
        this.Id = null; /* set a value here if you need to update or delete */
        this.Skill__c = null;
        this.Experience_Level__c = null; /* the field names must match the API names */
      }
      
      //Edit skill records
      function editSkills(){
         if($('.existingSkills').length > 0){
             $('.existingSkills').each(function () {
                 var Id = $(this).attr("id");
                 var userSkill = skillMap[Id];
                 var skillName = $(this).find("div.jqTransformSelectWrapper")[0];
                 $(skillName).find("span").text(userSkill.Skill__r.Name);
                 
                 var skillLevel = $(this).find("div.jqTransformSelectWrapper")[1];
                 $(skillLevel).find("span").text(userSkill.Experience_Level__c);
             });
         }
      }