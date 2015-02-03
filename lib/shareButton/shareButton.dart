library shareButton;

import 'package:angular/angular.dart';
import 'dart:html';

@Component(
	selector: 'share',
	templateUrl: 'share-button.html',
	cssUrl: 'shareButton.css')
class ShareButtonComponent {

	@NgAttr('href')
	String href;

	@NgAttr('icon')
	String icon;

	@NgAttr('alt')
	String alt;

	String get url => href.replaceFirst("SHARE_URL", Uri.encodeComponent(window.location.href));

	void share() {
		window.open(url, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	}
}