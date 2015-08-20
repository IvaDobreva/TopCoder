        var filename = '',fileData = '',bFilename = '',bFileData = '';
        var isProfilePicChanged = false;
        var profilePicCompleted = false;
        var isBannerPicChanged = false;
        var bannerPicCompleted = false;
         $(document).ready(function() {
             $('#darkLayer').hide();
         	 var tableTop = 0 - $('.text-module').height();
             var pixelValue = tableTop +'px';
             $('#activeStories').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
             $('#completedStories').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
             $('#DeveloperTable').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
			 
		     var element = document.getElementById("activeStories_wrapper");
			  if (typeof(element) != 'undefined' && element != null)
			  {
				document.getElementById("activeStories_wrapper").style.top = pixelValue;
			  }
			  var element1 = document.getElementById("completedStories_wrapper");
			  if (typeof(element1) != 'undefined' && element1 != null)
			  {
				document.getElementById("completedStories_wrapper").style.top = pixelValue;
			  }
			  var element2 = document.getElementById("DeveloperTable_wrapper");
			  if (typeof(element2) != 'undefined' && element2 != null)
			  {
				document.getElementById("DeveloperTable_wrapper").style.top = pixelValue;
			  }
         });
         
         //Function to save user information
         function callSave(){  
             
                $('#darkLayer').show();
                var tableTop = 0 - $('.text-module').height();
                var pixelValue = tableTop +'px';
                document.getElementById("activeStories_wrapper").style.top = pixelValue;
                document.getElementById("completedStories_wrapper").style.top = pixelValue;
                document.getElementById("DeveloperTable_wrapper").style.top = pixelValue;
                isProfilePicChanged = false;
                profilePicCompleted = false;
                isBannerPicChanged = false;
                bannerPicCompleted = false;
                                                                                           
                filename = '',fileData = '',bFilename = '',bFileData = '';
                
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
                
                //If profile pic is changed
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
                
                //if banner pic is changed
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
            
            //cahnge border function
            function changeBorder(){
                var tableTop = 40 - $('.edit-text-module').height();
                var pixelValue = tableTop +'px';
                document.getElementById("activeStories_wrapper").style.top = pixelValue;
                document.getElementById("completedStories_wrapper").style.top = pixelValue;
                document.getElementById("DeveloperTable_wrapper").style.top = pixelValue;
            }