 $(document).ready(function() {
          $('#activeActivities').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
          $('#completedActivities').dataTable({bFilter: false,"info":false,"dom": '<"top"i>rt<"bottom"flp><"clear">',"bSort" : false,"lengthMenu": [[5, 15, 25, -1], [5, 15, 25,"All"]]});
      });