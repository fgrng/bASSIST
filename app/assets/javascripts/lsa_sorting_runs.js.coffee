# Autofill idea_solution in new lsa sorting run form.

jQuery ->
  $("[id^=lsa_sorting_run_exercise_id]").each ->
    element = $(this)
    element.click ->
      exercise_id = element[0].value
      $.getJSON "/exercises/" + exercise_id, (json) ->
        evt = document.createEvent('Event');
        evt.initEvent('autosize.update', true, false);
        ta = document.querySelector("#exercise_ideal_solution")
        ta.value = json.ideal_solution
        ta.dispatchEvent(evt)

