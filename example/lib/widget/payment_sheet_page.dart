import 'package:flutter/material.dart';

import '../utils.dart';
import 'next_button.dart';

class PaymentSheetText {
  String? title;
  TextStyle? titleStyle;
  String? content;
  TextStyle? contentStyle;

  PaymentSheetText({
    this.title,
    this.content,
    this.contentStyle,
    this.titleStyle,
  });
}

class PaymentSheet extends StatefulWidget {
  PaymentSheet(
      {Key? key,
      required this.datas,
      required this.nextAction,
      required this.amount,
      required this.cancelAction})
      : super(key: key);

  final List<PaymentSheetText> datas;
  final VoidCallback nextAction;
  final VoidCallback cancelAction;
  final String amount;

  @override
  _PaymentSheetState createState() => _PaymentSheetState();

  static List<PaymentSheetText> getTransStyleList(
      {String from = "", String to = "", String remark = "", String fee = ""}) {
    List<PaymentSheetText> datas = [
      PaymentSheetText(
        title: "Payment address",
        content: from,
      ),
      PaymentSheetText(
        title: "Receive address",
        content: to,
      ),
      PaymentSheetText(
        title: "Free",
        content: fee,
      ),
      PaymentSheetText(
        title: "Remark",
        content: remark,
      )
    ];
    return datas;
  }
}

class _PaymentSheetState extends State<PaymentSheet> {
  void _next() {
    Navigator.pop(context);
    widget.nextAction();
  }

  void sheetClose() {
    Navigator.pop(context);
    widget.cancelAction();
  }

  Widget _getTitle() {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
          border: Border(
              bottom: BorderSide(
        width: 0.5,
        color: ColorUtils.lineColor,
      ))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 24,
          ),
          Text(
            "Confirm Transfer",
            style: TextStyle(
                color: ColorUtils.fromHex("#FF000000"),
                fontSize: 16,
                fontWeight: FontWeightUtils.semiBold),
          ),
          // CustomPageView.getCloseLeading(() {
          //   sheetClose();
          // }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 420,
      child: Column(
        children: [
          _getTitle(),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: 20,
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 31),
                    alignment: Alignment.center,
                    child: Text(
                      widget.amount,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: ColorUtils.fromHex("#FF000000"),
                        fontSize: 24,
                        fontWeight: FontWeightUtils.semiBold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.datas.length,
                      itemBuilder: (BuildContext context, int index) {
                        PaymentSheetText sheet = widget.datas[index];
                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          constraints: BoxConstraints(
                            minHeight: 45,
                          ),
                          decoration: const BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            width: 0.5,
                            color: ColorUtils.lineColor,
                          ))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 120,
                                child: Text(sheet.title!,
                                    style: TextStyle(
                                      color: ColorUtils.fromHex("#99000000"),
                                      fontSize: 12,
                                    )),
                              ),
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Text(sheet.content!,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        color: ColorUtils.fromHex("#FF000000"),
                                        fontSize: 12,
                                        fontWeight: FontWeightUtils.medium,
                                      )),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  NextButton(
                    onPressed: _next,
                    borderRadius: 12,
                    height: 48,
                    bgc: ColorUtils.blueColor,
                    title: "OK",
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeightUtils.medium,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
