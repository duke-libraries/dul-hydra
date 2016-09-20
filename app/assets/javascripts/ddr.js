$(function () {
  $('button[data-loading-text], .btn[data-loading-text]').click(function () {
      $(this).button('loading');
  });
});
