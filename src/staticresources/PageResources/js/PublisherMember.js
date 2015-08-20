      $(document).ready(function() {  
          var tableTop = 155 - $('.text-module').height();
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
      
       function openDialog(){
           $('#activityListModal').modal();  
       }
       
       function hideModal(){
           $('#activityListModal').hide();
       }