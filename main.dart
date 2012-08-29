#import('dart:io');
#import('dart:json');
#import("../mongo-dart/lib/mongo.dart");
#import('dart:math');

main() {
  var server = new HttpServer();
  
  int port;
  try
  {
    port = parseInt(Platform.environment['PORT']);  
  }
  catch(final error)
  {
    port = 0;
  }
  
  server.listen('0.0.0.0', port);
  print('Server started on port: ${port}');

  //ServerConfig serverConfig = new ServerConfig("mongodb://tuTest:d2ui12d81273hg1p387gd@ds037467.mongolab.com", 37467); //This doesn't work yet
  ServerConfig serverConfig = new ServerConfig("ds037467.mongolab.com", 37467);
  Db db = new Db("heroku_app7026785", serverConfig);
  print("Connecting to ${db.serverConfig.host}:${db.serverConfig.port}");
  db.open().chain((o){
    print("Connected!");
    DbCollection usersCollection = db.collection("users");
    return usersCollection.find().each((user){
      print("[${user['name']}]:[${user['password']}]:[user_id: ${user['user_id']}]");
      user.forEach((key,value) => print("$key -> $value"));
    });
  }).then((dummy){
    db.close();
  }); 
  
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    
    var resp = JSON.stringify({
      'Dart on Heroku': true,
      'Buildpack URL': 'https://github.com/igrigorik/heroku-buildpack-dart',
      'Environment': Platform.environment,
      'Hello': 'Intertubes',
      'Thomas': "was here",
      'Victor':'was here too... and so was your mom. :D',
	  'Prashant':'Hell Yeah!!!'
    });
    
    response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    response.outputStream.writeString(resp);
    response.outputStream.close();
  };
}
