import 'dart:io';
import 'dart:typed_data';

import 'package:eth_sig_util/util/utils.dart';
import 'package:flutter/material.dart';
import 'package:web3_provider/web3_provider.dart';
import 'package:web3dart/json_rpc.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';

import 'js_bridge_bean.dart';
import 'widget/payment_sheet_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var apiUrl = "https://bsc-dataseed.binance.org/"; //Replace with your API
  var httpClient = Client();
  String walletAddress = '0x81D1aB023A46Fb4d2572533278b4131192cC5d45';
  final String prvKey =
      '0a8a8b091ae22bef656b3910b1541321a95fd62b6ea3ef4a8cc1589abd4f0d2a';
  late Web3Client ethClient;

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

  _signTransaction({
    required BridgeParams bridge,
    required int chainId,
    required VoidCallback cancel,
    required Function(String idHash) success,
  }) async {
    final credentials = EthPrivateKey.fromHex(prvKey);
    final sender = EthereumAddress.fromHex(bridge.from ?? '');
    final signto = EthereumAddress.fromHex(bridge.to ?? '');
    final input = hexToBytes(bridge.data ?? '');
    String? price = (bridge.gasPrice == null)
        ? (await ethClient.getGasPrice()).toString()
        : bridge.gasPrice;
    int? maxGas;
    try {
      maxGas = (bridge.gas ??
          await ethClient.estimateGas(
            sender: sender,
            to: signto,
            data: input,
          )) as int?;
    } catch (e) {
      RPCError err = e as RPCError;
      cancel.call();
      return;
    }
    String fee = FormatterBalance.configFeeValue(
        beanValue: maxGas.toString(), offsetValue: price.toString());
    _showModalConfirm(
        from: walletAddress,
        to: bridge.to ?? '',
        value: bridge.value ?? BigInt.zero,
        fee: fee,
        confirm: () async {
          try {
            String result = await ethClient.sendTransaction(
              credentials,
              Transaction(
                  to: signto,
                  value: EtherAmount.inWei(bridge.value ?? BigInt.zero),
                  gasPrice: null,
                  maxGas: maxGas,
                  data: input),
              chainId: chainId,
              fetchChainIdFromNetworkId: false,
            );
            success.call(result);
          } catch (e) {
            if (e.toString().contains('-32000')) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("gasLow"),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(e.toString()),
              ));
            }
          }
        },
        cancel: () {
          cancel.call();
        });
  }

  _showModalConfirm({
    required String from,
    required String to,
    required BigInt value,
    required String fee,
    required VoidCallback confirm,
    required VoidCallback cancel,
  }) {
    showModalBottomSheet(
        context: context,
        elevation: 0,
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (_) {
          return PaymentSheet(
            datas: PaymentSheet.getTransStyleList(
              from: from,
              to: to,
              remark: '',
              fee: "$fee BNB",
            ),
            amount: "${value.tokenString(18)} BNB",
            nextAction: () async {
              confirm.call();
            },
            cancelAction: () {
              cancel.call();
            },
          );
        });
  }

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(apiUrl, httpClient);
  }

  String customFunctionInject({
    required int chainId,
    required String rpcUrl,
    required String walletAddress,
    bool? isDebug = true,
  }) {
    return """
         {
            ethereum:{
              chainId: $chainId,
              rpcUrl: "$rpcUrl",
              address: "$walletAddress",
              isDebug: $isDebug  
            }
         }
        """;
  }

  @override
  Widget build(BuildContext context) {
    int chainId = 56;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              walletAddress = '0x8F0c3C6C466d2801F6D88002948a2d845f56B129';
              setState(() {});
            },
            icon: const Icon(Icons.add),
          )
        ],
        title: Text(widget.title),
      ),
      body: InAppWebViewEIP1193(
        // use custom provider
        // customPathProvider: 'assets/custom.provider.js',
        // customWalletName: 'posiwallet',
        // customConfigFunction: customFunctionInject(
        //   chainId: chainId,
        //   rpcUrl: 'https://bsc-dataseed.binance.org/',
        //   walletAddress: walletAddress,
        // ),
        // use default provider
        chainId: chainId,
        rpcUrl: 'https://bsc-dataseed.binance.org/',
        walletAddress: walletAddress,
        signCallback: (params, eip1193, controller) {
          final id = params["id"];
          switch (eip1193) {
            case EIP1193.requestAccounts:
              controller?.setAddress(walletAddress, id);
              print('requestAccounts');
              break;
            case EIP1193.signTransaction:
              Map<String, dynamic> object = params["object"];
              BridgeParams bridge = BridgeParams.fromJson(object);
              _signTransaction(
                  bridge: bridge,
                  chainId: chainId,
                  cancel: () {
                    controller?.cancel(id);
                  },
                  success: (idHash) {
                    controller?.sendResult(idHash, id);
                  });
              print('signTransaction');
              break;
            case EIP1193.signMessage:
            case EIP1193.signPersonalMessage:
              Map<String, dynamic> object = params["object"];
              String data = object["data"];
              _showModalConfirm(
                  from: walletAddress,
                  to: '',
                  value: BigInt.zero,
                  fee: '0',
                  confirm: () async {
                    final credentials = EthPrivateKey.fromHex(prvKey);
                    Uint8List message =
                        await credentials.signPersonalMessage(hexToBytes(data));
                    String result = bytesToHex(message, include0x: true);
                    controller?.sendResult(result, id);
                  },
                  cancel: () {
                    controller?.cancel(id);
                  });
              break;
            case EIP1193.signTypedMessage:
              Map<String, dynamic> object = params["object"];
              String raw = object["raw"];
              _showModalConfirm(
                  from: walletAddress,
                  to: '',
                  value: BigInt.zero,
                  fee: '0',
                  confirm: () async {
                    final credentials = EthPrivateKey.fromHex(prvKey);
                    Uint8List message = await credentials.sign(hexToBytes(raw));
                    String result = bytesToHex(message, include0x: true);
                    controller?.sendResult(result, id);
                  },
                  cancel: () {
                    controller?.cancel(id);
                  });
              break;
            case EIP1193.addEthereumChain:
              print('addEthereumChain');
              break;
          }
        },
        initialUrlRequest: URLRequest(
          url: Uri.parse(
            'https://webapp-qc.nonprodposi.com/bonds/p2p',
          ),
        ),
      ),
    );
  }
}
