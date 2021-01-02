import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'HomePage.dart';
import 'package:progress_dialog/progress_dialog.dart';

class UploadPhotoPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _UploadPhotoPageState();
  }
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  bool _loading;
  double _progressValue;

  @override
  void initState() {
    super.initState();
    _loading = false;
    _progressValue = 0.0;
  }

  File _sampleImage;
  String _description;
  String _date;
  String url;
  final formKey = new GlobalKey<FormState>();

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _sampleImage = tempImage;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void uploadStatusImage() async {
    if (validateAndSave()) {
      setState(() {
        _loading = !_loading;
        _updateProgress();
      });

      final StorageReference postImageRef =
          FirebaseStorage.instance.ref().child("Post Image");
      var timeKey = new DateTime.now();

      final StorageUploadTask uploadTask =
          postImageRef.child(timeKey.toString() + ".jpg").putFile(_sampleImage);

      var ImageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      url = ImageUrl.toString();
      print("Image Url =" + url);
      goToHomePage();
      saveToDatabase(url);
    }
  }

  void saveToDatabase(url) {
    DatabaseReference ref = FirebaseDatabase.instance.reference();

    var data = {
      "image": url,
      "description": _description,
      "date": _date,
    };
    ref.child("Posts").push().set(data);
  }

  void goToHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
  }
//  Widget logo() {
//     return new Hero(
//       tag: 'hero',
//       child: new CircleAvatar(
//         backgroundColor: Colors.transparent,
//         radius: 110.0,
//         child: Image.asset('images/rudi_application.png'),
//       ),
//     );
//   }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Upload Image"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: new Column(
           
          children: [
           _sampleImage == null? Image.asset('images/rudi_application.png'):Text(""),
            _sampleImage == null
                ? 
                    
                    Text("[ Select an Image ] ")
                  
                : enableUpload(),
          ],
        ),
      ),

      bottomNavigationBar:_sampleImage == null? BottomAppBar(
        elevation: 10,
        color: Colors.pink,
        shape:
            const CircularNotchedRectangle(), //getting curver shape of bottomNavigateBar
        child: Container(
          height: 100.0,
        ),
      ): null,
      

      floatingActionButton: _sampleImage == null? FloatingActionButton(
        backgroundColor: Colors.pink,
        onPressed: getImage,
        child: Icon(Icons.add_a_photo),
      ):null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // floatingActionButton: new FloatingActionButton(

      //   tooltip: 'Add Image',
      //   child: new Icon(Icons.add_a_photo),
      //   onPressed: getImage,
      // ),
    );
  }

  Widget enableUpload() {
    return SingleChildScrollView(
      child: _loading
          ?Row(
              mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                    height: 500.0,
                  ),
                SizedBox(
                   height: 200.0,
                   width: 200.0,
                  child: CircularProgressIndicator(
                    strokeWidth: 13,
                    backgroundColor: Colors.pink[200],
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.pink),
                    value: _progressValue,
                  ),
                ),
                Text('${(_progressValue * 100).round()}%'),
              ],
            )
          : Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  Image.file(_sampleImage, height: 330.0, width: 630.0),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'Description'),
                    validator: (value) {
                      return value.isEmpty ? 'Description is required' : null;
                    },
                    onSaved: (value) {
                      return _description = value;
                    },
                  ),
                  TextFormField(
                    decoration: new InputDecoration(labelText: 'Date@Time'),
                    validator: (value) {
                      return value.isEmpty ? 'Date is required' : null;
                    },
                    onSaved: (value) {
                      return _date = value;
                    },
                  ),
                  SizedBox(
                    height: 15.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                        elevation: 10.0,
                        child: Text("Add a new post"),
                        textColor: Colors.white,
                        color: Colors.pink,
                        onPressed: uploadStatusImage,
                      )
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  void _updateProgress() {
    const oneSec = const Duration(milliseconds: 2000);
    new Timer.periodic(oneSec, (Timer t) {
      setState(() {
        _progressValue += 0.2;
        // we "finish" downloading here
        if (_progressValue.toStringAsFixed(1) == '1.0') {
          _loading = false;
          t.cancel();
          return;
        }
      });
    });
  }
}
