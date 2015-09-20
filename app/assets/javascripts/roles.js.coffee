# Load dataTable

jQuery ->
        $('#students').dataTable
                pagingType: "full_numbers"
                lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
                stateSave: true
                autoWidth: false
                serverSide: true
                ajax: "students.json"
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'

# Load dataTable

jQuery ->
        $('#students_tutorial').dataTable
                pagingType: "full_numbers"
                lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
                stateSave: true
                autoWidth: false
                serverSide: true
                ajax: "students.json"
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
                columnDefs: [
                        { 'sortable': false, 'targets': [ 2, 3, 4 ] }
                ]
