import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _formKeyReset = GlobalKey<FormState>();
  String email;
  String password;
  bool _isLoading = false;
  bool _obscureText = true;
  String _errorMessage;
  String emailReset;
  bool isLogin = true;
  String fullName;
  File avatarImageFile;
  String photoUrl;
  String userId;
  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.blue,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.red,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }

  //validator for email
  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  //validator for password
  String validatePassword(String value) {
    if (value.length < 8)
      return 'Password must be 8 character long';
    else
      return null;
  }

  //validator for name
  String validateName(String value) {
    if (value.length < 6)
      return 'Name too short';
    else
      return null;
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image != null) {
        avatarImageFile = image;
      }
    });
  }

  takePicture() async {
    print('Picker is called');
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
//    File img = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      avatarImageFile = image;
      setState(() {});
    }
  }

  void _choosePictureOption(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Choose any option",
            style: GoogleFonts.firaCode(),
          ),
          content: Text(
            "You can choose image from gallery or take picture from camera",
            style: GoogleFonts.firaCode(),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: Icon(
                  Icons.camera_alt,
                  color: Colors.orange,
                  size: 30,
                ),
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  takePicture();
                  Navigator.of(context).pop();
                },
              ),
            ),
            IconButton(
                icon: Icon(
                  FontAwesomeIcons.cloudUploadAlt,
                  color: Colors.orange,
                  size: 30,
                ),
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  getImage();
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }

  // Check if form is valid before perform login
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<String> signIn(String email, String password) async {
    print('===========>' + email);
    FirebaseUser user = (await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password))
        .user;

    return user.uid;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      setState(() {
        _errorMessage = "";
        _isLoading = true;
      });
      String userId = "";

      try {
        if (isLogin) {
          userId = await signIn(email, password);
          if (userId != null) {
            print('Signed in: $userId');
            Fluttertoast.showToast(
                msg: "LoginSuccess",
                toastLength: Toast.LENGTH_SHORT,
                backgroundColor: Colors.blue,
                textColor: Colors.white);
          } else {
            Navigator.of(this.context).pushReplacementNamed('/AuthScreen');
          }
        } else {
          FirebaseUser user = (await FirebaseAuth.instance
                  .createUserWithEmailAndPassword(
                      email: email, password: password))
              .user;
          String fileName = basename(avatarImageFile.path);
          StorageReference firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('userProfile')
              .child(fileName);
          StorageUploadTask uploadTask =
              firebaseStorageRef.putFile(avatarImageFile);
          var downUrl =
              await (await uploadTask.onComplete).ref.getDownloadURL();
          var url = downUrl.toString();
          setState(() {
            print("Post Picture uploaded");
            photoUrl = url;
          });
          print("Download URL :$url");
          await Firestore.instance
              .collection('Users')
              .document(user.uid)
              .setData({
            'email': email,
            'fullName': fullName,
            'photoUrl': photoUrl,
            'id': user.uid,
            'createdAt': DateTime.now(),
          });
          await FirebaseAuth.instance.signOut();
          Fluttertoast.showToast(
              msg: "Sign Up Success",
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.blue,
              textColor: Colors.white);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;

          _errorMessage = e.message;
          Fluttertoast.showToast(
              msg: _errorMessage,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        });
      }
      setState(() {
        isLogin = !isLogin;
        _isLoading = false;
      });
      try {
        if (userId.length > 0 && userId != null) {
          Navigator.of(
            this.context,
          ).pushReplacementNamed('/UserMainScreen');
        } else
          Navigator.of(this.context).pushReplacementNamed('/AuthScreen');
      } catch (e) {
        print(e);
      }
    }
  }

//google sign in
  Future<Null> handleSignIn() async {
    this.setState(() {
      _isLoading = true;
    });

    GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser firebaseUser =
        (await FirebaseAuth.instance.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        Firestore.instance
            .collection('Users')
            .document(firebaseUser.uid)
            .setData({
          'email': firebaseUser.email,
          'fullName': firebaseUser.displayName,
          'photoUrl': firebaseUser.photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now(),
        });
      }
      Fluttertoast.showToast(msg: "Sign in success");
      this.setState(() {
        _isLoading = false;
      });

      Navigator.of(this.context).pushReplacementNamed('/UserMainScreen');
    } else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        _isLoading = false;
      });
    }
  }

//for password reset
  bool _validateAndSaveReset() {
    final form = _formKeyReset.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmitReset() async {
    if (_validateAndSaveReset()) {
      setState(() {
        _errorMessage = "";
      });

      try {
        sendPasswordResetMail(emailReset);

        setState(
          () {
            Fluttertoast.showToast(
                msg:
                    "Email sent to,$emailReset follow the link to reset your password",
                toastLength: Toast.LENGTH_LONG,
                backgroundColor: Colors.grey,
                textColor: Colors.white);

            Navigator.of(this.context).pushReplacementNamed('/LoginScreen');
          },
        );
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          Fluttertoast.showToast(
              msg: _errorMessage,
              toastLength: Toast.LENGTH_LONG,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        });
      }
    }
  }

//send password reset mail
  Future<void> sendPasswordResetMail(String emailReset) async {
    print('===========>' + emailReset);
    await FirebaseAuth.instance.sendPasswordResetEmail(email: emailReset);

    return null;
  }

