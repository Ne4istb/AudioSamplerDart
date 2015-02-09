import 'dart:io';
import 'package:http_server/http_server.dart' show VirtualDirectory;
import 'package:appengine/appengine.dart';

main() {

	// Assumes the server lives in bin/ and that `pub build` ran.
	var buildUri = Platform.script.resolve('../build/web');

	var staticFiles = new VirtualDirectory(buildUri.toFilePath());
	staticFiles
		..allowDirectoryListing = true
		..directoryHandler = (dir, request) {
		var indexUri = new Uri.file(dir.path).resolve('index.html');
		var uri = indexUri.toFilePath();
		staticFiles.serveFile(new File(uri), request);
	};

	runAppEngine(staticFiles.serveRequest);
}