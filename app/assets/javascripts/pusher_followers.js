  var pusher = new Pusher('097feb606e4d58120d56', {
      encrypted: true
    });

 var channel = pusher.subscribe('load_followers');
    channel.bind('update', function(data) {

      console.log(data)
      var mydata = {page: data.cursor, id: data.id }
      // Should only ask back for the data relevant to the current pagination
      var page = $($('.current')[0]).html()
      page = + page.replace(/,/g, '');
      if (page==data.cursor)
        $.ajax({
           // url: $('#container').attr('data-action-url'), // Route to the Controller method
          url: "/accounts/followers",
          type: "POST",
      	dataType: "json",
          data: mydata, // This goes to Controller in params hash, i.e. params[:file_name]
     		complete: function() {},
       	success: function(data, textStatus, xhr) {
                  
                  console.log(data['data'])                  
                  $('#followers_list').empty();
                  for(var i=0; i<data['data'].length; i++){
                    $('#followers_list').append("<li id='cursor"+mydata.page+" "+i+"'>"+data['data'][i].follower+"</li>")
                  }  
                  $('#paginator').html(decodeURIComponent(data['attachmentPartial']))
                  
                    
                },
         error: function(r, e) {
                  console.log(e+" Ajax error!")
                }
      	});
    });
