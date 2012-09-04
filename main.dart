#import('dart:io');
#import('dart:json');
#import('dart:math');

#import('package:dart-uuid/Uuid.dart');
#import('package:logging/logging.dart');
#import('package:puremvc-dart-multicore-framework/src/puremvc.dart');
#import('package:sqljocky/sqljocky.dart');

#source("UsersProxy.dart");

Logger log;

var multitonKey = "TestFacade";

main() {
  var server = new HttpServer();
  int port;
  try
  {
    port = parseInt(Platform.environment['PORT']);
  }
  catch(error)
  {
    port = 0;
  }
  server.listen('0.0.0.0', port);
  print('Server started on port: ${port}');
  

  //PureMVC
  List<String> someMoreDataFromMVC = getDataFromMVC();
  print("someMoreDataFromMVC[0] = ${someMoreDataFromMVC[0]}");
  print("someMoreDataFromMVC[1] = ${someMoreDataFromMVC[1]}");
  
  
  //OMG WTF BBQ SQLJOCKY TEST!!! //poop
  //Log.initialize();
  log = new Logger("##### SQLJockey");
  

  String user = 'app7026785';
  String password = 'dip4life';
  //int dbport = 16735;
  int dbport = 3306;
  String db = 'onheroku';
  //String host = 'instance25510.db.xeround.com';
  String host = 'localhost';

  //print("Starting SQLJocky Test...");
  Connection cnx = new Connection();
  print("Connecting...");
  
  try {
    Future future = cnx.connect(host, dbport, user, password, db);
   //Gotta catch em all, Pokemon! //This is to protect against hung SQL DB connections :X
    doSQLWork(future, cnx);
  }
  catch (e) {
    print("Error: $e");
    cnx.close(); 
  }

  return;
  //Json response from original tutorial
  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {
    var resp = JSON.stringify({
      'Dart on Heroku': true,
      'Buildpack URL': 'https://github.com/igrigorik/heroku-buildpack-dart',
      //'Environment': Platform.environment
      'Hello': 'Intertubes',
      'Thomas': "was here",
      'Victor':'was here too... and so was your mom. :D',
	  'Prashant':'Hell Yeah!!!',
//	  'Data1': someMoreDataFromMVC[0],
//	  'Data2': someMoreDataFromMVC[1]
    });
    response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    response.outputStream.writeString(resp);
    response.outputStream.close();
  };
}

doSQLWork(Future future, Connection connection)
{
  future.handleException( (e) {
    print("Connection failed, Is the WAMP Server on?: $e");
    return false;
  });
  
  var uuidString;
  
  future.chain((value) {
    
    print("Connection Complete!");
    if  (future.hasValue) {
    }
    //        log.debug("Creating Table...");
    //        cnx.query("create table testTable (id INT NOT NULL AUTO_INCREMENT PRIMARY KEY, data VARCHAR(100));").then((Results results) {
    //          log.debug(results.toString());
    //        });
    var rng = new Random();
    String rNumber = rng.nextInt(100).toString();
    String testData = "THISISATEST$rNumber";
    var uuid = new Uuid();
    uuidString = uuid.v1();
    print(uuidString);
    log.info("Inserting Row..."); //This doesn't run because it fires simultaneously
    Future<Results> futureResults = connection.query("INSERT INTO testtable (id, data) VALUES ('$uuidString', '$testData')"); 
    return futureResults;
    
  }).chain( (value) {
    
    //Let's use a proxy for shits and giggles
    UsersProxy proxy = new UsersProxy(connection);
    
    IFacade facade = MVCFacade.getInstance(multitonKey);
    
    //Register the proxy
    facade.registerProxy(proxy);
    
    Future<List<User>> futureList = proxy.getUsers();
    return futureList;
    
  }).transform((List<User> userList){
    
    print("The values are...");
    
    userList.forEach((User user) {
      print("User ${user.uuid}, ${user.data}");
    });
    
    return userList;
    
  }).chain((value){
    
    print("DELETE FROM testTable WHERE id='$uuidString'");
    Future<Results> futureResults = connection.query("DELETE FROM testTable WHERE id='$uuidString'");
    return futureResults;
    
  }).then((value){
    
    print("Success! Closing connection.");
    connection.close();
  });
  
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
  IFacade facade = MVCFacade.getInstance(multitonKey);
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
