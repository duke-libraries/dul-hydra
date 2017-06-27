$(function () {
  $('button[data-loading-text], .btn[data-loading-text]').click(function () {
      $(this).button('loading');
  });

  // Trigger Bootstrap UI actions
  // See http://getbootstrap.com/javascript/
  $('[data-toggle="tooltip"]').tooltip();

});
