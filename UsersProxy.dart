/**
 * Users Proxy using SQLJockey.
 **/
class UsersProxy extends MVCProxy implements IProxy {
  static const String NAME = "usersProxy";
  static const String SELECT_COMPLETE = "selectComplete";
  Connection connection;
  
  UsersProxy(Connection this.connection):super( NAME ){ 
  } 
  
  Future<List<User>> getUsers() {
    
    var completer = new Completer();
    
    List<User> list = [];
    
    print("Getting Users by proxy...");
    Future<Results> futureResults = connection.query("SELECT * FROM testTable;");
    
    futureResults.then( (value) {
      
      var iterator = value.iterator();
      while(iterator.hasNext())
      {
        List row  = iterator.next();
        
        User user = new User(row[0], row[1]);
        list.add(user);
      }
      completer.complete(list);
      return value;
      
    });
    
    return completer.future;
  }
}

//VO
class User
{
  String uuid;
  String data;
  
  User(this.uuid, this.data) {}
}