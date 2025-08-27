import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyWebView(),
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
  String? _currentUrl; // 自己追蹤目前網址

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(
        // 常見 Safari UA，避免被部分站台擋掉
        'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) '
            'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 '
            'Mobile/15E148 Safari/604.1',
      )
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onUrlChange: (change) {
            _currentUrl = change.url;
          },
          onNavigationRequest: (req) {
            _currentUrl = req.url; // 兼容較舊版本沒 onUrlChange 的情況
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (e) {
            setState(() {
              // failingUrl 已移除，改成用我們自己追蹤到的 _currentUrl
              _lastError = '[${e.errorCode}] ${e.description}'
                  '${_currentUrl != null ? " · $_currentUrl" : ""}';
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
        // 背景確保 Flutter 有畫出東西
        Container(color: Colors.black87),
        // WebView 疊上去
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
