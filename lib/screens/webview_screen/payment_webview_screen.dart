import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String url;
  final String successUrl;

  const PaymentWebViewScreen({
    super.key,
    required this.url,
    required this.successUrl,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isPopped = false;

  void _checkUrl(String url) {
    if (_isPopped) return;

    if (url.contains(widget.successUrl) || url.contains("success=true")) {
      _isPopped = true;
      Navigator.pop(context, true); 
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
            _checkUrl(url); 
          },
          onUrlChange: (UrlChange change) {
            if (change.url != null) {
              _checkUrl(change.url!);
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (!_isPopped) {
          _isPopped = true;
          Navigator.pop(context, false); 
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Secure Payment"),
          backgroundColor: const Color(0xFF274C77),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              if (!_isPopped) {
                _isPopped = true;
                Navigator.pop(context, false);
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF274C77)),
              ),
          ],
        ),
      ),
    );
  }
}
