import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_note_app/color_pallete.dart';
import 'package:cloud_note_app/home_page.dart';
import 'package:cloud_note_app/model/note.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  void loginBtnClicked(BuildContext context, String email, String pass) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: color3,
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );

    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);

      final db = FirebaseFirestore.instance;
      var snapshot = await db
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("notes")
          .get();

      List<String> notes = [];
      for (var doc in snapshot.docs) {
        notes.add(Note.fromDoc(doc.data()).toJson());
      }

      await Hive.box("notes").put("notes", notes);

      Navigator.pop(context);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'invalid-credential') {
        showDialog(
          context: context,
          builder: (context) => const Dialog(
            backgroundColor: color3,
            child: SizedBox(
              height: 200,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Text(
                    "Invalid Credential",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => const Dialog(
            backgroundColor: color3,
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Center(
                  child: Text(
                    "Something went wrong! Please try again later.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: color1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "LOGIN",
              style: TextStyle(
                color: color4,
                fontWeight: FontWeight.bold,
                fontSize: 50,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                  color: color4,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color3,
                    width: 3,
                  )),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                style: const TextStyle(
                  fontSize: 15,
                  color: color1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  color: color4,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: color3,
                    width: 3,
                  )),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 5,
              ),
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                style: const TextStyle(
                  fontSize: 15,
                  color: color1,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Password",
                ),
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: passwordController,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextButton(
                onPressed: () => loginBtnClicked(
                    context, emailController.text, passwordController.text),
                style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(color2),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: const Text(
                  "LOGIN",
                  style: TextStyle(
                    color: color4,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
