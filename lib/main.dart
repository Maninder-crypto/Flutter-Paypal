import 'dart:async';

import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

import 'package:paypal_payment/paypal_services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String token;
  StreamSubscription<String> _onUrlChanged;
  var orderJson;

  String textValue = 'get token first';

  String returnUrl = "https://mydomainname.com/success";
  String cancelUrl = "https://mydomainname.com/cancel";

  final flutterWebViewPlugin = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //-----onUrlChanged Listener is use to update EditTextfield value and set value of currentURL----
    _onUrlChanged = flutterWebViewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('success')) {
        print('webview should close');
        flutterWebViewPlugin.close();
        setState(() {
          textValue = 'Payment Aproved now Capture the payment';
        });
      } else if (url.contains('cancel')) {
        print('Payment faild');
        flutterWebViewPlugin.close();
        setState(() {
          textValue = 'payment faild try again';
        });
      }
      if (mounted) {
        setState(() {
          print('url $url');
        });
      }
    });
  }

  //------order json------

  getJsonBody() {
    var orderBody = {
      "intent": "CAPTURE",
      "purchase_units": [
        {
          "reference_id": "PUHF",
          "amount": {"currency_code": "USD", "value": "50.00"}
        }
      ],
      "application_context": {"return_url": returnUrl, "cancel_url": cancelUrl}
    };
    String jsonObj = json.encode(orderBody);
    return jsonObj;
  }

  void webView(String selectedUrl) {
    double headerHeight = 78.0;
    double footerHeight = 60.0;
    flutterWebViewPlugin.launch(
      selectedUrl,
      rect: Rect.fromLTWH(0.0, headerHeight, MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height - (headerHeight + footerHeight)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(textValue),
            SizedBox(height: 20.0),
            RaisedButton(
              child: Text('Get Token'),
              onPressed: () {
                PaypalServices.getToken().then((data) {
                  token = data['access_token'];
                  setState(() {
                    textValue = 'Token genrated now create order';
                  });
                  //print('token ${data['access_token']}');
                  //print('token ${data}');
                });
              },
            ),
            SizedBox(
              height: 30.0,
            ),
            RaisedButton(
              child: Text('Create Order'),
              onPressed: () {
                //if (token != null) {
                PaypalServices.createOrder(token, getJsonBody()).then((data) {
                  orderJson = data;
                  webView(orderJson['links'][1]['href']);
                });
                // } else {
                // print('token is null');
                //}
              },
            ),
            RaisedButton(
              child: Text('Capture'),
              onPressed: () {
                PaypalServices.capture(token, orderJson['links'][3]['href'])
                    .then((data) {
                       setState(() {
                    textValue = 'Payment done!';
                  });
                  print('capture result: $data');
                });
              },
            )
          ],
        ),
      ),
    );
  }

  //-------------------------------------

}
