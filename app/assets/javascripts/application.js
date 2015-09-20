// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap
//= require bootstrap-switch
//= require dataTables/jquery.dataTables
//= require dataTables/bootstrap/3/jquery.dataTables.bootstrap
//= require_tree .

// Load Bootstrap Tooltips

$(document).ready(function() {
    $('[data-toggle="tooltip"]').tooltip({
				container: 'body',
				delay: { "show": 250, "hide": 100 }
    });
});

// Load Bootstrap PopOver

$(function () {
    $('body').popover({
				selector: '[data-toggle="popover"]',
				trigger: 'click',
				html: true,
    });
});

$(document).on('draw.dt', function() {
    $('body').popover({
    		selector: '[data-toggle="popover"]',
				trigger: 'click',
				html: true,
    });
});

// Start autosize for textareas

$(document).ready(function() {
    autosize(document.querySelectorAll('textarea'));
});


