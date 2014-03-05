library shareButton;

import 'package:angular/angular.dart';
import 'dart:html';

@NgComponent(
    selector: 'share', 
    templateUrl: 'shareButton/shareButton.html', 
    cssUrl: '',
    publishAs: 'cmp')
class ShareButtonComponent {

  @NgAttr('href')
  String href;
  
  @NgAttr('icon')
  String icon;
  
  @NgAttr('alt')
  String alt;
    
  String get url => href.replaceFirst("SHARE_URL", window.location.href);
  
  void share(){
    window.open(url, '', 'menubar=no,toolbar=no,resizable=yes,scrollbars=yes,height=600,width=600');
  }
}