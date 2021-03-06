import 'package:chat_app/Controllers/firebaseController.dart';
import 'package:chat_app/Widgets/commonButton.dart';
import 'package:chat_app/Widgets/commonTextFormField.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  Map _formData = {};

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
      body: Form(
        key: _formStateKey,
        child: Container(
          height: size.height,
          width: size.width,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Hero(
                  tag: '${size.height}_ABC',
                  child: Image.asset('images/logo.png',
                      fit: BoxFit.fill,
                      height: size.height * 0.25,
                      width: size.height * 0.25),
                ),
                SizedBox(height: size.height * 0.1),
                CommonTextFormField.textFormField(
                    hintText: 'User Name',
                    prefixIconData: Icons.person,
                    textInputType: TextInputType.text,
                    onSaved: (String value) {
                      _formData['userName'] = value;
                    },
                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'This field is required.';
                      }
                    }),
                SizedBox(height: size.height * 0.02),
                CommonTextFormField.textFormField(
                    hintText: 'Phone Number',
                    prefixIconData: Icons.phone,
                    textInputType: TextInputType.numberWithOptions(),
                    onSaved: (String value) {
                      if (value.startsWith('+2'))
                        _formData['phoneNumber'] = value;
                      else
                        _formData['phoneNumber'] = '+2' + value;
                    },
                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'This field is required.';
                      }
                    }),
                SizedBox(height: size.height * 0.02),
                CommonTextFormField.textFormField(
                    hintText: 'Email',
                    prefixIconData: Icons.email,
                    textInputType: TextInputType.emailAddress,
                    onSaved: (String value) {
                      _formData['email'] = value;
                    },
                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'This field is required.';
                      }
                    }),
                SizedBox(height: size.height * 0.02),
                CommonTextFormField.textFormField(
                    hintText: 'Password',
                    prefixIconData: Icons.lock,
                    onSaved: (String value) {
                      _formData['password'] = value;
                    },
                    // ignore: missing_return
                    validator: (String value) {
                      if (value.isEmpty) {
                        return 'This field is required.';
                      }
                    }),
                SizedBox(height: size.height * 0.02),
                authProvider.getIsLoading
                    ? Center(child: CircularProgressIndicator())
                    : CommonButton.signButton(
                        onPressed: () {
                          if (_formStateKey.currentState.validate()) {
                            _formStateKey.currentState.save();
                            authProvider.verifyPhone(
                                context: context,
                                phoneNumber: _formData['phoneNumber'],
                                formData: _formData);
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => PhoneAuthenticationPage(
                            //             formData: _formData)));
                          }
                        },
                        text: 'Register',
                        height: size.height * 0.075,
                        minWidth: size.width),
                SizedBox(height: size.height * 0.02),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FlatButton(
                      onPressed: () {},
                      child: Text('Have an account? LogIn Here',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
