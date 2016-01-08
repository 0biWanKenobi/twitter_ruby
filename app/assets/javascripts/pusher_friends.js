  var pusher = new Pusher('097feb606e4d58120d56', {
      encrypted: true
    });

  var channel = pusher.subscribe('load_friends');
    channel.bind('update', function(data) {

      console.log(data)
      var mydata = {page: data.cursor, id: data.id }
      
      // Should only ask back for the data relevant to the current pagination
      var page = $('#paginator').attr('data-page')
      page = + page.replace(/,/g, '');
      if (page==data.cursor)
        $.ajax({
           // url: $('#container').attr('data-action-url'), // Route to the Controller method
          url: "/accounts/friends",
          type: "POST",
      	dataType: "json",
          data: mydata, // This goes to Controller in params hash, i.e. params[:file_name]
     		complete: function() {},
       	success: function(data, textStatus, xhr) {
                  
                  console.log(data)                  
                  $('#friends_list').empty();
                  for(var i=0; i<data.length; i++){
                    $('#friends_list').append("<li id='cursor"+mydata.page+" "+i+"'>"+data[i].friend+"</li>")
                  }                    
                  
                    
                },
         error: function(r, e) {
                  console.log(e+" Ajax error!")
                }
      	});

      if(data.percentage == 100){
        mydata = {id: data.id}
          $.ajax({
           // url: $('#container').attr('data-action-url'), // Route to the Controller method
            url: "/accounts/pagination_friends",
            type: "POST",
          dataType: "json",
            data: mydata, // This goes to Controller in params hash, i.e. params[:file_name]
          complete: function() {},
          success: function(data, textStatus, xhr) {
                    
                    
                    console.log(data)
                    $('#paginator').html(decodeURIComponent(data['pagination']))
                    
                      
                  },
           error: function(r, e) {
                    console.log(r)
                  }
          });
      } 
    });