  var pusher = new Pusher('097feb606e4d58120d56', {
      encrypted: true
    });

	var channel = pusher.subscribe('create_user');
  channel.bind('success', function(data) {
    $('#followers_'+data.name).html(data.followers)
    $('#friends_'+data.name).html(data.friends)
    console.log('account updated')
  });


 