# Load dataTable

jQuery ->
        $('#submissions').dataTable
                pagingType: "full_numbers"
                lengthMenu: [ [25, 50, 100, -1], [25, 50, 100, "All"] ]
                stateSave: true
                autoWidth: false
                serverSide: true
                ajax: "submissions.json"
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
                "rowCallback": (row, data) ->
                        $(row).addClass(data[data.length-1]);
                        return row;
