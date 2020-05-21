import 'dart:io';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String userId;
  final nameController = TextEditingController();
  String photoUrl;
  File avatarImageFile;
  bool isLoading = false;
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

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
      });
    }
    uploadFile();
  }

  takePicture() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);

    if (image != null) {
      avatarImageFile = image;
      setState(() {});
    }
    uploadFile();
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
                  getImage();
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }

//delete previous pic
  Future deleteImage() async {
    await FirebaseStorage.instance
        .getReferenceFromUrl(photoUrl)
        .then((value) => value.delete())
        .catchError((onError) {
      print(onError);
    });
  }

  Future uploadFile() async {
    setState(() {
      isLoading = true;
    });
    String fileName = basename(avatarImageFile.path);
    StorageReference reference =
        FirebaseStorage.instance.ref().child('userProfile').child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          deleteImage();
          photoUrl = downloadUrl;

          Firestore.instance.collection('Users').document(userId).updateData({
            'photoUrl': photoUrl,
          }).then((data) async {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: "Upload success");
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.toString());
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
          Fluttertoast.showToast(msg: 'This file is not an image');
        });
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(msg: 'This file is not an image');
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: err.toString());
    });
  }

  Widget _buildProfileCard(BuildContext context, snapshot) {
    nameController.text = snapshot.data.data['fullName'];
    photoUrl = snapshot.data.data['photoUrl'];
    return Container(
      margin: EdgeInsets.only(top: 100.0, left: 20, right: 20.0),
      height: MediaQuery.of(context).size.height / 6,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: <Color>[
            Color(0xfffff7F7FD5),
            Color(0xffff86A8E7),
            Color(0xfffff91EAE4),
          ],
        ),
        border: Border.all(width: 1, color: Colors.black.withOpacity(.5)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: (snapshot.data.data['photoUrl'] != null)
                  ? Stack(
                      children: [
                        (avatarImageFile == null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CachedNetworkImage(
                                  imageUrl: snapshot.data.data['photoUrl'],
                                  fit: BoxFit.cover,
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  placeholder: (context, url) => Container(
                                    height: 90,
                                    width: 90,
                                    child: CircularProgressIndicator(
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(avatarImageFile),
                              ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: IconButton(
                                icon: FaIcon(
                                  FontAwesomeIcons.cameraRetro,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  _choosePictureOption(context);
                                }))
                      ],
                    )
                  : Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
            ),
          ),
          Expanded(
            flex: 0,
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: (snapshot.data.data['fullName'] != null)
                        ? (Text(
                            snapshot.data.data['fullName'],
                            style: GoogleFonts.firaCode(
                                fontSize: 18.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w600),
                          ))
                        : Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                  ),
                  Container(
                    child: (snapshot.data.data['email'] != null)
                        ? (Text(snapshot.data.data['email'],
                            style: GoogleFonts.firaCode(
                                fontSize: 14.0,
                                color: Colors.black,
                                fontWeight: FontWeight.w600)))
                        : Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                                strokeWidth: 1,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black12,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height / 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                Color(0xffff2193b0),
                                Color(0xffff6dd5ed),
                                Color(0xfffffDBD4B4),
                                Color(0xfffff7AA1D2)
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Column(
                            children: [
                              StreamBuilder(
                                stream: Firestore.instance
                                    .collection('Users')
                                    .document(userId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Container(
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black12,
                                      ),
                                    );
                                  if (snapshot.data.data == null)
                                    return Container(
                                      alignment: Alignment.center,
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.black12,
                                      ),
                                    );
                                  return _buildProfileCard(context, snapshot);
                                },
                              ),
                              Container(
                                height: 70,
                                margin: EdgeInsets.all(20),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(width: 1)),
                                child: Center(
                                  child: ListTile(
                                    isThreeLine: true,
                                    leading: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                    ),
                                    trailing: Icon(Icons.chevron_right),
                                    title: Text("test"),
                                    subtitle: Text("text"),
                                  ),
                                ),
                              ),
                              ListTile(
                                isThreeLine: true,
                                leading: Icon(Icons.favorite),
                                trailing: Icon(Icons.chevron_right),
                                title: Text("test"),
                                subtitle: Text("text"),
                              ),
                              ListTile(
                                isThreeLine: true,
                                leading: Icon(Icons.favorite),
                                trailing: Icon(Icons.chevron_right),
                                title: Text("test"),
                                subtitle: Text("text"),
                              ),
                              ListTile(
                                isThreeLine: true,
                                leading: Icon(Icons.favorite),
                                trailing: Icon(Icons.chevron_right),
                                title: Text("test"),
                                subtitle: Text("text"),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              child: isLoading
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      child: Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xfff5a623))),
                      ),
                      color: Colors.black.withOpacity(0.5),
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
