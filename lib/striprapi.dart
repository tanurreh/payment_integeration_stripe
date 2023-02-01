import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:payint/constants.dart';

class StripeAPI {
  static createPaymentIntent(
      String amount, String currency, BuildContext context) async {
    try {
      var response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: {
          "amount": "${amount}00",
          "currency": currency,
          "payment_method_types[]": "card",
        },
        headers: {
          "Authorization": "Bearer ${DocumentationsKeys.testkey}",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );
      print(response.body);
      return jsonDecode(response.body);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
        backgroundColor: Colors.red,
      ));
    }
  }

  static Future<void> makePayment(
      String amount, String currency, BuildContext context) async {
    Map<String, dynamic>? paymentIntentData;

    try {
      paymentIntentData = await createPaymentIntent(amount, currency, context);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData["client_secret"],
          merchantDisplayName: "name",
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Color.fromARGB(255, 85, 148, 87),
              primary: Colors.blue,
              componentBorder: Colors.black,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: Colors.red),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color.fromARGB(255, 231, 235, 30),
                  text: Color.fromARGB(255, 235, 92, 30),
                  border: Color.fromARGB(255, 235, 92, 30),
                ),
              )))
          //customerId: "id",
        ));
        await Stripe.instance.presentPaymentSheet();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("payment is successful"),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      print(e);
      // LocalizedErrorMessage localizedErrorMessage =
      //     e.reactive.toJson()['error'];
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(localizedErrorMessage.message.toString()),
      //   backgroundColor: Colors.red,
      // ));
    }
  }
}
