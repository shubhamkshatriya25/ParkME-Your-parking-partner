import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constant.dart';

class ChangePassword extends StatefulWidget {
  final User user;
  const ChangePassword({Key key, this.user}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showNewPassword = false;
  bool _showRepeatPassword = false;
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _repeatPasswordController = TextEditingController();
  Widget build(BuildContext context) {
    var _formKey = GlobalKey<FormState>();
    bool checkCurrentPasswordValid = true;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kprimaryColor,
        title: Text('Update Password'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                SizedBox(height: 20,),
                TextFormField(
                  controller: _currentPasswordController,
                  validator: (value){
                    return checkCurrentPasswordValid ? null : "Incorrect password";
                  },
                  decoration: InputDecoration(
                    labelText: "Current Password",
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: kprimaryColor),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: !this._showNewPassword,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        this._showNewPassword ? Icons.visibility_off :Icons.visibility,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        setState(() => this._showNewPassword = !this._showNewPassword);
                      },
                    ),
                    labelText: "New Password",
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: kprimaryColor),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                SizedBox(height: 20,),
                TextFormField(
                  controller: _repeatPasswordController,
                  validator: (value) {
                    return _newPasswordController.text.trim() == value.trim()
                        ? null
                        : "Your password doesn't match";
                  },
                  obscureText: !this._showRepeatPassword,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                        this._showRepeatPassword ? Icons.visibility_off :Icons.visibility,
                        color: Colors.grey.shade400,
                      ),
                      onPressed: () {
                        setState(() => this._showRepeatPassword = !this._showRepeatPassword);
                      },
                    ),
                    labelText: "Repeat New Password",
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide(color: kprimaryColor),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  height: 50,
                  child: RaisedButton(
                    onPressed: () async {
                      checkCurrentPasswordValid = await validatePassword(_currentPasswordController.text.trim());
                      if (_formKey.currentState.validate()) {
                          widget.user.updatePassword(_newPasswordController.text.trim());
                          Navigator.pop(context);
                      }
                    },
                    padding: EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        color: kprimaryColor,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints(
                            minHeight: 50, maxWidth: double.infinity),
                        child: Text(
                          "SAVE",
                          style:
                          TextStyle(color: kBtnTextColor, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> validatePassword(String password) async {
    var firebaseUser = await _auth.currentUser;

    var authCredentials = EmailAuthProvider.getCredential(
        email: firebaseUser.email, password: password);
    try {
      var authResult = await firebaseUser
          .reauthenticateWithCredential(authCredentials);
      return authResult.user != null;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
