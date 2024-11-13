import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('Background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MessagingTutorial());
}

class MessagingTutorial extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Messaging',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Firebase Messaging'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseMessaging messaging;
  String? notificationText;
  String? fcmToken;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;

    messaging.subscribeToTopic("messaging");

    messaging.getToken().then((value) {
      setState(() {
        fcmToken = value;
      });
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      final notificationType = event.data['notification_type'];
      Color bgColor = notificationType == 'important' ? Colors.red : Colors.green;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: bgColor,
            title: Text("Notification"),
            content: Text(event.notification!.body!),
            actions: [
              TextButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Message clicked!');
    });
  }

  void _copyToClipboard() {
    if (fcmToken != null) {
      Clipboard.setData(ClipboardData(text: fcmToken!)).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("FCM Token copied to clipboard")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("FCM Token not available")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Default Title'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Messaging Tutorial"),
            SizedBox(height: 20),
            Text("FCM Token: ${fcmToken ?? 'Token not available'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _copyToClipboard,
              child: Text("Copy FCM Token"),
            ),
          ],
        ),
      ),
    );
  }
}