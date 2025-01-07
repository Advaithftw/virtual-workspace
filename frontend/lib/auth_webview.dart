import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AuthWebView extends StatelessWidget {
  final String authUrl;

  const AuthWebView({super.key, required this.authUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: WebView(
        initialUrl: authUrl,
        javascriptMode: JavascriptMode.unrestricted,
        navigationDelegate: (navigation) {
          if (navigation.url.startsWith("myapp://home")) {

            
            Navigator.pop(context, navigation.url);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onPageFinished: (url) {
        },
      ),
    );
  }
}
