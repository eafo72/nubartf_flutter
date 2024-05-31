import 'package:url_launcher/url_launcher.dart';

Future<void> launchInBrowser(url) async {
  if (!await launchUrl(url)){
    print('Could not launch url');
  }
}


