# Load dataTable

jQuery ->
  $('#lsa_runs').dataTable
    pagingType: "full_numbers"
    lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
    stateSave: true
    autoWidth: false
    serverSide: true
    ajax: "lsa_runs.json"
    dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
    columnDefs: [
      { 'sortable': false, 'targets': [ 1, 6 ] }
    ]
