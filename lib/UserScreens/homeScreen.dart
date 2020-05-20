import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_samples/UserScreens/readPdf.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userId;

  bool isFavourite = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((firebaseUser) {
      if (firebaseUser != null) {
        setState(() {
          userId = firebaseUser.uid;
          print("Logged in user ID:- " + userId);
        });
      }
    });
  }

  Future<Null> handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();

      await GoogleSignIn().signOut();
      Navigator.of(this.context).pushReplacementNamed('/AuthScreen');
    } catch (e) {
      print(e.message);
    }
  }

  void _exitAlert() {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)), //this right here
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                    colors: [Color(0xffffff7e5f), Color(0xfffffeb47b)])),
            height: 100,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: Text("Are You Sure ?",
                      style: GoogleFonts.firaCode(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.timesCircle,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          "No".toUpperCase(),
                          style: GoogleFonts.firaCode(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: FaIcon(
                            FontAwesomeIcons.signOutAlt,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            handleSignOut();
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          "Yes".toUpperCase(),
                          style: GoogleFonts.firaCode(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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

  Widget _buildListVaccination(
      BuildContext context, DocumentSnapshot document, String collectionName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: <Color>[
              Color(0xfffffDBD4B4),
              Color(0xffffDAE2F8),
            ],
          ),
          border: Border.all(width: .5),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            isThreeLine: true,
            leading: FaIcon(FontAwesomeIcons.book),
            trailing: StreamBuilder(
                stream: Firestore.instance
                    .collection('Books')
                    .document(document.documentID)
                    .collection('favourite')
                    .document(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return FaIcon(
                      FontAwesomeIcons.heart,
                      color: Colors.blue,
                    );
                  } else {
                    return IconButton(
                      icon: snapshot.data.data == null
                          ? FaIcon(
                              FontAwesomeIcons.heart,
                              color: Colors.red,
                            )
                          : FaIcon(
                              snapshot.data["favourite"]
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              color: Colors.red,
                              size: 30,
                            ),
                      onPressed: () {
                        Firestore.instance
                            .collection('Books')
                            .document(document.documentID)
                            .collection('favourite')
                            .document(userId)
                            .setData({
                          "favourite": snapshot.data.data == null
                              ? true
                              : !snapshot.data["favourite"]
                        });
                      },
                    );
                  }
                }),
            title: Text(
              document['bookName'],
              style: GoogleFonts.firaCode(
                  fontSize: 20, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              document['aboutBook'],
              style: GoogleFonts.firaCode(
                  fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          ButtonBar(
            children: <Widget>[
              Text(
                'Tag:- ' + document['category'],
                style: GoogleFonts.firaCode(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ReadPdf(
                                url: document['pdfUrl'],
                              )));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Read Now",
                    style: GoogleFonts.firaCode(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xffff2193b0), Color(0xffff6dd5ed)])),
        ),
        actions: <Widget>[
          Center(
              child: Text(
            "Log Out".toUpperCase(),
            style: GoogleFonts.lato(fontSize: 15, fontWeight: FontWeight.bold),
          )),
          IconButton(
              icon: Icon(Icons.exit_to_app), onPressed: () => _exitAlert()),
        ],
      ),
      body: WillPopScope(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xffffCC95C0),
                Color(0xfffffDBD4B4),
                Color(0xfffff7AA1D2)
              ],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                    stream: Firestore.instance.collection('Books').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return LinearProgressIndicator(
                          backgroundColor: Colors.black12,
                        );
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) => _buildListVaccination(
                            context, snapshot.data.documents[index], 'Books'),
                      );
                    }),
              ),
            ],
          ),
        ),
        onWillPop: () => onBackPress(),
      ),
    );
  }
}
