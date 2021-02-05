import 'package:chat_app/Controllers/firebaseController.dart';
import 'package:chat_app/Widgets/commonButton.dart';
import 'package:chat_app/Widgets/commonTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneAuthenticationPage extends StatefulWidget {
  final Map formData;
  PhoneAuthenticationPage({this.formData});
  @override
  State<StatefulWidget> createState() => _PhoneAuthenticationPageState();
}

class _PhoneAuthenticationPageState extends State<PhoneAuthenticationPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseController>(context, listen: false).isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<FirebaseController>(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.1),
              CommonTextFormField.textFormField(
                  hintText: 'Code',
                  prefixIconData: Icons.person,
                  onSaved: (String value) {
                    // _formData['userName'] = value;
                    authProvider.smsOTP = value;
                  },
                  // ignore: missing_return
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'This field is required.';
                    }
                  },
                  onChanged: (String value) {
                    authProvider.smsOTP = value;
                  }),
              SizedBox(height: size.height * 0.02),
              authProvider.authMsg != ''
                  ? Text(
                      authProvider.authMsg,
                      style: TextStyle(color: Colors.red),
                    )
                  : Container(),
              SizedBox(height: size.height * 0.02),
              CommonButton.signButton(
                  onPressed: () {
                    setState(() {
                      authProvider.formData = widget.formData;
                      authProvider.signIn(context);
                    });
                  },
                  text: 'Verify Code',
                  height: size.height * 0.075,
                  minWidth: size.width),
            ],
          ),
        ),
      ),
    );
  }
}
