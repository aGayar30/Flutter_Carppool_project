import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final String price;

  const PaymentPage({required this.price});

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Payment',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF73C2BE),
          ),
        ),
        backgroundColor: Color(0xFF495159),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Price: ${widget.price}',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF73C2BE),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Enter Credit Card Information',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Color(0xFF73C2BE),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Card Number',
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryDateController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Expiry Date (MM/YY)',
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'CVV',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.0),
            ElevatedButton(
              onPressed: () {
                // Handle payment processing logic here
                // You may want to integrate with a payment gateway or service
                // For demonstration purposes, print entered card details
                print('Card Number: ${_cardNumberController.text}');
                print('Expiry Date: ${_expiryDateController.text}');
                print('CVV: ${_cvvController.text}');

                if (_cardNumberController.text.isEmpty || _expiryDateController.text.isEmpty || _cvvController.text.isEmpty){
                  // Show a success message or navigate to the next screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter all your card information'),
                      backgroundColor: Color(0xFF73C2BE),
                    ),
                  );
                  return;
                }
                // Show a success message or navigate to the next screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment Successful!'),
                    backgroundColor: Color(0xFF73C2BE),
                    duration: Duration(
                        seconds: 2),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text('Pay Now'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
                textStyle: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


