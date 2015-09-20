# Show passage mapping on plagiarism check on mouse hover

jQuery ->
  $(".lsa-passage").each ->
    element = $(this)
    element.hover ->
      $("span[passage="+element.attr("passage")+"]").each ->
        $(this).css("background-color", "#FFAAAA")
      $("span[passage="+element.attr("mirror")+"]").each ->
        $(this).css("background-color", "#FFAAAA")
    ,
    ->
      element.css("background-color", "#FFFF00");
      $("span[passage='"+element.attr("passage")+"']").each ->
        $(this).css("background-color", "#FFFF00");
      $("span[passage='"+element.attr("mirror")+"']").each ->
        $(this).css("background-color", "#FFFF00");
