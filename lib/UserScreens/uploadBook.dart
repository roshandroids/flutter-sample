import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadBook extends StatefulWidget {
  @override
  _UploadBookState createState() => _UploadBookState();
}

class _UploadBookState extends State<UploadBook> {
  Item selectedCategory;
  String pdfUrl;
  String fileName;
  String userId;
  File pdf;
  bool isLoading = false;
  TextEditingController bookName = TextEditingController();
  TextEditingController aboutBook = TextEditingController();

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

  List<Item> users = <Item>[
    const Item(
        'Romantic',
        FaIcon(
          FontAwesomeIcons.heart,
          color: Colors.red,
        )),
    const Item(
        'Programming',
        FaIcon(
          FontAwesomeIcons.laptopCode,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Research',
        FaIcon(
          FontAwesomeIcons.researchgate,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Airtificial Intelligence',
        FaIcon(
          FontAwesomeIcons.robot,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Networking',
        FaIcon(
          FontAwesomeIcons.networkWired,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Software Engineering',
        FaIcon(
          FontAwesomeIcons.desktop,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Database',
        FaIcon(
          FontAwesomeIcons.database,
          color: const Color(0xFF167F67),
        )),
    const Item(
        'Project Management',
        FaIcon(
          FontAwesomeIcons.fileWord,
          color: const Color(0xFF167F67),
        )),
  ];
  void chooseFile() async {
    pdf = await FilePicker.getFile(
        type: FileType.custom, allowedExtensions: ['pdf']);

    setState(() {
      fileName = basename(pdf.path);
    });
  }

  void uploadFile() async {
    if (bookName.text.isNotEmpty &&
        aboutBook.text.isNotEmpty &&
        selectedCategory != null &&
        pdf != null) {
      setState(() {
        isLoading = true;
      });
      try {
        StorageReference firebaseStorageRef =
            FirebaseStorage.instance.ref().child('Books').child(fileName);
        StorageUploadTask uploadTask = firebaseStorageRef.putFile(pdf);
        var downUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
        var url = downUrl.toString();
        await Firestore.instance.collection('Books').document().setData({
          'postedBy': userId,
          'bookName': bookName.text.trim(),
          'aboutBook': aboutBook.text.trim(),
          'category': selectedCategory.name,
          'pdfUrl': url,
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          Fluttertoast.showToast(msg: e.message);
          print(e.message);
        });
      }
      setState(() {
        bookName.clear();
        aboutBook.clear();
        selectedCategory = null;
        pdf = null;
        isLoading = false;
        fileName = null;
        Fluttertoast.showToast(msg: "Upload Successful");
      });
    } else {
      Fluttertoast.showToast(msg: "Please fill all fields");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Upload Your Book",
          style: GoogleFonts.firaCode(
              fontSize: 18, color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                Color(0xffff2193b0),
                Color(0xffff6dd5ed),
                Color(0xfffffDBD4B4),
                Color(0xfffff7AA1D2)
              ])),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Enter the Details of the Book :",
                        style: GoogleFonts.firaCode(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 10.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.bookReader,
                              color: Colors.grey,
                            ),
                          ),
                          labelText: 'Book Name',
                          hintText: 'Book Name',
                          labelStyle:
                              GoogleFonts.firaCode(color: Colors.black87),
                          hintStyle:
                              GoogleFonts.firaCode(color: Colors.black87),
                        ),
                        controller: bookName,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            child: DropdownButton<Item>(
                              hint: Text(
                                "Book Category",
                                style: GoogleFonts.firaCode(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: selectedCategory,
                              onChanged: (Item value) {
                                setState(() {
                                  selectedCategory = value;
                                  print(value.name);
                                });
                              },
                              items: users.map((Item user) {
                                return DropdownMenuItem<Item>(
                                  value: user,
                                  child: Row(
                                    children: <Widget>[
                                      user.icon,
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              chooseFile();
                            },
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(width: 1, color: Colors.grey)),
                              child: Text(
                                "Choose File",
                                style: GoogleFonts.firaCode(
                                    fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    (fileName == null)
                        ? Container()
                        : Container(
                            child: Text(fileName),
                          ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        maxLines: 10,
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 2.0),
                          ),
                          border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black87, width: 10.0),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.infoCircle,
                              color: Colors.grey,
                            ),
                          ),
                          labelText: 'About This Book',
                          hintText: 'About This Book',
                          labelStyle:
                              GoogleFonts.firaCode(color: Colors.black87),
                          hintStyle:
                              GoogleFonts.firaCode(color: Colors.black87),
                        ),
                        controller: aboutBook,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        uploadFile();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        margin:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "Upload",
                          style: GoogleFonts.firaCode(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            (isLoading)
                ? Positioned.fill(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black.withOpacity(0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CircularProgressIndicator(
                              backgroundColor: Colors.green,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Uploading! Please Wait :)",
                                style: GoogleFonts.firaCode(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}

class Item {
  const Item(this.name, this.icon);
  final String name;
  final FaIcon icon;
}
