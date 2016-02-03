library shareButton;

import 'package:angular2/core.dart';
import 'dart:html';

@Component(
	selector: 'share',
	templateUrl: 'share-button.html',
	styleUrls: const['shareButton.css'])
class ShareButtonComponent {

	@Input() String href;
  @Input() String icon;
  @Input() String alt;

	String get url => href.replaceFirst("SHARE_URL", Uri.encodeComponent(window.location.href));

	void share() {
		window.open(url, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
	}
}