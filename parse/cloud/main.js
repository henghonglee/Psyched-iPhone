
/*Parse.Cloud.afterSave('Flash',function(request,response){
	var reqRoute = request.object.get("route");
	reqRoute.fetch({
  success: function(myObject) {
    // The object was refreshed successfully.
   console.log("running flash aftersave"+myObject.get("difficulty"));
   	request.object.set("difficulty",myObject.get("difficulty"));
			request.object.save(null, {
									success: function(saved) {
									// The object was saved successfully.
									//response.success("Done");
									console.log("successfully saved");
									},
									error: function(error) {
									console.log("failed w error"+error);
									//	response.error("failed to save, "+ error);
									// The save failed.
									// error is a Parse.Error with an error code and description.
									}
									}); 
  },
  error: function(myObject, error) {
    // The object was not refreshed successfully.
    // error is a Parse.Error with an error code and description.
  }
});

	var route = Parse.Object.extend("Route");
	var routeQuery = new Parse.Query(route);
	routeQuery.get(request.object.get("route").get("objectId"),{
		success: function(routeobject) {
		
		},
		error: function(error) {
			//response.error();
		}
	});
});
*/
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("calculateScore", function(request, response) {

//go thru all badges check and use add unique to add badges to the badgesEarned Array
// add badges points to temp score
// 


var tempscore = 0;

console.log("badges earned = "+Parse.User.current().get("badgesEarned"));
var badge = Parse.Object.extend("Badge");
var badgeQuery = new Parse.Query(badge);    
badgeQuery.containedIn("objectId",Parse.User.current().get("badgesEarned"));
badgeQuery.find({
	success: function(objects){
		for (var i = objects.length - 1; i >= 0; i--) {
			tempscore = tempscore + objects[i].get("pointsAwarded");
		};
		 var follows = Parse.Object.extend('Follow');
		  var followedQuery = new Parse.Query(follows);
		  followedQuery.equalTo('followed',Parse.User.current().get("name"))
		  var followerQuery = new Parse.Query(follows);
		  followerQuery.equalTo('follower',Parse.User.current())

		  var mainQuery = Parse.Query.or(followedQuery, followerQuery);
		  mainQuery.count({
		  	success: function(count3){
		  			tempscore = tempscore + count3*3;
		  	},
		  	error:function(error){
				response.error();
		  	}

			  });
	},
	error: function(error){
		response.error();
	}

});    

//award points for number of followed/following people
 



//awarding points for uploading routes
var Routes = Parse.Object.extend('Route');
  var routeQuery = new Parse.Query(Routes);
  routeQuery.equalTo('username',Parse.User.current().get("name"))
  routeQuery.count({
  	success: function(count3){
  			tempscore = tempscore + count3*10;
  	},
  	error:function(error){
		response.error();
  	}

	  });


//awarding points for flash sent proj
  var flashes = Parse.Object.extend('Flash');
  var flashQuery = new Parse.Query(flashes);
  flashQuery.equalTo('user',Parse.User.current())
  flashQuery.find({
  	success: function(list){
  			tempscore = tempscore + list.length*1*10;
			//for (var i = 0; i < list.length; i++) {
			//    tempscore = tempscore + list[i].get("difficulty")*1*10;  
			//}
  			  var sends = Parse.Object.extend('Sent');
			  var sendQuery = new Parse.Query(sends);
			  sendQuery.equalTo('user',Parse.User.current())
			  sendQuery.find({
			  	success: function(list2){
			  		tempscore = tempscore + list2.length*1*10;
							//for (var i = 0; i < list2.length; i++) {
							 //   tempscore = tempscore + list2[i].get("difficulty")*1*10;
							//    console.log(tempscore);
							//}
			  			  var projects = Parse.Object.extend('Project');
						  var projQuery = new Parse.Query(projects);
						  projQuery.equalTo('user',Parse.User.current())
						  projQuery.find({
						  	success: function(list3){
						  		tempscore = tempscore + list3.length*1*10;
						  			//for (var i = 0; i < list3.length; i++) {
							    	//	tempscore = tempscore + list3[i].get("difficulty")*1*10;							    	
									//}
						  			var myuser = Parse.User.current();
						  			myuser.set("score", tempscore);
						  			myuser.save(null, {
									success: function(myuser) {
									// The object was saved successfully.
									response.success("Done calculating score, score: "+tempscore);
									},
									error: function(myuser, error) {
									// The save failed.
									// error is a Parse.Error with an error code and description.
									}
									});
						  			
						  	},
						  	error:function(error){
								response.error();
						  	}

						  });
			  	},
			  	error:function(error){
					response.error();
			  	}

			  });
  	},
  	error:function(error){
		response.error();
  	}

  }); 
});


