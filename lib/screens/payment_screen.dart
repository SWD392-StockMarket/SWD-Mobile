import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: PayPalPaymentScreen());
  }
}

class PayPalPaymentScreen extends StatefulWidget {
  @override
  _PayPalPaymentScreenState createState() => _PayPalPaymentScreenState();
}

class _PayPalPaymentScreenState extends State<PayPalPaymentScreen> {
  String transactionStatus = "Pending";
  bool isLoading = false; // Added loading state

  void processPayment() {
    setState(() => isLoading = true);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UsePaypal(
          sandboxMode: true,
          clientId: "AahYOJELlYGWzCt1xCPrjcnEVRZCAUujE41La7KnPKdrMRLAjQaUUZJFWrUNbmitnfSnsEosdSOaXMN2",
          secretKey: "ECFvR6mFXWsvvmKnuVYdnynD5_Rzk1Ast1ZIBvgn6hYz_LAVeFEWKqhXxMoh80n5pban0cJDz5mob-7C",
          returnURL: "paypalpayment://return?screen=home", // Specify target screen
          cancelURL: "paypalpayment://cancel?screen=stock", // Specify target screen
          transactions: [
            {
              "amount": {"total": "10.00", "currency": "USD"},
              "description": "Test transaction in sandbox mode.",
              "item_list": {
                "items": [
                  {"name": "Test Item", "quantity": "1", "price": "10.00", "currency": "USD"}
                ]
              },
            }
          ],
          note: "Contact us for any questions",
          onSuccess: (Map params) {
            _handlePaymentResult("Success", targetScreen: "paypal");
            print("Payment Success: $params");
          },
          onError: (error) {
            _handlePaymentResult("Failed", error: error);
            print("Payment Error: $error");
          },
          onCancel: (params) {
            _handlePaymentResult("Cancelled", targetScreen: "stock");
            print("Payment Cancelled: $params");
          },
        ),
      ),
    );
  }

  void _handlePaymentResult(String status, {String? error, String? targetScreen}) {
    if (mounted) {
      setState(() {
        transactionStatus = status;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error != null ? "Payment Failed: $error" : "Payment $status"),
        ),
      );

      // Navigate to the target screen if provided, otherwise just pop
      if (targetScreen != null) {
        Navigator.pushNamed(context, '/$targetScreen'); // Use named route
      } else if (Navigator.canPop(context)) {
        Navigator.pop(context); // Fallback to popping
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PayPal Sandbox Payment")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Transaction Status: $transactionStatus"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: processPayment,
              child: Text("Pay with PayPal"),
            ),
          ],
        ),
      ),
    );
  }
}