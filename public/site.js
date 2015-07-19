/*jshint browser: true */
(function(document) {
  'use strict';

  document.addEventListener('DOMContentLoaded', function() {
    var el = document.getElementById('preview');
    var ws = new WebSocket('ws://' + location.host + location.pathname);
    ws.onmessage = function(event) {
      el.innerHTML = event.data;
    };
  });
}(document));
