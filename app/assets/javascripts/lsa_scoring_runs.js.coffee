# Autofill idea_solution, scored text in new lsa scoring run form.

jQuery ->
  $("[id^=lsa_scoring_run_exercise_id]").each ->
    element = $(this)
    element.click ->
      evt = document.createEvent('Event');
      evt.initEvent('autosize.update', true, false);
      exercise_id = element[0].value
      $.getJSON "/exercises/" + exercise_id, (json) ->
        ta = document.querySelector("#exercise_ideal_solution")
        ta.value = json.ideal_solution
        ta.dispatchEvent(evt)
      $.getJSON "/exercises/" + exercise_id + "/lsa_sorting_last", (json) ->
        ta = document.querySelector("#lsa_scoring_run_first_scored_text")
        ta.value = json.first.text
        ta.dispatchEvent(evt)
        ta = document.querySelector("#lsa_scoring_run_second_scored_text")
        ta.value = json.second.text
        ta.dispatchEvent(evt)
