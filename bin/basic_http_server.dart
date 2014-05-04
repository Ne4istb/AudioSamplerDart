import 'dart:io';
import 'dart:async' show runZoned;
import 'package:http_server/http_server.dart' show VirtualDirectory;

void main() {
  // Assumes the server lives in bin/ and that `pub build` ran.
  var buildUri = Platform.script.resolve('../build');

  var staticFiles = new VirtualDirectory(buildUri.toFilePath());
  staticFiles
    ..allowDirectoryListing = true
    ..directoryHandler = (dir, request) {
      var indexUri = new Uri.file(dir.path).resolve('audioSampler2.html');
      var uri = indexUri.toFilePath();
      print(uri);
      staticFiles.serveFile(new File(uri), request);
    };

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  runZoned(() {
    HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
      server.listen(staticFiles.serveRequest);
    });
  }, onError: (e, stackTrace) => print('Error: $e $stackTrace'));
}