import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 191, 186, 203),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QK WASH',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Expanded(
                    child: Center(
                      child: Text(
                        'Terms of service\nand Privacy policy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),

                  // Right: BACK button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                      minimumSize: const Size(70, 32),
                    ),
                    child: const Text(
                      'BACK',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            SizedBox(height: 70),
            Text(
              'QKWash Laundry App Terms and Conditions of Use Your',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'Right to Cancel At QKWash Ltd, we want you to be fully',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'satisfied every time you top up your account using the',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'QKWash Laundry App. You have the right to cancel your',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'purchase of app credit. However,we regret that we cannot',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'accept cancellations of top-up purchases if any or all of',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'the credit has been used.',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 30),
            Text(
              'To cancel a credit made through the QKWash',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'Laundry App, please contact QKWash Services Ltd within',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'seven working days of receiving the top-up confirmation',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'via email. To facilitate a quick refund process, please',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'provide the reason for your refund request, along with',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'your top-up purchase receipt. Send these details to:',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              'QKWash Services Ltd North Paravur, Ernakulam, Kerala',
              style: TextStyle(fontSize: 9, color: Colors.black, height: 1.5),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
