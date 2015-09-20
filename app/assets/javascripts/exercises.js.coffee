# Decrease loading time on exercises index.
# Add submission count via js after loading page.

jQuery ->
  $('[data-count-submissions]').each ->
    element = $(this)
    request = $.ajax
      type: 'GET'
      url: '/exercises/' + element.attr("data-count-submissions") + '/count_submissions'
      dataType: 'JSON'
      success: (data) ->
        element.html(data[0] + ' / ' + data[1])

jQuery ->
  $('[data-count-submissions-tutorial]').each ->
    element = $(this)
    request = $.ajax
      type: 'GET'
      url: '/exercises/' + element.attr("data-count-submissions-exercise") + '/count_submissions'
      data: "count_tutorial=" + element.attr("data-count-submissions-tutorial")
      dataType: 'JSON'
      success: (data) ->
        element.html(data[0] + ' / ' + data[1])
