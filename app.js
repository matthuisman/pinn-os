//var systems = {};
systems = [];
boards = {
  'Pi 0'  : '0092',
 // 'Pi 0W' : '0093',
  'Pi 1'  : '2,3,4,5,6,7,8,9,d,e,f,10,11,12,14,19',
  'Pi 2'  : '1040,1041',
  'Pi 3'  : '2082'
}

$(document).ready(function(){
  get_systems();

  for (var board in boards) {
    $('#board').append('<label class="radio-inline"><input name="board" type="radio" value="'+board+'">'+board+'</label>');
  }

  $('input[name=board]').click(function () { 
    filter_systems($(this).val());
  });
});


function loading(message) {
  $('#page div').hide();
  $('#loading #loading-message').html(message);
  $('#loading').show();
}

function filter_systems(board) {
  $('#systems ul').empty();
  for (var i in systems) {
    var system = systems[i];
    if (!system.supported_hex_revisions || system.supported_hex_revisions.indexOf(boards[board]) >= 0) {
      $('#systems ul').append('<li>'+system.os_name+'</li>');
    }
  }
  $('#systems').show();
}

function show_boards() {
  $('#loading').hide();
  $('#board').show();
}

function get_systems(callback) {
  loading('Fetching availabe systems....');

  request = requestCrossDomainJSON('https://bitbucket.org/matthuisman/pinn-os/raw/master/os_master_v3.json');
  request.then(
    function(json) {
      var requests = [];
      $.each(json.master_list, function(i, list) {
        requests.push(requestCrossDomainJSON(list.os_list));
      });

      $.when.apply($, requests).then(function() {
        $.each(arguments, function(i, object) {
          $.each(object.os_list, function(i, system) {
            systems.push(system);
          });
        });

        show_boards();
      });
    }
  );
}

function requestCrossDomainJSON(url) {
  var dfd = $.Deferred();

  $.getJSON('http://query.yahooapis.com/v1/public/yql?'
        + 'q=' + encodeURIComponent('select * from json where url=@url')
        + '&url=' + encodeURIComponent(url)
        + '&format=json&callback=?',

    function(data){
      //console.log(data);
      if ( ! data.error && data.query.results) {
          dfd.resolve(data.query.results.json);
      }

      else throw new Error('Nothing returned from getJSON.');
    });

  return dfd.promise();
}