import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

// 빌드할 때 --dart-define 으로 바꿀 수 있음 (기본값 = 기존 GSBOX 앱)
//   GSBOX 모바일 앱: --dart-define=HOME_URL=https://gsbox.kr/ --dart-define=APP_TITLE='GSBOX 모바일'
const String kHomeUrl = String.fromEnvironment('HOME_URL', defaultValue: 'https://gsbox.kr');
const String kAppTitle = String.fromEnvironment('APP_TITLE', defaultValue: 'GSBOX');
const String kHost = 'gsbox.kr';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GsBoxApp());
}

class GsBoxApp extends StatelessWidget {
  const GsBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _loading = true;
            _hasError = false;
          }),
          onPageFinished: (_) => setState(() => _loading = false),
          onWebResourceError: (error) {
            // 메인 페이지 로드 실패일 때만 오류 화면 표시
            if (error.isForMainFrame ?? true) {
              setState(() {
                _hasError = true;
                _loading = false;
              });
            }
          },
          onNavigationRequest: (request) async {
            final uri = Uri.parse(request.url);

            // tel:, mailto:, sms: 등은 외부 앱으로
            if (!['http', 'https'].contains(uri.scheme)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }

            // gsbox.kr 도메인은 앱 안에서, 그 외는 외부 브라우저로
            if (uri.host == kHost || uri.host.endsWith('.$kHost')) {
              return NavigationDecision.navigate;
            }
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse(kHomeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_loading) const LinearProgressIndicator(),
              if (_hasError)
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('페이지를 불러오지 못했습니다.\n네트워크 상태를 확인해주세요.',
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          setState(() => _hasError = false);
                          _controller.loadRequest(Uri.parse(kHomeUrl));
                        },
                        child: const Text('다시 시도'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
