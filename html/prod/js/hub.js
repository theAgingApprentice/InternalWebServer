// Real-time link filter for hub pages.
// Hides cards that contain no matching links; opens collapsed details on match.
(function () {
  var input = document.getElementById('hub-filter');
  if (!input) return;

  // Mark which <details> elements start closed so they can be restored on clear.
  document.querySelectorAll('.hub-card details').forEach(function (d) {
    if (!d.hasAttribute('open')) d.dataset.defaultClosed = '1';
  });

  input.addEventListener('input', function () {
    var q = this.value.trim().toLowerCase();
    document.querySelectorAll('.hub-card').forEach(function (card) {
      var items = Array.from(card.querySelectorAll('li'));
      if (!q) {
        card.style.display = '';
        items.forEach(function (li) { li.style.display = ''; });
        card.querySelectorAll('details[data-default-closed]').forEach(function (d) {
          d.removeAttribute('open');
        });
        return;
      }
      var anyMatch = false;
      items.forEach(function (li) {
        var match = li.textContent.toLowerCase().includes(q);
        li.style.display = match ? '' : 'none';
        if (match) {
          anyMatch = true;
          var d = li.closest('details');
          if (d) d.setAttribute('open', '');
        }
      });
      card.style.display = anyMatch ? '' : 'none';
    });
  });
}());
