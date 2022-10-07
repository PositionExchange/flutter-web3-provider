import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web3_provider/web3_provider.dart';

class CommunicateDapp extends StatefulWidget {
  const CommunicateDapp({Key? key}) : super(key: key);

  @override
  State<CommunicateDapp> createState() => _CommunicateDappState();
}

class _CommunicateDappState extends State<CommunicateDapp> {
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      userAgent:
          "Mozilla/5.0 (Linux; Android 4.4.4; SAMSUNG-SM-N900A Build/tt) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/33.0.0.0 Mobile Safari/537.36",
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      domStorageEnabled: true,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: InAppWebView(
          initialData: InAppWebViewInitialData(
            data: """
                  <!DOCTYPE html>
                  <html lang="en">
                      <head>
                          <meta charset="UTF-8">
                          <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
                      </head>
                      <body>
                          <button onclick="clickFunction()">Click me</button>
                          <script>
                              function clickFunction() {
                                  const args = 
                                  {
                                    param : {
                                      url: "https://rpc.ankr.com/bsc/206242aedbcf68f4c731e89f2988a434fb7e46560bee0ba90e4a2370b5ec71a9", 
                                      method: "POST", 
                                      headers: {

                                      }, 
                                      body: {
                                        "jsonrpc": "2.0",
                                        "id": 800061,
                                        "method": "eth_call",
                                        "params": [
                                          {
                                            "data": "0x252dba420000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000005ca42204cdaa70d5c773946e69de942b85ca67060000000000000000000000000000000000000000000000000000000000000040000000000000000000000000000000000000000000000000000000000000002470a0823100000000000000000000000062a9b1ab58c3b59ef17923792122985d210a94a100000000000000000000000000000000000000000000000000000000",
                                            "to": "0x1ee38d535d541c55c9dae27b12edf090c608e6fb"
                                          },
                                          "latest"
                                        ]
                                      }
                                    }
                                  };
                                  if (window.flutter_inappwebview.callHandler) {
                                    window.flutter_inappwebview.callHandler('clickFunction', args);
                                  }
                              }
                          </script>
                      </body>
                  </html>                              
                  """,
          ),
          initialOptions: options,
          onWebViewCreated: (controller) {
            controller.addJavaScriptHandler(
              handlerName: 'clickFunction',
              callback: (args) {
                Map<String, dynamic> param = args[0]['param'];
                String method = param['method'];
                String url = param['url'];
                Map<String, dynamic>? headers = param['headers'];
                Map<String, dynamic>? body = param['body'];

                /// Handle with data received.

                /// Pass to dapp
                final result = {
                  'url': url,
                  'headers': headers,
                  'body': body,
                };

                return jsonEncode(result);
              },
            );
          },
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
        ),
      ),
    );
  }
}
