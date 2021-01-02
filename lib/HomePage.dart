import 'package:rudi/Authentication.dart';
import 'package:rudi/LoginRegisterPage.dart';
import 'package:rudi/PhotoUpload.dart';
import 'package:flutter/material.dart';
import 'Posts.dart';
import 'package:firebase_database/firebase_database.dart';

class HomePage extends StatefulWidget {
  HomePage({
    this.auth,
    this.onSignedOut,
  });
  final AuthImplemetaion auth;
  final VoidCallback onSignedOut;

  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  String url;
  final formKey = new GlobalKey<FormState>();

  // void uploadStatusImage() async {
  //   goToHomePage();
  //   saveToDatabase();
  // }

  bool validateAndSave(String t) {
    if (t != "") {
      return true;
    } else {
      return false;
    }
  }

  // void saveToDatabase() {
  //   DatabaseReference ref = FirebaseDatabase.instance.reference();
  //   url = "-MPnhfhKGILT80UZQbhf";
  //   // var data = {
  //   //   "description": _description,
  //   // };

  //   Map<String, Object> up = new Map();

  //   up['description'] = "ddd_description";
  //   ref.child("Posts/$url").update(up);
  // }

  void goToHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
  }

  List<Posts> postsList = [];
  @override
  void initState() {
    super.initState();
    DatabaseReference postsRef =
        FirebaseDatabase.instance.reference().child("Posts");
    postsRef.once().then((DataSnapshot snap) {
      var KEYS = snap.value.keys;
      var DATA = snap.value;

      postsList.clear();

      for (var individualKey in KEYS) {
        Posts posts = new Posts(
          DATA[individualKey]['image'],
          DATA[individualKey]['description'],
          DATA[individualKey]['date'],
          individualKey,
        );
        postsList.add(posts);
      }
      setState(() {
        print('Length : $postsList.length');
      });
    });
  }

  void _logoutUser() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Home"),
      ),
      body: new Container(
        child: postsList.length == 0
            ? Center(child: new Text("No Blog Post available"))
            : new ListView.builder(
                itemCount: postsList.length,
                itemBuilder: (_, index) {
                  return PostsUI(
                      postsList[index].image,
                      postsList[index].description,
                      postsList[index].date,
                      postsList[index].key);
                }),
      ),
      bottomNavigationBar: new BottomAppBar(
        shape:
                const CircularNotchedRectangle(),
        color: Colors.pink,
        child: new Container(
          margin: const EdgeInsets.only(left: 70.0, right: 70.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.home),
                iconSize: 30,
                color: Colors.white,
                onPressed: _logoutUser,
              ),
              new IconButton(
                icon: new Icon(Icons.add_a_photo),
                iconSize: 30,
                color: Colors.white,
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return new UploadPhotoPage();
                  }));
                },
              )
            ],
          ),
        ),


      ),
    );
  }

  Widget PostsUI(String image, String description, String date, String k) {
    List<String> splitted = date.split("@");
    // String _description;
    // print("sd");
    TextEditingController emailController = new TextEditingController();

    return Container(
      margin: EdgeInsets.all(10.0),
      //padding: EdgeInsets.only(bottom: 20.0),
      child: new Card(
        elevation: 15.0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                topLeft: Radius.circular(1),
                topRight: Radius.circular(1)),
            side: BorderSide(width: 1, color: Colors.pink)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                //color: Colors.black,
                child: new Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: <Widget>[
                    new Text(
                      splitted[0],
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.left,
                    ),
                    new Text(
                      splitted[1],
                      style: Theme.of(context).textTheme.subtitle,
                      textAlign: TextAlign.right,
                    ),
                    // SizedBox(
                    //   height: 2.0,
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              new Image.network(image, fit: BoxFit.cover),
              SizedBox(
                height: 10.0,
              ),
              new Text(
                description,
                style: Theme.of(context).textTheme.subhead,
              ),
              Divider(),
              TextFormField(
                controller: emailController,
                decoration: new InputDecoration(labelText: 'Comment'),
                // validator: (value) {
                //   return value.isEmpty ? 'Enter any comment' : null;
                // },
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                //       SizedBox(
                //   height: 10.0,
                // ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.white)),
                  elevation: 10.0,
                  child: Text("comment"),
                  textColor: Colors.white,
                  color: Colors.pink,
                  onPressed: () {
                    if (validateAndSave(emailController.text)) {
                      goToHomePage();
                      DatabaseReference ref =
                          FirebaseDatabase.instance.reference();
                      url = k;

                      Map<String, Object> up = new Map();

                      up['description'] = description +
                          "\n\n" +
                          "C M T :  " +
                          emailController.text;
                      ref.child("Posts/$url").update(up);
                    }
                  },
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
