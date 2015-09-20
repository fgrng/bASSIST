# Autofill idea_solution, scored text in new lsa scoring run form.

jQuery ->
  $("[id^=lsa_scoring_run_exercise_id]").each ->
    element = $(this)
    element.click ->
      exercise_id = element[0].value
      $.getJSON "/exercises/" + exercise_id, (json) ->
        $("#exercise_ideal_solution").val(json.ideal_solution).change()
      $.getJSON "/exercises/" + exercise_id + "/lsa_sorting_last", (json) ->
        $("#lsa_scoring_run_first_scored_text").val(json.first.text).change()
        $("#lsa_scoring_run_second_scored_text").val(json.second.text).change()
