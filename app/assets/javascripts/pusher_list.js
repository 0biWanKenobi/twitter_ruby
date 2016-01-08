  var pusher = new Pusher('097feb606e4d58120d56', {
      encrypted: true
    });

	var channel = pusher.subscribe('create_user');
  channel.bind('success', function(data) {
  	$('#'+data.name).removeClass('hidden')
    $('#followers_'+data.name).html(data.followers)
    $('#friends_'+data.name).html(data.friends)
    $('#notice').html('Account '+data.name+" successfully added")
    console.log('account updated')
  });

  channel.bind('not_found', function(data){

  	$('#'+data.name).remove()
  	$('#notice').html('Account '+data.name+" not found").addClass('error')
  	console.log(name+" not found")
  });



 