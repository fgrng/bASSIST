# Load dataTable

jQuery ->
        $('#users').dataTable
                pagingType: "full_numbers"
                lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
                stateSave: true
                autoWidth: false
                serverSide: true
                ajax: "users.json"
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
                columnDefs: [
                        { 'sortable': false, 'targets': [ 5 ] }
                ]
