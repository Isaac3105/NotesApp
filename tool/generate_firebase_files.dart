import 'dart:developer' show log;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  // ANDROID google-services.json
  final androidJson = '''
{
  "project_info": {
    "project_id": "${dotenv.env['FIREBASE_PROJECT_ID']}",
    "storage_bucket": "${dotenv.env['FIREBASE_STORAGE_BUCKET']}"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "${dotenv.env['FIREBASE_APP_ID_ANDROID']}",
        "android_client_info": {
          "package_name": "${dotenv.env['FIREBASE_PACKAGE_NAME']}"
        }
      },
      "api_key": [
        {
          "current_key": "${dotenv.env['FIREBASE_API_KEY_ANDROID']}"
        }
      ]
    }
  ],
  "configuration_version": "1"
}
''';
  File('android/app/google-services.json').writeAsStringSync(androidJson);
  log('Generated android/app/google-services.json');

  // iOS GoogleService-Info.plist
  final iosPlist = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
"http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>API_KEY</key>
	<string>${dotenv.env['FIREBASE_API_KEY_IOS']}</string>
	<key>APP_ID</key>
	<string>${dotenv.env['FIREBASE_APP_ID_IOS']}</string>
	<key>PROJECT_ID</key>
	<string>${dotenv.env['FIREBASE_PROJECT_ID']}</string>
	<key>STORAGE_BUCKET</key>
	<string>${dotenv.env['FIREBASE_STORAGE_BUCKET']}</string>
	<key>BUNDLE_ID</key>
	<string>${dotenv.env['FIREBASE_IOS_BUNDLE_ID']}</string>
	<key>GCM_SENDER_ID</key>
	<string>${dotenv.env['FIREBASE_MESSAGING_SENDER_ID']}</string>
</dict>
</plist>
''';
  File('ios/Runner/GoogleService-Info.plist').writeAsStringSync(iosPlist);
  log('Generated ios/Runner/GoogleService-Info.plist');
}
