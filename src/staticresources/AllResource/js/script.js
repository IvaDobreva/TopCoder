$(document).ready(function(){
  //render the custom form elements
  if($(".form-container").length>0){
     for(var i=0;i<$('.form-container').length;i++)
     {
       if($('.form-container').eq(i).parents(".create-activity-form.hide").length === 0)
         $('.form-container').eq(i).jqTransform({imgPath:'i/'});
     }
  }
  
  /*calendar*/
  if($(".from-date").length>0)
  {
	  for(var i=0;i<$(".from-date").length;i++)
    {
      if($(".from-date").eq(i).parents(".create-activity-form.hide").length === 0)
      {
        $(".from-date").eq(i).datepicker({
	        dateFormat:"mm/dd/yy"
	      });
      }
    }
  }
  
  for(var i=0;i<$(".date-icon").length;i++)
  {
    if($(".date-icon").eq(i).parents(".create-activity-form.hide").length === 0)
    {
      $(".date-icon").eq(i).bind('click',function(){
	      $(this).prev(".from-date").trigger("click").focus();
      });
    }
  }
  if($(".to-date").length>0)
  {
	  
	  for(var i=0;i<$(".to-date").length;i++)
    {
      if($(".to-date").eq(i).parents(".create-activity-form.hide").length === 0)
      {
        $(".to-date").eq(i).datepicker({
		      dateFormat:"mm/dd/yy"
	      });
      }
    }
  }
  
  //click page body to hide Thank You message  
  $("body").click(function(){
    $(".my-submissions-contents .submissions-message").addClass("hide");
    
    $(".search-filter .blue-text-dropdown .btn-group").removeClass("active");
    $(".search-filter .blue-text-dropdown .btn-group").next().addClass("hide");
  })
  
  //click Thank You message section do not hide itself
  $(".my-submissions-contents .submissions-message").click(function(event){
    event.stopPropagation();
  })
  
  $(".filter-content").addClass("hide");
  //click Show/Hide Filter link
  $(".hide-filter,.show-filter").click(function(){
    if($(this).hasClass("hide-filter"))
    {
      //show the filter
      if($(".search-result-contents").length>0)
      {
        var filter_type = $(this).attr("data-filter-type");
        $(".filter-content."+filter_type).removeClass("hide");
        $(this).removeClass("hide-filter").addClass("show-filter");
        $(this).find("em").html("Hide Filter");
      }
      else
      {
        $(".filter-content").removeClass("hide");
        $(this).removeClass("hide-filter").addClass("show-filter");
        $(this).find("em").html("Hide Filter");
      }
    }
    else
    {
      //hide the filter
      $(".filter-content").addClass("hide");
      $(this).removeClass("show-filter").addClass("hide-filter");
      $(this).find("em").html("Filter");
    }
  })
  
  //click Cancel button in Filter section
  $(".filter-cancel-button").click(function(){
    $(".filter-content").addClass("hide");
    $(".filter-btn").removeClass("show-filter").addClass("hide-filter");
    $(".filter-btn").find("em").html("Filter");
  })
  
  $(".tab-content").addClass("hide");
  $(".tab-content").eq(0).removeClass("hide");
  //click on tabs buttons
  $(".tabs-bar li").click(function(){
    if($(this).hasClass("icon-add-btn"))
      return;
    
    var index = $(this).parent().find("li").index($(this));
    
    if(!$(this).hasClass("current"))
    {
      $(this).parent().find("li").removeClass("current");
      $(this).addClass("current");
      
      $(".tab-content").addClass("hide");
      $(".tab-content").eq(index).removeClass("hide");
    }
  })
  
  
  //render the top technologies in Publisher Dashboard page
  if($(".top-technologies-column").length>0)
  {
    var slider_item = $(".top-technologies-column .slider span");
    for(var i=0;i<slider_item.length;i++)
    {
      var width = 0;
      if(parseInt(slider_item.eq(i).attr("data-percentage"))>100)
      {
        width = 100;
      }
      else
      {
        width = parseInt(slider_item.eq(i).attr("data-percentage"));
      }
      slider_item.eq(i).width(width + "%");
    }
  }
  
  //render the technology used in Publisher Profile page
  if($(".technology-used-contents").length>0)
  {
    var slider_item = $(".technology-used-contents .blue-bar span");
    for(var i=0;i<slider_item.length;i++)
    {
      var width = 0;
      if(parseInt(slider_item.eq(i).attr("data-percentage"))>100)
      {
        width = 100;
      }
      else
      {
        width = parseInt(slider_item.eq(i).attr("data-percentage"));
      }
      slider_item.eq(i).width(width + "%");
    }
  }
  
  //render the sliders of "Area Expertise" and "Additional thechnologies" in Member Profile page
  if($(".member-info-table").length>0)
  {
    var slider_item = $(".member-info-table .blue-bar span");
    for(var i=0;i<slider_item.length;i++)
    {
      var width = 0;
      if(parseInt(slider_item.eq(i).attr("data-percentage"))>100)
      {
        width = 100;
      }
      else
      {
        width = parseInt(slider_item.eq(i).attr("data-percentage"));
      }
      slider_item.eq(i).width(width + "%");
    }
  }
  
  //select show number per page
  $(".page-bar select").change(function(){
    var total_page_number = parseInt($(this).parents(".page-bar").prev().attr("data-total-row-number"));
    var per_page_number;
    if($(this).val() === "All")
      per_page_number = total_page_number;
    else
      per_page_number = parseInt($(this).val());
    var table_rows;
    if($(this).parents(".page-bar").prev().hasClass("has-rows-group"))
    {
      table_rows = $(this).parents(".page-bar").prev().find(".row-group");
    }
    else
    {
      table_rows = $(this).parents(".page-bar").prev().find(".row-td");
    }
    
    if(per_page_number<=table_rows.length)
    {
      table_rows.addClass("hide");
      for(var i=0;i<per_page_number;i++)
      {
        table_rows.eq(i).removeClass("hide");
      }
    }
    else
    {
      table_rows.removeClass("hide");
      var clone_rows_number = per_page_number - table_rows.length;
      for(var i=0;i<clone_rows_number;i++)
      {
        var new_row = table_rows.eq(table_rows.length-1).clone(true);
        new_row.insertAfter(table_rows.eq(table_rows.length-1));
      }
    }
    
    var page_count = Math.ceil(total_page_number/per_page_number);
    $(this).parents(".page-bar").prev().attr("data-total-page-number",page_count);
    var pagination_area = $(this).parents(".page-bar").find(".pages");
    pagination_area.find(".icon-back-btn").addClass("disable");
    
    if(page_count === 1)
    {
      pagination_area.find(".icon-next-btn").addClass("disable");
    }
    else
    {
      pagination_area.find(".icon-next-btn").removeClass("disable");
    }
      
    var html = "";
    if(page_count<=9)
    {
      //show numbers directly
      pagination_area.find("ul").empty();
      for(var i=0;i<page_count;i++)
      {
        html = "<li" + (i===0 ? " class='current'" : "") 
               + "><a href='javascript:;'><i></i>" + (i+1) + "</a></li>";
        pagination_area.find("ul").append(html);
      }
    }
    else
    {
      //show a line between 1-8 and last page
      pagination_area.find("ul").empty();
      for(var i=0;i<8;i++)
      {
        html = "<li" + (i===0 ? " class='current'" : "") 
               + "><a href='javascript:;'><i></i>" + (i+1) + "</a></li>";
        pagination_area.find("ul").append(html);
      }
      
      html = "<li><div class='jump'><i></i></div></li>";
      pagination_area.find("ul").append(html);
      
      html = "<li><a href='javascript:;'><i></i>" + (page_count) + "</a></li>";;
      pagination_area.find("ul").append(html);
    }
  })
  
  //click page number dot in pagination
  $(document).on("click",".pages li",function(){
    if($(this).hasClass("current") || $(this).find(".jump").length > 0)
      return;
      
    $(this).parent().find("li").removeClass("current");
    $(this).addClass("current");
    
    var clicked_page_number = parseInt($(this).find("a").html().replace("<i></i>",""));
    if(clicked_page_number === 1)
    {
      $(this).parent().prev().addClass("disable");
    }
    else
    {
      $(this).parent().prev().removeClass("disable");
    }
    
    var total_page_number = parseInt($(this).parents(".page-bar").prev().attr("data-total-page-number"));
    if(clicked_page_number === total_page_number)
    {
      $(this).parent().next().addClass("disable");
    }
    else
    {
      $(this).parent().next().removeClass("disable");
    }
    
    var per_page_number = parseInt($(this).parents(".pages").prev().find("select").val());
    
    var first_title = $(this).parents(".page-bar").prev().find(".blue-link").eq(0);
    first_title.find("span").remove();
    first_title.html(first_title.html()+ "<span>" +clicked_page_number + "</span>");
  })
  
  //click prev button in pagination
  $(".icon-back-btn").click(function(){
    if($(this).hasClass("disable"))
      return;
    if($(this).hasClass("open-modal-window"))
      return;
    if($(this).hasClass("modal-window-close"))
      return;
    
    $(this).next().next().removeClass("disable");
    var page_numer_dots = $(this).next().find("li");
    var current_dot = $(this).next().find("li.current");
    var prev_dot = current_dot.prev();
    var current_page_number = parseInt(current_dot.find("a").html().replace("<i></i>",""));
    var total_page_number = parseInt($(this).parents(".page-bar").prev().attr("data-total-page-number"));
    if(prev_dot.find("div.jump").length === 0)
    {
      // prev is not a line
      current_dot.removeClass("current");
      prev_dot.addClass("current");
      var prev_page_number = current_page_number - 1;
      if(prev_page_number === 1)
      {
        $(this).addClass("disable");
      }
      else if((prev_page_number !== 1) && prev_dot.length === 0)
      {
        //curent item is first item in non first page
        var pagination_area = $(this).parents(".page-bar").find(".pages");
        pagination_area.find(".icon-back-btn").removeClass("disable");
        
        pagination_area.find(".icon-next-btn").removeClass("disable");
          
        var html = "";

        //show a line between 1-8 and last page
        pagination_area.find("ul").empty();
        for(var i=0;i<8;i++)
        {
          html = "<li" + (i === 7 ? " class='current'" : "") + "><a href='javascript:;'><i></i>" 
                 + (prev_page_number-7+i) + "</a></li>";
          pagination_area.find("ul").append(html);
        }
        
        html = "<li><div class='jump'><i></i></div></li>";
        pagination_area.find("ul").append(html);
        
        html = "<li><a href='javascript:;'><i></i>" + (total_page_number) + "</a></li>";;
        pagination_area.find("ul").append(html);
      }
      
      var first_title = $(this).parents(".page-bar").prev().find(".blue-link").eq(0);
      first_title.find("span").remove();
      first_title.html(first_title.html()+ "<span>" + prev_page_number + "</span>");
    }
    else
    {
      // prev is a line,which mean the current is the last page     
      var pages_left_number = current_page_number%8;
      var pagination_area = $(this).parents(".page-bar").find(".pages");
      
      pagination_area.find(".icon-prev-btn").removeClass("disable");
        
      var html = "";
      //show numbers directly
      pagination_area.find("ul").empty();
      for(var i=0;i<pages_left_number;i++)
      {
        html = "<li" + ((i === pages_left_number -2) ? " class='current'" : "") 
               + "><a href='javascript:;'><i></i>" 
               + (current_page_number-pages_left_number+i+1) + "</a></li>";
        pagination_area.find("ul").append(html);
      }
    }
  })
  
  //click next button in pagination
  $(".icon-next-btn").click(function(){
    if($(this).hasClass("disable"))
      return;
    
    $(this).prev().prev().removeClass("disable");
    var page_numer_dots = $(this).prev().find("li");
    var current_dot = $(this).prev().find("li.current");
    var next_dot = current_dot.next();
    if(next_dot.find("div.jump").length === 0)
    {
      // next is not a line
      current_dot.removeClass("current");
      next_dot.addClass("current");
      var next_page_number = parseInt(next_dot.find("a").html().replace("<i></i>",""));
      var total_page_number = parseInt($(this).parents(".page-bar").prev().attr("data-total-page-number"));
      if(next_page_number === total_page_number)
      {
        $(this).addClass("disable");
      }
      
      var first_title = $(this).parents(".page-bar").prev().find(".blue-link").eq(0);
      first_title.find("span").remove();
      first_title.html(first_title.html()+ "<span>" + next_page_number + "</span>");
    }
    else
    {
      // next is a line
      var current_page_number = parseInt(current_dot.find("a").html().replace("<i></i>",""));
      var total_page_number = parseInt($(this).parents(".page-bar").prev().attr("data-total-page-number"));
      
      var pages_left_number = total_page_number - current_page_number;
      var pagination_area = $(this).parents(".page-bar").find(".pages");
      
      if(pages_left_number === 1)
      {
        pagination_area.find(".icon-next-btn").addClass("disable");
      }
      else
      {
        pagination_area.find(".icon-next-btn").removeClass("disable");
      }
        
      var html = "";
      if(pages_left_number<=9)
      {
        //show numbers directly
        pagination_area.find("ul").empty();
        for(var i=0;i<pages_left_number;i++)
        {
          html = "<li" + (i===0 ? " class='current'" : "") 
                 + "><a href='javascript:;'><i></i>" + (current_page_number+i+1) + "</a></li>";
          pagination_area.find("ul").append(html);
        }
      }
      else
      {
        //show a line between 1-8 and last page
        pagination_area.find("ul").empty();
        for(var i=0;i<8;i++)
        {
          html = "<li" + (i===0 ? " class='current'" : "") 
                 + "><a href='javascript:;'><i></i>" 
                 + (current_page_number+i+1) + "</a></li>";
          pagination_area.find("ul").append(html);
        }
        
        html = "<li><div class='jump'><i></i></div></li>";
        pagination_area.find("ul").append(html);
        
        html = "<li><a href='javascript:;'><i></i>" 
               + (current_page_number+pages_left_number) + "</a></li>";;
        pagination_area.find("ul").append(html);
      }
    }
  })
  
  //click Cancel Activity button
  $(".cancel-activity-button").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal");
  })
  
  //click Yes button in Cancel Activity modal window
  $(".modal-cancel-activity .yes-btn").click(function(){
    if($(".tabs-bar").length>0)
    {
      $(".clicked-to-show-modal").parents(".activity-contents.tab-content").prev().removeClass("hide");
      $(".clicked-to-show-modal").parents(".activity-contents.tab-content").remove();
      
      var current_tab = $(".tabs-bar").find("li.current");
      current_tab.prev().addClass("current");
      current_tab.remove();
    }
    else
    {
      location.href = "publisher-dashboard.html";
    }
  })
  
  $(".publisher-mains .sub-tab-content").addClass("hide");
  $(".publisher-mains .sub-tab-content").eq(0).removeClass("hide");
  //click sub tab bar items in activity detail page
  $(".sub-tabs-bar li").click(function(){
    if($(this).hasClass("disable"))
      return;
      
    if($(".search-result-contents").length>0)
      return;
    
    var index = $(this).parent().find("li").index($(this));
    
    if(!$(this).hasClass("current"))
    {
      $(this).parent().find("li").removeClass("current");
      $(this).addClass("current");
      
      $(this).parents(".tab-content").find(".sub-tab-content").addClass("hide");
      $(this).parents(".tab-content").find(".sub-tab-content").eq(index).removeClass("hide");
    }
  })
  
  //click Unassign button
  $(document).on("click",".unassign-button",function(){
    $(this).parents(".row-td").remove();
  })
  
  //click Assign button
  $(".assign-button").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal");
  })
  
  //click Yes button in Assign Member modal window
  $(".modal-assign-member .yes-btn").click(function(){
    var new_row = $(".clicked-to-show-modal").parents(".row-td").clone();
    new_row.find(".assign-button").html("Unassign");
    new_row.find(".assign-button").attr("class","blue-link width65 text-right spacing-left7 pull-right unassign-button");
    $(".clicked-to-show-modal").parents(".unassigned-table").prev().append(new_row);
  })
  
  //click Register button
  $(".icon-register-btn").click(function(){
    $(this).addClass("hide");
    $(this).prev().removeClass("hide");
    $(this).next().removeClass("disable");
  })
  
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
            
          }
          break;
        default:
          break;
      }
    }
  }
  
  //click sortable table header
  $(".sorting-dwon-btn,.sorting-up-btn").click(function(){
    var sort_column_index = $(this).parent().find("div").index($(this));
    var sorted_rows = $(this).parents(".table-data").find(".row-td");
    var length = sorted_rows.length;
    
    if($(this).hasClass("sorting-dwon-btn"))
    {
      //sort by ascending
      $(this).removeClass("sorting-dwon-btn").addClass("sorting-up-btn");
      
      for (var i=0;i<length;i++){
        for (var j=i+1;j<length;j++){
          if($(this).hasClass("sort-name"))
          {
            //sort name
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find(".blue-link").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find(".blue-link").html();
            if(value_i.localeCompare(value_j) === 1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-date"))
          {
            //sort date
            var date_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html();
            var date_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html();
            var date_i_array = date_i.substring(0, 10).split('/');
            var date_j_array = date_j.substring(0, 10).split('/');

            date_i = date_i_array[1] + '-' + date_i_array[0] + '-' + date_i_array[2];
            date_j = date_j_array[1] + '-' + date_j_array[0] + '-' + date_j_array[2];
            
            var a = (Date.parse(date_i) - Date.parse(date_j)) / 3600;
            if (a > 0) {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-number"))
          {
            //sort number
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html();
            if(parseInt(value_i)>parseInt(value_j))
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-string"))
          {
            //sort string
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find("p").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find("p").html();
            if(value_i.localeCompare(value_j) === 1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-member-name"))
          {
            //sort member name
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find("a.blue-link").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find("a.blue-link").html();
            if(value_i.localeCompare(value_j) === 1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-submission-date"))
          {
            //sort submission date
            var date_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html().replace('<em class="spacing12"></em>',"");
            var date_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html().replace('<em class="spacing12"></em>',"");
            var date_i_array = date_i.substring(0, 10).split('/');
            var date_j_array = date_j.substring(0, 10).split('/');

            date_i = date_i_array[1] + '-' + date_i_array[0] + '-' + date_i_array[2] + ' ' + date_i.substring(10, 15);
            date_j = date_j_array[1] + '-' + date_j_array[0] + '-' + date_j_array[2] + ' ' + date_j.substring(10, 15);
            
            var a = (Date.parse(date_i) - Date.parse(date_j)) / 3600;
            if (a > 0) {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-submission-score"))
          {
            //sort submission score
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html().replace("%","");
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html().replace("%","");
            if(parseInt(value_i)>parseInt(value_j))
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
        }
      }
    }
    else
    {
      //sort by descending
      $(this).removeClass("sorting-up-btn").addClass("sorting-dwon-btn");
      
      for (var i=0;i<length;i++){
        for (var j=i+1;j<length;j++){
          if($(this).hasClass("sort-name"))
          {
            //sort name
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find(".blue-link").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find(".blue-link").html();
            if(value_i.localeCompare(value_j) === -1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-date"))
          {
            //sort date
            var date_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html();
            var date_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html();
            var date_i_array = date_i.substring(0, 10).split('/');
            var date_j_array = date_j.substring(0, 10).split('/');

            date_i = date_i_array[1] + '-' + date_i_array[0] + '-' + date_i_array[2];
            date_j = date_j_array[1] + '-' + date_j_array[0] + '-' + date_j_array[2];
            
            var a = (Date.parse(date_i) - Date.parse(date_j)) / 3600;
            if (a < 0) {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-number"))
          {
            //sort number
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html();
            if(parseInt(value_i)<parseInt(value_j))
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-string"))
          {
            //sort string
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find("p").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find("p").html();
            if(value_i.localeCompare(value_j) === -1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-member-name"))
          {
            //sort member name
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).find("a.blue-link").html();
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).find("a.blue-link").html();
            if(value_i.localeCompare(value_j) === -1)
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-submission-date"))
          {
            //sort submission date
            var date_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html().replace('<em class="spacing12"></em>',"");
            var date_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html().replace('<em class="spacing12"></em>',"");
            var date_i_array = date_i.substring(0, 10).split('/');
            var date_j_array = date_j.substring(0, 10).split('/');

            date_i = date_i_array[1] + '-' + date_i_array[0] + '-' + date_i_array[2] + ' ' + date_i.substring(10, 15);
            date_j = date_j_array[1] + '-' + date_j_array[0] + '-' + date_j_array[2] + ' ' + date_j.substring(10, 15);
            
            var a = (Date.parse(date_i) - Date.parse(date_j)) / 3600;
            if (a < 0) {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
          
          if($(this).hasClass("sort-submission-score"))
          {
            //sort submission score
            var value_i = sorted_rows.eq(i).find("div.col-td").eq(sort_column_index).html().replace("%","");
            var value_j = sorted_rows.eq(j).find("div.col-td").eq(sort_column_index).html().replace("%","");
            if(parseInt(value_i)<parseInt(value_j))
            {
              sorted_rows.eq(j).insertBefore(sorted_rows.eq(i));
              sorted_rows = $(this).parents(".table-data").find(".row-td");
            }
          }
        }
      }
    }
  })
  
  //click Remove in "Support Doc" section
  $(".support-doc-con .remove").click(function(){
    $(this).parent().remove();
  })
  
  //click Add More Prize button
  $(".add-more-prize-btn").click(function(){
    if($(this).hasClass("disable"))
      return;
    
    var prize_section = $(this).parents(".prizes");
    prize_section.find(".close").removeClass("hide");
    var new_prize_item = prize_section.find(".prizes-item").eq(prize_section.find(".prizes-item").length-1).clone(true);
    new_prize_item.find("input").val("");
    switch(prize_section.find(".prizes-item").length+1)
    {
      case 1:
        new_prize_item.find(".turn").html("1st");
        break;
      case 2:
        new_prize_item.find(".turn").html("2nd");
        break;
      case 3:
        new_prize_item.find(".turn").html("3rd");
        break;
      default:
        new_prize_item.find(".turn").html(prize_section.find(".prizes-item").length+1+"th");
        break;
    }
    new_prize_item.insertAfter(prize_section.find(".prizes-item").eq(prize_section.find(".prizes-item").length-1));
  })
  
  //click Remove icon in Prize section
  $(".prizes-item .close").click(function(){
    if($(this).parent().hasClass("disable"))
      return;
  
    var prize_section = $(this).parent().parent();
    
    var total_prize_items = prize_section.find(".prizes-item").length-1;
    if(total_prize_items === 1)
    {
      prize_section.find(".close").addClass("hide");
    }
    $(this).parent().remove();
    
    for(var i=0;i<total_prize_items;i++)
    {
      switch(i+1)
      {
      case 1:
        prize_section.find(".prizes-item").eq(i).find(".turn").html("1st");
        break;
      case 2:
        prize_section.find(".prizes-item").eq(i).find(".turn").html("2nd");
        break;
      case 3:
        prize_section.find(".prizes-item").eq(i).find(".turn").html("3rd");
        break;
      default:
        prize_section.find(".prizes-item").eq(i).find(".turn").html(i+1+"th");
        break;
    }
    }
  })
  
  //type tag in input
  $(".tag-in").keyup(function(event){
    if(event.which === 13)
    {
      var tag_values = $(this).val().split(",");
      $(this).val("");
      for(var i=0;i<tag_values.length;i++)
      {
        if(tag_values[i].trim() === "")
          continue;
        var new_tag = $(this).parent().find(".tag-type.hide").clone(true);
        new_tag.removeClass("hide");
        new_tag.find("span").html(tag_values[i]);
        new_tag.insertBefore($(this));
      }
    }
  })
  
  //click delete icon of tags
  $(".tag-type .close").click(function(){
    $(this).parent().remove();
  })
  
  //click Add More Requirement button
  $(".add-more-requirement-btn").click(function(){
    var requirement_section = $(this).parents(".active-require");
    var parent_requirement_number = requirement_section.find(".require-box-parent").length;
    var new_parent_requirement = requirement_section.find(".require-box-parent.hide").clone(true);
    new_parent_requirement.removeClass("hide");
    
    new_parent_requirement.find(".require-tit .tit-con").eq(0).html("Requirement " + parent_requirement_number + ".0");
    new_parent_requirement.insertBefore(requirement_section.find(".require-box-parent.hide"));
    new_parent_requirement.find(".selects-container").empty();
    var html = "<select>"
               +  "<option>Select</option>"
               +  "<option>Critical</option>"
               +  "<option>High</option>"
               +  "<option>Medium</option>"
               +  "<option>Low</option>"
               +"</select>";
    new_parent_requirement.find(".selects-container").html(html);
    new_parent_requirement.find(".form-container").removeClass("jqtransformdone");
    new_parent_requirement.find(".form-container").jqTransform({imgPath:'i/'});
  })
  
  //click Add Child Requirement button
  $(".add-child-requirement-btn").click(function(){
    var requirement_parent_section = $(this).parent().parents(".require-box-parent");
    var parent_requirement_number = requirement_parent_section.find(".require-tit .tit-con").eq(0).html().replace("Requirement ",'').replace(".0",'');
    var child_requirement_number = requirement_parent_section.find(".require-box-son").length-requirement_parent_section.find(".require-box-son.hide").length;
    var new_child_requirement;

    new_child_requirement = requirement_parent_section.find(".end-son.hide").clone(true);
    if(child_requirement_number > 0)
      requirement_parent_section.find(".end-son").eq(0).removeClass("end-son").addClass("another-son");
    new_child_requirement.insertBefore(requirement_parent_section.find(".end-son"));
    new_child_requirement.removeClass("hide");
    new_child_requirement.find(".selects-container").empty();
    var html = "<select>"
               +  "<option>Select</option>"
               +  "<option>Critical</option>"
               +  "<option>High</option>"
               +  "<option>Medium</option>"
               +  "<option>Low</option>"
               +"</select>";
    new_child_requirement.find(".selects-container").html(html);
    new_child_requirement.find(".form-container").removeClass("jqtransformdone");
    new_child_requirement.find(".form-container").jqTransform({imgPath:'i/'});
      
    new_child_requirement.find(".require-tit .tit-con").eq(0).html("Requirement " + parent_requirement_number + "." + (child_requirement_number+1)); 
  })
  
  //click Delete button of Requirement box
  $(".require-box .close").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal"); 
  })
  
  //click Yes button in Delete Requirement Box modal window
  $(".modal-delete-requirement-box .yes-btn").click(function(){
    $(".clicked-to-show-modal").parent().parent().remove();
  })
  
  //select Importance select box
  $(document).on("change",".require-box select",function(){
    var selected_option = $(this).val();
    $(this).parents(".importance").parent().attr("class","require-tit "+"ex-"+selected_option.toLowerCase());
  })
  
  //click Add Activity button
  $(".create-story-step2 .add-activity-btn").click(function(){
    $(".create-step.last").addClass("create-step-step-tab");
    var total_activity_number = $(".create-activity-form").length - 1;
    if(total_activity_number>2)
    {
      var new_page_number_button = $(".carete-step-small").find("a.hide").clone(true);
      new_page_number_button.removeClass("hide");
      new_page_number_button.insertBefore($(".carete-step-small").find("a.hide"));
      
      $(".carete-step-small").find("a.on").removeClass("on");
      new_page_number_button.addClass("on");
      
      for(var i=0;i<total_activity_number;i++)
      {
        $(".carete-step-small").find("a").eq(i).html(i+1);
      }
    }
  
    var new_activity_page = $(".create-activity-form.new-activity-form.hide").clone(true);
    $(".create-activity-form").addClass("hide");
    new_activity_page.removeClass("new-activity-form");
    new_activity_page.removeClass("hide");
    new_activity_page.insertBefore($(".create-activity-form.new-activity-form.hide"));
    
    new_activity_page.find('.form-container').jqTransform({imgPath:'i/'});
    
    new_activity_page.find(".from-date").datepicker({
	    dateFormat:"mm/dd/yy"
	  });
	  
	  new_activity_page.find(".date-icon").bind('click',function(){
	    $(this).prev(".from-date").trigger("click").focus();
    });
	  
	  new_activity_page.find(".to-date").datepicker({
		  dateFormat:"mm/dd/yy"
	  });
  })
  
  //click Copy Activity button
  $(".create-story-step2 .copy-activity-btn").click(function(){
    $(".create-step.last").addClass("create-step-step-tab");
    var total_activity_number = $(".create-activity-form").length - 1;
    if(total_activity_number>2)
    {
      var new_page_number_button = $(".carete-step-small").find("a.hide").clone(true);
      new_page_number_button.removeClass("hide");
      new_page_number_button.html(total_activity_number);
      new_page_number_button.insertBefore($(".carete-step-small").find("a.hide"));
      
      $(".carete-step-small").find("a.on").removeClass("on");
      new_page_number_button.addClass("on");
      
      for(var i=0;i<total_activity_number;i++)
      {
        $(".carete-step-small").find("a").eq(i).html(i+1);
      }
    }
  
    var new_activity_page = $(".create-activity-form.copy-activity-form.hide").clone(true);
    $(".create-activity-form").addClass("hide");
    new_activity_page.removeClass("copy-activity-form");
    new_activity_page.removeClass("hide");
    new_activity_page.insertBefore($(".create-activity-form.new-activity-form.hide"));
    
    new_activity_page.find('.form-container').jqTransform({imgPath:'i/'});
    
    new_activity_page.find(".from-date").datepicker({
	    dateFormat:"mm/dd/yy"
	  });
	  
	  new_activity_page.find(".date-icon").bind('click',function(){
	    $(this).prev(".from-date").trigger("click").focus();
    });
	  
	  new_activity_page.find(".to-date").datepicker({
		  dateFormat:"mm/dd/yy"
	  });
  })
  
  //click Remove this Activity button
  $(".create-story-step2 .cancel-activity-btn").click(function(){
    var total_activity_number = $(".create-activity-form").length - 3;
    if(total_activity_number === 1)
    {
      $(".create-step.last").removeClass("create-step-step-tab");
    }
    else
    {
      var current_page_number = $(".carete-step-small").find("a.on");
      current_page_number.prev().addClass("on");
      current_page_number.remove();
      
      for(var i=0;i<total_activity_number;i++)
      {
        $(".carete-step-small").find("a").eq(i).html(i+1);
      }
    }
    
    $(this).parents(".create-activity-form").prev().removeClass("hide");
    $(this).parents(".create-activity-form").remove();
  })
  
  //click page number of activities
  $(".carete-step-small a").click(function(){
    
    var index = $(this).parent().find("a").index($(this));
    
    if(!$(this).hasClass("on"))
    {
      $(this).parent().find("a").removeClass("on");
      $(this).addClass("on");
      
      $(".create-activity-form").addClass("hide");
      $(".create-activity-form").eq(index).removeClass("hide");
    }
  })
  
  $(".edit-story-contents").addClass("hide");
  //click Edit Story button in Story Details page
  $(".edit-story-btn").click(function(){
    $(".story-contents").addClass("hide");
    $(".edit-story-contents").removeClass("hide");
  })
  
  //click Cancel and Update button in Story Details page
  $(".edit-story-contents .cancel-link,.edit-story-contents .save-btn").click(function(){
    $(".story-contents").removeClass("hide");
    $(".edit-story-contents").addClass("hide");
  })
  
  //show tooltips on icons
  $(".icon-blue-tip").hover(function(){
    $(this).next().removeClass("hide");
  },function(){
    $(this).next().addClass("hide");
  });
  
  //check/uncheck check box in Recommended Members tab
  $(".row-td .checkbox-img").click(function(){
    $(this).toggleClass("checked");
    var checked_num =  $(this).parents(".recommended-members-contents").find(".row-td .checkbox-img.checked").length;
    if(checked_num < $(this).parents(".recommended-members-contents").find(".row-td .checkbox-img").length)
    {
      $(this).parents(".recommended-members-contents").find(".row-th .checkbox-img.check-all").removeClass("checked");
    }
    
    if(checked_num === $(this).parents(".recommended-members-contents").find(".row-td .checkbox-img").length)
    {
      $(this).parents(".recommended-members-contents").find(".row-th .checkbox-img.check-all").addClass("checked");
    }
  })
  
  //check/uncheck "All" check box in Recommended Members tab
  $(".row-th .checkbox-img.check-all").click(function(){
    $(this).toggleClass("checked");
    
    if($(this).hasClass("checked"))
    {
      $(this).parents(".recommended-members-contents").find(".row-td .checkbox-img").addClass("checked");
    }
    else
    {
      $(this).parents(".recommended-members-contents").find(".row-td .checkbox-img").removeClass("checked");
    }
  })
  
  //new code start
  
  //click Review/Edit/View links in "My Submissions" tab of Publisher/Member Activity Detail page
  $(".sub-tab-content.submissions-contents .edit-view-scoreboard-link,"+
    ".sub-tab-content.my-submissions-contents .edit-view-scoreboard-link").click(function(){
    $(this).parents(".tab-content").find(".sub-tabs-bar .review-score-tab").removeClass("hide");
    $(this).parents(".tab-content").find(".sub-tabs-bar .review-score-tab").click();
  })
  
  //click Cancel button in Review tab of Publisher Activity Detail page
  $(".sub-tab-content.review-contents .cancel-review-button").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal");
  })
  
  //click Yes button in Cancel Review modal window
  $(".modal-cancel-review .yes-btn").click(function(){
    $(".clicked-to-show-modal").parents(".tab-content").find(".sub-tabs-bar .review-score-tab").addClass("hide");
    $(".clicked-to-show-modal").parents(".tab-content").find(".sub-tabs-bar .review-score-tab").prev().click();
  })
  
  //click Save Review button in Review tab of Publisher Activity Detail page
  $(".sub-tab-content.review-contents .save-review-button").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal");
  
    var validated = true;
    var textareas = $(this).parents(".sub-tab-content.review-contents").find("textarea");
    for(var i=0;i<textareas.length;i++)
    {
      if(textareas.eq(i).val() === "")
      {
        textareas.eq(i).parent().addClass("error-style");
        validated = false;
      }
    }
    
    if (validated) {
      $(this).next().find(".saving-review-btn").click();
      
    } else {
      $(this).next().find(".saving-error-btn").click();
    }
  })
  
  //click Yes button in Saving Review modal window
  $(".modal-saving-review .yes-btn").click(function(){
    $(".clicked-to-show-modal").parents(".tab-content").find(".sub-tabs-bar .review-score-tab").addClass("hide");
    $(".clicked-to-show-modal").parents(".tab-content").find(".sub-tabs-bar .review-score-tab").prev().click();
  })
  
  //focus on textarea in Review tab of Publisher Activity Detail page
  $(".sub-tab-content.review-contents textarea").focus(function(){
    $(this).parent().removeClass("error-style");
  })
  
  //click common links to open modal window
  $(".open-modal-window").click(function(){
    if($(this).hasClass("disable"))
      return;
    
    var modal_class = $(this).attr("data-modal-class");
    $(".modal-bg").removeClass("hide");
    $(".modal-container").addClass("hide");
    $("."+modal_class).removeClass("hide");
    
    //init state for "modal-uploading" modal window
    if(modal_class === "modal-uploading")
    {
      $("."+modal_class).find(".progress-box .green-bar").width("0%");
      percent_value = 0;
      loadProgressBar(100);
    }
    
    //init state for "modal-submit" modal window
    if(modal_class === "modal-submit")
    {
      $("."+modal_class).find(".browse-bar input[type=text]").val("");
      $("."+modal_class).find(".browse-bar input[type=file]").val("");
    }
  })
  
  //click common close button in modal window
  $(".modal-container .modal-window-close,.modal-container .modal-window-cancel").click(function(){
    $(".modal-bg").addClass("hide");
    $(this).parents(".modal-container").addClass("hide");
    
    if($(this).parents(".modal-container").hasClass("modal-uploading"))
    {
      clearTimeout(timer);
    }
  })
  
  //click on input box or browser button in "Submit your code" modal window
  $(".browse-bar input[type=text],.browse-bar .blue-border-btn").click(function(){
    $(this).parents(".browse-bar").find("input[type=file]").click();
  })
  
  //change value in file input box in "Submit your code" modal window
  $(".browse-bar input[type=file]").change(function(){
    $(this).parents(".browse-bar").find("input[type=text]").val($(this).val());
  })
  
  //click Filter dropdown in Search Result page
  $(".blue-text-dropdown .btn-group").click(function(){
    if(!$(this).hasClass("active"))
    {
      //open option list
      $(".search-filter .blue-text-dropdown .btn-group").removeClass("active");
      $(".search-filter .blue-text-dropdown .btn-group").next().addClass("hide");
      
      $(this).addClass("active");
      $(this).next().removeClass("hide");
    }
    else
    {
      //close option list
      $(".search-filter .blue-text-dropdown .btn-group").removeClass("active");
      $(".search-filter .blue-text-dropdown .btn-group").next().addClass("hide");
      
      $(this).removeClass("active");
      $(this).next().addClass("hide");
    }
  })
  
  //click Filter dropdown area in Search Result page
  $(".blue-text-dropdown").click(function(event){
    event.stopPropagation();
  })
  
  //click option of Filter dropdown in Search Result page
  $(".blue-text-dropdown ul a").click(function(){
    $(this).parent().parent().prev().click();
    
    $(this).parent().parent().find("a.selected").removeClass("selected");
    $(this).addClass("selected");
    
    var selected_value = $(this).html();
    $(this).parent().parent().prev().find(".value").html(selected_value);
  })
  
  //click Filter tabs in Search Result page
  $(".search-result-contents .tabs-bar li").click(function(){
    if(!$(this).hasClass("current"))
    {
      $(this).parent().find("li").removeClass("current");
      $(this).addClass("current");
    }
    
    var filter_type = $(this).attr("data-filter-type");
    if(filter_type !== "all")
    { 
      $(".search-all-results-contents .row-td").addClass("hide-filter");
      for(var i=0;i<$(".search-all-results-contents .row-td").length;i++)
      {
        if($(".search-all-results-contents .row-td").eq(i).hasClass(filter_type))
        {
          $(".search-all-results-contents .row-td").eq(i).removeClass("hide-filter");
        }
      }
      
      $(".search-all-results-contents .page-bar").addClass("hide");
      
      //Show Filter button
      $(".filter-btn").removeClass("hide");
      $(".filter-btn").attr("data-filter-type",filter_type);
      if($(".filter-btn").hasClass("show-filter"))
      {
        $(".filter-content").addClass("hide");
        $(".filter-content."+filter_type).removeClass("hide");
      }
    }
    else
    {
      $(".search-all-results-contents .row-td").removeClass("hide-filter");
      $(".search-all-results-contents .page-bar").removeClass("hide");
      
      //Hide Filter button
      $(".filter-btn").addClass("hide");
      $(".filter-btn").attr("data-filter-type",filter_type);
      $(".filter-content").addClass("hide");
    }
  })
  
  //click Register button in Search Result page
  $(".register-button-search-result").click(function(){
    $(".clicked-to-show-modal").removeClass("clicked-to-show-modal");
    $(this).addClass("clicked-to-show-modal");
  })
  
  //click Yes button in Register in Search Result modal window
  $(".modal-register-search-result .yes-btn").click(function(){
    $(".clicked-to-show-modal").addClass("hide");
    $(".clicked-to-show-modal").next().removeClass("hide");
  })
  
  //click on input box or browser button in Support Doc section of Add/Edit Activity screen
  $(".support-doc-upload-file input[type=text].file-name-input,.support-doc-upload-file .browse-link").click(function(){
    $(this).parents(".support-doc-upload-file").find("input[type=file]").click();
  })
  
  //change value in file input box in Support Doc section of Add/Edit Activity screen
  $(".support-doc-upload-file input[type=file]").change(function(){
    $(this).parents(".support-doc-upload-file").find("input[type=text].file-name-input").val($(this).val());
  })
  
  //click upload button in Support Doc section of Add/Edit Activity screen
  $(".support-doc-upload-file .blue-upload-btn").click(function(){
    var uploaded_file_name = $(this).parents(".support-doc-upload-file").find(".file-name-input").val();
    var str_uploaded_file_name = uploaded_file_name.split('\\');
    uploaded_file_name = str_uploaded_file_name[str_uploaded_file_name.length-1];
    uploaded_file_name = (uploaded_file_name!==""?uploaded_file_name:"Lorem ipsum dolor");
    
    var file_description = $(this).parents(".support-doc-upload-file").find(".file-description-input").val();
    
    var attached_table = $(this).parents(".support-doc-upload-file").find(".support-doc-data");
    var new_row = attached_table.find("li.hide").clone(true);
    new_row.find(".support-name .blue-link").html(uploaded_file_name);
    new_row.find(".support-name span").html(file_description);
    new_row.removeClass("hide");
    new_row.insertAfter(attached_table.find("li.hide"));
  })
  
  //check/uncheck No Prize checkbox in Prizes section of Add/Edit Activity screen
  $(".prizes .row-td .checkbox-img").click(function(){
    if($(this).hasClass("checked"))
    {
      $(this).parents(".prizes").find(".add-more-prize-btn").addClass("disable");
      $(this).parents(".prizes").find(".prizes-item").addClass("disable");
      $(this).parents(".prizes").find(".prizes-item input").attr("disabled","disabled");
    }
    else
    {
      $(this).parents(".prizes").find(".add-more-prize-btn").removeClass("disable");
      $(this).parents(".prizes").find(".prizes-item").removeClass("disable");
      $(this).parents(".prizes").find(".prizes-item input").removeAttr("disabled");
    }
  })
  
  //new code end
  
  //click Expand/Collapse on Notification pages
  $(".notifications-contents .row-td .click-box").click(function(){
    var row_item = $(this).parents(".row-box");
    if(row_item.hasClass("row-content-hide"))
    {
      //show row content
      row_item.removeClass("row-content-hide").addClass("row-content-show");
    }
    else
    {
      //hide row content
      row_item.removeClass("row-content-show").addClass("row-content-hide");
    }
  })
  
  //click user and email icons of row content on Notification pages
  $(".content-info li").hover(function(){
    $(".tip-text").addClass("hide");
    $(this).find(".tip-text").removeClass("hide");
    
    //event.stopPropagation();
  },function(){
    $(this).find(".tip-text").addClass("hide");
  })
  
  //click Edit button in Publisher Profile page
  $(".edit-publisher-profile-button").click(function(){
    $(".profile-contents").addClass("edit-profile-contents");
  })
  
  //click Save Profile button in Publisher Profile page
  $(".save-publisher-profile-button").click(function(){
    $(".profile-contents").removeClass("edit-profile-contents");
  })
  
  //click Edit button in Member Profile page
  $(".edit-member-profile-button").click(function(){
    $(".profile-contents").addClass("edit-profile-contents");
  })
  
  //click Save Profile button in Member Profile page
  $(".save-member-profile-button").click(function(){
    $(".profile-contents").removeClass("edit-profile-contents");
  })
  
  $(".member-info-table.edit-member-info-table").addClass("hide");
  //click Edit button of Member Skills section in Member Profile page
  $(".edit-member-profile-skills").click(function(){
    $(this).addClass("hide");
    $(this).next().removeClass("hide");
    
    $(".member-info-table").eq(0).addClass("hide");
    $(".member-info-table.edit-member-info-table").removeClass("hide");
  })
  
  //click Save button of Member Skills section in Member Profile page
  $(".save-member-profile-skills").click(function(){
    $(this).prev().removeClass("hide");
    $(this).addClass("hide");
    
    $(".member-info-table").eq(0).removeClass("hide");
    $(".member-info-table.edit-member-info-table").addClass("hide");
  })
  
  //change skill level in Member Profile page
  $(".select-skill-level").change(function(){
    var progress_bar = $(this).parents(".row-td").find(".blue-progress-bar");
    var level_blocks = progress_bar.find("li");
    level_blocks.removeClass("active");
    var i=0;
    switch($(this).val())
    {
      case "Master":
        for(i=0;i<5;i++)
        {
          level_blocks.eq(i).addClass("active");
        }
        break;
      case "Expert":
        for(i=0;i<4;i++)
        {
          level_blocks.eq(i).addClass("active");
        }
        break;
      case "Specialist":
        for(i=0;i<3;i++)
        {
          level_blocks.eq(i).addClass("active");
        }
        break;
      case "Intermediate":
        for(i=0;i<2;i++)
        {
          level_blocks.eq(i).addClass("active");
        }
        break;
      case "Junior":
        for(i=0;i<1;i++)
        {
          level_blocks.eq(i).addClass("active");
        }
        break;
      default:
        break;
    }
  })
  
  //click arrow in New Row of Member Skills section in Member Profile page
  $(".form-container-input .input-box a").click(function(){
    $(this).parent().next().toggleClass("hide");
  })
  
  //click select option in New Row of Member Skills section in Member Profile page
  $(".form-container-input ul a").click(function(){
    $(this).parent().parent().find("li a").removeClass("selected");
    $(this).addClass("selected");
    
    $(this).parent().parent().addClass("hide");
    $(this).parent().parent().prev().find("input").val($(this).html());
  })
  
  //click Add New Row of Member Skills section in Member Profile page
  $(".add-member-skill-button").click(function(){
    var current_row = $(this).parents(".blue-row-td");
    var skill_name = $(".form-container-input .input-box input").eq(0).val();
    var skill_name_index = $(".form-container-input ul").eq(0).find("a").index($(".form-container-input ul").eq(0).find("a.selected"));
    
    var skill_level = $(".form-container-input .input-box input").eq(1).val();
    var skill_level_index = $(".form-container-input ul").eq(1).find("a").index($(".form-container-input ul").eq(1).find("a.selected"));
    for(var i=0;i<$(".form-container-input").length;i++)
    {
      $(".form-container-input .input-box input").val("");
      $(".form-container-input ul li a").removeClass("selected");
      $(".form-container-input ul").addClass("hide");
    }
    
    var new_added_row = current_row.parent().find(".row-td.hide").clone(true);
    new_added_row.insertBefore(current_row.prev());
    new_added_row.removeClass("hide");
    new_added_row.find(".form-container-hidden").removeClass("form-container-hidden").addClass("form-container").jqTransform({imgPath:'i/'});
    
    var skill_name_select = new_added_row.find(".jqTransformSelectWrapper").eq(0);
    skill_name_select.find("div span").html(skill_name);
    if(skill_name_index>-1)
    {
      skill_name_select.find("ul a").removeClass("selected");
      skill_name_select.find("ul a").eq(skill_name_index).addClass("selected");
      skill_name_select.find("select").val(skill_name);
    }
    
    var skill_level_select = new_added_row.find(".jqTransformSelectWrapper").eq(1);
    skill_level_select.find("div span").html(skill_level);
    skill_level_select.find("ul a").removeClass("selected");
    skill_level_select.find("ul a").eq(skill_level_index).addClass("selected");
    skill_level_select.find("select").val(skill_level);
    skill_level_select.find("select").change();
  })
  
  //choose Activity items of Our Activities section in Home page
  $(".our-activities .round-col").click(function(){
    $(".our-activities .round-col").removeClass("round-active");
    $(this).addClass("round-active");
    
    var index = $(".our-activities .round-col").index($(this));
    
    $(".our-activities .info-box").addClass("hide");
    $(".our-activities .info-box").eq(index).removeClass("hide");
  })
  
  //click Submit button in Forget Password modal window
  $(".modal-forgot-password .submit-btn").click(function(){
    var entered_username = $(".modal-forgot-password .username-input").val();
    if(entered_username !== "user")
    {
      $(".error-text").parent().addClass("error-row");
    }
    else
    {
      $(".error-text").parent().removeClass("error-row");
      $(".modal-forgot-password").addClass("hide");
      $(".modal-confirmation").removeClass("hide");
    }
  })
  
  //change/drag&drop in select file input in Edit mode of Profile pages
  $("input[type=file].profile-image-input-file,input[type=file].banner-background-input-file").change(function(e){
    e = e || window.event;
     
    var files = e.target.files;  //FileList Objects    
    var ireg = /image\/.*/i;
    var p = $(this).prev();
 
    //do nothing if it is not a image file
    if(!files[0].type.match(ireg)) {
        return;
    }
     
    var reader = new FileReader();
     
    reader.onload = (function(file) {
        return function(e) {
            var innerHTML = '<img src="'+ this.result +'" alt="'+ file.name +'" />';
            p.empty();
            p.append(innerHTML);
        };
    })(files[0]);
    //read file content
    reader.readAsDataURL(files[0]);
  })
  
  //click browse link for banner background in Edit mode of Profile pages
  $(".browse-banner-background-link").click(function(){
    $(".banner-background-input-file").click();
  })
  
  //click browse link for profile image in Edit mode of Profile pages
  $(".browse-profile-image-link").click(function(){
    $(".profile-image-input-file").click();
  })
})

var percent_value = 0;
var timer;
//show animation effect of uploading progress bar
function loadProgressBar(max_value){
  $(".progress-box .green-bar").width(percent_value+"%");
  if(percent_value >= parseInt(max_value))
  {
    if(!$(".modal-uploading").hasClass("hide"))
    {
      //upload complete
      
      //close modal window
      $(".modal-uploading .modal-window-close").click();
      
      //go to "My Submission" tab
      var tabs = $(".sub-tabs-bar li");
      for(var i=0;i<tabs.length;i++)
      {
        if(tabs.eq(i).attr("data-tab-class") === "Submissions")
        {
          tabs.eq(i).click();
        }
      }
      
      //show Thank You message
      $(".my-submissions-contents .submissions-message").removeClass("hide");
      var uploaded_file_name = $(".modal-submit").find(".browse-bar input[type=text]").val();
      var str_uploaded_file_name = uploaded_file_name.split('\\');
      uploaded_file_name = str_uploaded_file_name[str_uploaded_file_name.length-1];
      uploaded_file_name = (uploaded_file_name!==""?uploaded_file_name:"File Name 1");
      $(".my-submissions-contents .submissions-message").find(".uploaded-file-name").html(uploaded_file_name);
      
      //add a new file row
      var new_row = $(".my-submissions-contents .row-td.hide").clone(true);
      new_row.removeClass("hide");
      new_row.find(".file-name-label").html(uploaded_file_name);
      new_row.insertAfter($(".my-submissions-contents .row-td.hide"));
    }
    else
      return;
  }
  else
  {
    percent_value++;
    timer = setTimeout("loadProgressBar(" + max_value + ")",50);
  }
}