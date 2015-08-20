//init the tabs in activity details page
  if($(".member-activity-details-contents").length>0)
  {
    tabNavigation();
  }
  
  //navigate to specify tab
  function tabNavigation(){
    var params = "";
    var aParams = document.location.href.split('?');
    if(aParams.length === 1)
      return;
    else
      aParams = aParams[1].split("&");

    for(var i=0;i<aParams.length;i++)
    {
      params = aParams[i].split('=');
      if(params.length === 1)
        continue;
      
      switch(params[0])
      {
        case "tab":
          if(params[1] !== "")
          {
            var tabs = $(".sub-tabs-bar li");
            for(var j=0;j<tabs.length;j++)
            {
              if(tabs.eq(j).attr("data-tab-class") === params[1].toString())
              {
                tabs.eq(j).click();
              }
            }
          }
          break;
        case "registrants":
          if(params[1] !== "")
            $(".registrants-number").html(params[1]);
          break;
        case "submissions":
          if(params[1] !== "")
          {
            $(".submissions-number").html(params[1]);
            var submissions_number = parseInt(params[1]);
            if($(".submissions-contents").length>0)
            {
              //Publisher user Activity detail page
              var table_submission = $(".submissions-contents .table-data");
              var table_row_td = table_submission.find(".row-td");
              for(var j=(table_row_td.length-1);j>0;j--)
              {
                table_row_td.eq(j).remove();
              }
              for(var j=0;j<submissions_number;j++)
              {
                var new_row = table_row_td.eq(0).clone(true);
                new_row.removeClass("hide");
                new_row.insertBefore(table_row_td.eq(0));
              }
            }
            
            if($(".my-submissions-contents").length>0)
            {
              //Member user Activity detail page
              var table_submission = $(".my-submissions-contents .table-data");
              var table_row_td = table_submission.find(".row-td");
              for(var j=(table_row_td.length-1);j>0;j--)
              {
                table_row_td.eq(j).remove();
              }
              for(var j=0;j<submissions_number;j++)
              {
                var new_row = table_row_td.eq(0).clone(true);
                new_row.removeClass("hide");
                new_row.insertBefore(table_row_td.eq(0));
              }
            }
          }
          break;
        default:
          break;
      }
    }
  }