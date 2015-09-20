# Load dataTable

jQuery ->
        $('#no_submissions').dataTable
                pagingType: "full_numbers"
                lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
                stateSave: true
                autoWidth: false
                serverSide: true
                ajax: "missing.json"
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
                "rowCallback": (row, data) ->
                        $(row).addClass(data[4]);
                        return row;
                columnDefs: [
                        { 'sortable': false, 'targets': [ 3 ] }
                ]
