#import('dart:io');
#import('dart:json');
#import("../mongo-dart/lib/mongo.dart");
#import('dart:math');
//#import('dart:html'); 
#import('src/puremvc.dart');

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
  
  List<String> someMoreDataFromMVC = getDataFromMVC();
  //print(someMoreDataFromMVC[0]);
  //print(someMoreDataFromMVC[1]);

  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    
    var resp = JSON.stringify({
      'Dart on Heroku': true,
      'Buildpack URL': 'https://github.com/igrigorik/heroku-buildpack-dart',
      'Environment': Platform.environment,
      'Hello': 'Intertubes',
      'Thomas': "was here",
      'Victor':'was here too... and so was your mom. :D',
	  'Prashant':'Hell Yeah!!!',
	  'Data1': someMoreDataFromMVC[0],
	  'Data2': someMoreDataFromMVC[1]
    });
    
    response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    response.outputStream.writeString(resp);
    response.outputStream.close();
  };
}

List<String> getDataFromMVC()
{
  String data1 = "StupidData1";
  String data2 = "StupidData2";
  //Generate data
  List<String> dataObject = new List<String>();
  dataObject.add(data1);
  dataObject.add(data2);
  //Create Facade
  IFacade facade = MVCFacade.getInstance("TestFacade");
  //Create a proxy to hold the Data
  IProxy proxy = new MVCProxy("TestProxy", dataObject);
  //Register the proxy
  facade.registerProxy(proxy);
  //Retireve proxy
  IProxy retirevedProxy = facade.retrieveProxy("TestProxy");
  //Get Data
  List<String> retirevedDataObject = retirevedProxy.getData();
  
  return retirevedDataObject;
}
