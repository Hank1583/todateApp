import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MyWebView(),
    );
  }
}

class MyWebView extends StatefulWidget {
  const MyWebView({super.key});
  @override
  State<MyWebView> createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (e) {
            setState(() {
              _lastError = '${e.errorCode} ${e.description} (${e.failingUrl ?? ""})';
              _loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse('https://gmb.taipeiads.com/Book/login'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // 顯示彩色背景，確認 Flutter 有畫到畫面
        Container(color: Colors.black87),
        // WebView 疊在上面
        WebViewWidget(controller: _controller),
        if (_loading)
          const Center(child: CircularProgressIndicator()),
        if (_lastError != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withOpacity(0.9),
              child: Text(
                _lastError!,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ]),
    );
  }
}
