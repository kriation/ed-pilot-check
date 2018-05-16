/* because you never know when you might need some jquery */
$(document).ready(function(){
  // this can be real later
  var ajaxResults = true;

  // if we get results do something fancy
  if (ajaxResults) {
    $('form h2 span').text('Another');
    typeMe('.typewriter p');
  }

  // the fancy shmancy mentioned above
  function typeMe(el) {
    $(el).each(function(index) {
      var row = this;
      var t = setTimeout(function() {
          $(row).addClass('type-me');
      }, 1300 * index);
    });
  }
});