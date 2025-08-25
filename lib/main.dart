import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
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
  bool _isLoading = true;
  String _url = 'https://gmb.taipeiads.com/Book/login'; // 確保用 HTTPS

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),

          // 只處理「主框架」錯誤，避免子資源 404/阻擋誤判整頁失敗
          onWebResourceError: (error) async {
            debugPrint(
                "WebView Error (${error.errorCode}): ${error.description} | mainFrame=${error.isForMainFrame}");
            if (error.isForMainFrame == true) {
              await _controller.loadHtmlString('''
            <html><body style="font-family:sans-serif;display:flex;align-items:center;justify-content:center;height:100vh;">
              <div style="text-align:center">
                <h2>載入失敗，請檢查網路連線</h2>
                <button onclick="location.reload()" style="padding:10px 16px;font-size:16px;">重新整理</button>
              </div>
            </body></html>
          ''');
            }
          },

          // 如有導轉，正常放行
          onNavigationRequest: (request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://gmb.taipeiads.com/Book/login'));

  }

  Future<bool> _onWillPop() async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
      return false; // 不退出 App
    }
    return true; // 退出 App
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 不讓系統自動關閉，自己處理
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; // 如果已經被 pop，不再處理
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          Navigator.of(context).maybePop(result); // 傳回 result
        }
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
