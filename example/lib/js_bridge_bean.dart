import 'package:web3_provider/web3_provider.dart';

class BridgeParams {
  int? gas;
  BigInt? value;
  String? from;
  String? to;
  String? data;
  String? gasPrice;

  BridgeParams({this.value, this.to, this.data, this.from, this.gas});

  BridgeParams.fromJson(Map<String, dynamic> json) {
    String? jsonGas = json["gas"];
    gas = jsonGas == null
        ? null
        : int.parse(jsonGas.replaceAll("0x", ""), radix: 16);
    String? jsonPrice = json["gasPrice"];
    gasPrice = jsonPrice == null
        ? null
        : (BigInt.parse(jsonPrice.replaceAll("0x", ""), radix: 16))
            .tokenString(9);
    value = BigInt.tryParse((json['value'] ?? "0").replaceAll("0x", ""),
            radix: 16) ??
        BigInt.zero;
    from = json['from'];
    to = json['to'];
    data = json['data'];
  }
}
