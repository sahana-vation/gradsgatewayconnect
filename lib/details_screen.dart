import 'package:flutter/material.dart';

class basicDetails extends StatefulWidget {
  const basicDetails({Key? key}) : super(key: key);

  @override
  _basicDetailsState createState() => _basicDetailsState();
}

class _basicDetailsState extends State<basicDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.pink[600],
                borderRadius: BorderRadius.circular(54),
                boxShadow: [
                  BoxShadow(color: Colors.yellow.shade700, spreadRadius: 8)
                ]),
            height: 200,
            width: 500,
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Basic Details",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Name",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Date of Birth",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Exam Name",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "School Name",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(40)),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Class",
                  labelStyle: TextStyle(fontSize: 19),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(width: 5),
                    borderRadius: BorderRadius.all(Radius.circular(40)),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 120),
          ElevatedButton(
              onPressed: () {}, //To de added later
              child: Text("Submit"),
              style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(), backgroundColor: Colors.yellow.shade700,
                  padding: EdgeInsets.symmetric(horizontal: 152, vertical: 15),
                  textStyle: TextStyle(
                    fontSize: 20,
                  ))),
        ],
      ),
    );
  }
}