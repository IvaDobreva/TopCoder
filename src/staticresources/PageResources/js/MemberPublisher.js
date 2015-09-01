      $(document).ready(function() {
      	 var tableTop = 20 - $('.text-module').height();
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