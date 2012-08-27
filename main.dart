#import('dart:io');
#import('dart:json');

main() {
  var server = new HttpServer();
  
  int port;
  try
  {
    port = Math.parseInt(Platform.environment['PORT']);  
  }
  catch(final error)
  {
    port = 0;
  }
  
  server.listen('0.0.0.0', port);
  print('Server started on port: ${port}');

  server.defaultRequestHandler = (HttpRequest request, HttpResponse response) {

    var resp = JSON.stringify({
      'Dart on Heroku': true,
      'Buildpack URL': 'https://github.com/igrigorik/heroku-buildpack-dart',
      'Environment': Platform.environment,
      'Hello': 'Intertubes',
      'Thomas': "was here",
      'Victor':'was here too... and so was your mom. :D'
    });
    

    response.headers.set(HttpHeaders.CONTENT_TYPE, 'application/json');
    response.outputStream.writeString(resp);
    response.outputStream.close();
  };
}
