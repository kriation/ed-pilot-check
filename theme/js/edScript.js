/* because you never know when you might need some jquery */
$(document).ready(function(){
  // hide the battle-box result display
  $('.battle-box--skew').hide();

  // testing purposes only
  // $('.battle-box--skew').show();
  // var obj = {"ship": "Cobra MkIII", "station": "Morgue's Mortuary", "days": 7, "hours": 7.686388888888889, "commander": "kriation"};
  // console.log(obj);

  // var ship = obj['ship']
  //     station = obj['station']
  //     commander = obj['commander']
  //     days = obj['days']
  //     hours = obj['hours'];

  // var simpleHours = ~~hours
  //     time = days + ' days and ' + simpleHours + ' hours ago';

  // $('.battle-box--skew').append('<p><strong>Ship: </strong>' + ship + '</p> <p><strong>Location: </strong>' + station + '</p><p><strong>Reported: </strong>' + time + '</p>');

  $('button.target-commander').click(function(e){
    getMeCommander();
    e.preventDefault();
  });

  $('input.rq-form-element').bind("enterKey",function(e){
    getMeCommander();
    e.preventDefault();
  });

  function getMeCommander() {
    var commanderName = $('input.rq-form-element').val();

      // let there be ajax!
      $.ajax({
        type: 'GET',
        url: 'https://ivzn3c5vf1.execute-api.us-east-1.amazonaws.com/live/cmdr-info',
        data: { 
            commander: commanderName,
        },
        success: function(result) {          
          var ship = result['ship']
              station = result['station']
              commander = result['commander']
              days = result['days']
              hours = result['hours']
              // a lil love for those numbahs
              simpleHours = ~~hours
              time = days + ' days and ' + simpleHours + ' hours ago';

          $('.battle-box--skew .typewriter').append('<h3>Commander ' + commander + ' located!</h3><p><strong>Ship: </strong>' + ship + '</p> <p><strong>Location: </strong>' + station + '</p><p><strong>Reported: </strong>' + time + '</p>');
          // if there is a successful return of data add "Another" to the form text
          $('form h2 span').text('Another');
          // show the battle box result before typewriter effect
          $('.battle-box--skew').show();
          // typewriter effect engaged
          typeMe('.typewriter p');
        },
        error: function(result) {
          console.log(result);
          // add error classes and change text
          $('.battle-box--skew').addClass('error');
          $('.typewriter h3').addClass('error').text('Commander not found');
          $('.typewriter p:first').addClass('error').text('Or there was an error');
          // show the battle box result before typewriter effect
          $('.battle-box--skew').show();
          typeMe('.typewriter p:first');
        }
      });
  }
  // expected json response: {"ship": "Cobra MkIII", "station": "Morgue's Mortuary", "days": 7, "hours": 7.686388888888889, "commander": "kriation"}

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