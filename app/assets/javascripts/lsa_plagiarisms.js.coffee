# Load dataTable

jQuery ->
        $('#lsa_plagiarisms').dataTable
                sPaginationType: "full_numbers"
                stateSave: true
                autoWidth: false
                bProcessing: true
                bServerSide: true
                dom: '<"panel-heading"lf><"panel-body"t><p><"panel-footer"i>'
                sAjaxSource: $('#lsa_plagiarisms').data('source')
                aoColumnDefs: [
                        { 'bSortable': false, 'aTargets': [ 6 ] }
                ]
                "order": [[ 2, "desc" ]]
                "rowCallback": (row, data) ->
                        $(row).addClass(data[data.length-1]);
                        return row;
