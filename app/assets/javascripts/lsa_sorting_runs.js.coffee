# Autofill idea_solution in new lsa sorting run form.

jQuery ->
  $("[id^=lsa_sorting_run_exercise_id]").each ->
    element = $(this)
    element.click ->
      exercise_id = element[0].value
      $.getJSON "/exercises/" + exercise_id, (json) ->
        area = $("#exercise_ideal_solution").val(json.ideal_solution).change()