//for password forget dialogue
  void _forgetPassword() {
    showDialog(
        context: this.context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20),
              width: MediaQuery.of(context).size.width / 1.2,
              height: 200,
              padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
              child: Form(
                key: _formKeyReset,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "*Please enter your mail where the password reset email will be sent !",
                        style: GoogleFonts.firaCode(),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.red, width: 10.0),
                          ),
                          prefixIcon: Icon(
                            Icons.email,
                            color: Colors.grey,
                          ),
                          hintText: 'Email',
                          hintStyle: GoogleFonts.firaCode()),
                      validator: validateEmail,
                      onSaved: (value) => emailReset = value.trim(),
                    ),
                    InkWell(
                      onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        _validateAndSubmitReset();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1.2,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFf45d27), Color(0xFFf5851f)],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50))),
                        child: Center(
                          child: Text(
                            'Send Password reset Email'.toUpperCase(),
                            style: GoogleFonts.firaCode(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: onBackPress,
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Stack(
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          (!isLogin)
                              ? Container(
                                  child: Center(
                                    child: Stack(
                                      children: <Widget>[
                                        (avatarImageFile == null)
                                            ? (photoUrl != null
                                                ? Material(
                                                    child:
                                                        Image.network(photoUrl),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20.0)),
                                                    clipBehavior: Clip.hardEdge,
                                                  )
                                                : Icon(
                                                    Icons.account_circle,
                                                    size: 90.0,
                                                    color: Colors.black38,
                                                  ))
                                            : Material(
                                                child: Image.file(
                                                  avatarImageFile,
                                                  width: 90.0,
                                                  height: 90.0,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(45.0)),
                                                clipBehavior: Clip.hardEdge,
                                              ),
                                        Positioned(
                                          left: 40,
                                          bottom: 0,
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.camera_alt,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              _choosePictureOption(context);
                                            },
                                            highlightColor: Color(0xffaeaeae),
                                            iconSize: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  width: double.infinity,
                                  margin: EdgeInsets.all(20.0),
                                )
                              : Container(
                                  padding: EdgeInsets.only(top: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "Lets Read Some Books",
                                          style: GoogleFonts.firaCode(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Image.asset(
                                        'lib/Assets/book.gif',
                                        height: 100,
                                        fit: BoxFit.cover,
                                      ),
                                    ],
                                  ),
                                ),
                          (!isLogin)
                              ? Container(
                                  margin: EdgeInsets.only(top: 40),
                                  width:
                                      MediaQuery.of(context).size.width / 1.2,
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.black, width: 2.0),
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 10.0),
                                      ),
                                      prefixIcon: Icon(
                                        Icons.person,
                                        color: Colors.grey,
                                      ),
                                      labelText: 'Full Name',
                                      hintText: 'Full Name',
                                      labelStyle: GoogleFonts.firaCode(),
                                      hintStyle: GoogleFonts.firaCode(),
                                    ),
                                    validator: validateName,
                                    onSaved: (value) => fullName = value.trim(),
                                  ),
                                )
                              : Container(),
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.red, width: 10.0),
                                ),
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: Colors.grey,
                                ),
                                labelText: 'Email',
                                hintText: 'Email',
                                labelStyle: GoogleFonts.firaCode(),
                                hintStyle: GoogleFonts.firaCode(),
                              ),
                              validator: validateEmail,
                              onSaved: (value) => email = value.trim(),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: TextFormField(
                              decoration: InputDecoration(
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 2.0),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.red, width: 10.0),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: Colors.grey,
                                  ),
                                  suffixIcon: IconButton(
                                      icon: FaIcon(
                                        _obscureText
                                            ? FontAwesomeIcons.eyeSlash
                                            : FontAwesomeIcons.eye,
                                        color: Colors.deepOrange,
                                      ),
                                      onPressed: _toggle),
                                  labelStyle: GoogleFonts.firaCode(),
                                  hintStyle: GoogleFonts.firaCode(),
                                  hintText: 'Password',
                                  labelText: 'Password'),
                              obscureText: _obscureText,
                              validator: validatePassword,
                              onSaved: (value) => password = value.trim(),
                            ),
                          ),
                          (isLogin)
                              ? Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, right: 50),
                                    child: GestureDetector(
                                      onTap: () {
                                        _forgetPassword();
                                      },
                                      child: Text(
                                        'Forgot Password ?',
                                        style: GoogleFonts.firaCode(
                                            color: Colors.grey,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              top: 20,
                              bottom: 20,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (!isLogin) {
                                  if (avatarImageFile == null &&
                                      fullName == null &&
                                      email == null &&
                                      password == null) {
                                    Fluttertoast.showToast(
                                        msg: "Please fill all the details");
                                  } else {
                                    _validateAndSubmit();
                                  }
                                } else {
                                  _validateAndSubmit();
                                }

                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                              },
                              child: Container(
                                height: 45,
                                width: MediaQuery.of(context).size.width / 1.2,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFf45d27),
                                        Color(0xFFf5851f)
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(50))),
                                child: Center(
                                    child: Text((isLogin) ? 'Login' : 'Sign Up',
                                        style: GoogleFonts.firaCode(
                                            fontSize: 20.0,
                                            color: Colors.white))),
                              ),
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              alignment: Alignment.bottomCenter,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    (isLogin)
                                        ? 'Don\'t have an account ?'
                                        : 'Already have an account ?',
                                    style: GoogleFonts.firaCode(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        isLogin = !isLogin;
                                        print(isLogin);
                                      });
                                    },
                                    child: Text(
                                      (isLogin) ? 'Register' : 'Login',
                                      style: GoogleFonts.firaCode(
                                          color: Color(0xfff79c4f),
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              )),
                          InkWell(
                            onTap: () {
                              handleSignIn();
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'lib/Assets/google.png',
                                    height: 50,
                                  ),
                                  Text(
                                    "Sign In With Google",
                                    style: GoogleFonts.firaCode(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _isLoading
                    ? Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black.withOpacity(0.5),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            backgroundColor: Colors.redAccent,
                          ),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
