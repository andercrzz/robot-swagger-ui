import 'package:flutter/material.dart';
import 'package:robot/service/widget_support.dart';

class Onboarding extends StatefulWidget {
    const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding Page'),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 40.0), 
        child: Column(
            children: [
                Text('Welcome to the Onboarding Page!',
                    style: AppWidget.HeadlineTextFieldStyle(),
                    textAlign: TextAlign.center),
                SizedBox(height: 20.0),
                Text('This is a simple onboarding page. Tap the button below to continue.',
                    style: AppWidget.SimpleTextFieldStyle(),
                    textAlign: TextAlign.center),
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10.0)),
                        child: Center(
                            child: Text("Get started",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.center,
                    ),
                        )
                )
            ],
        )
      ),
    );
  }
}

