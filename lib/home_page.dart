import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_note_app/color_pallete.dart';
import 'package:cloud_note_app/login_page.dart';
import 'package:cloud_note_app/model/note.dart';
import 'package:cloud_note_app/note_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var box = Hive.box("notes");
  late List<Note> notes;
  final db = FirebaseFirestore.instance;

  void getBackup() async {
    final db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("notes")
        .get();

    List<String> notes = [];
    for (var doc in snapshot.docs) {
      notes.add((doc as Note).toJson());
    }

    await Hive.box("notes").put("notes", notes);
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await Hive.box("notes").delete("notes");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void toNotePage(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotePage(
          note: note,
          deleteFunc: deleteNote,
        ),
      ),
    ).then((value) {
      if (value == null) return;
      setState(() {
        updateNote(note, value[0], value[1]);
      });
    });
  }

  void updateNote(Note note, String newTitle, String newContent) {
    note.title = newTitle;
    note.content = newContent;
    syncData();
  }

  void syncData() {
    box.put("notes", notes.map((e) => e.toJson()).toList());
  }

  void addNote() {
    Note note = Note();
    notes.add(note);
    toNotePage(note);
  }

  void deleteNote(Note note) {
    setState(() {
      notes.remove(note);
      syncData();
    });
  }

  List<Note> fetchNotes() {
    return box.get("notes")?.map<Note>((e) => Note.fromJson(e)).toList() ?? [];
  }

  void restore() async {
    Navigator.pop(context);

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Dialog(
          backgroundColor: color2,
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
    } on Exception catch (e) {
      showDialog(
        context: context,
        builder: (context) => const Dialog(
          backgroundColor: color2,
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

    Navigator.pop(context);

    setState(() {});
  }

  void backup() async {
    Navigator.pop(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Dialog(
        backgroundColor: color2,
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

    final db = FirebaseFirestore.instance;
    try {
      var snapshot = await db
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("notes")
          .get();

      for (var doc in snapshot.docs) {
        await db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("notes")
            .doc(doc.id)
            .delete();
      }

      for (var note in notes) {
        await db
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("notes")
            .add(note.toDoc());
      }
    } on Exception catch (e) {
      showDialog(
        context: context,
        builder: (context) => const Dialog(
          backgroundColor: color2,
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

    Navigator.pop(context);
  }

  void showCloudDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: color1,
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  IconButton(
                    onPressed: () => backup(),
                    color: color4,
                    iconSize: 50,
                    icon: const Icon(Icons.cloud_upload),
                  ),
                  const Text(
                    "Backup",
                    style: TextStyle(
                      color: color4,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    onPressed: () => restore(),
                    color: color4,
                    iconSize: 50,
                    icon: const Icon(Icons.cloud_download),
                  ),
                  const Text(
                    "Restore",
                    style: TextStyle(
                      color: color4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notes = fetchNotes();

    return Scaffold(
      backgroundColor: color3,

      // AppBar
      appBar: AppBar(
        backgroundColor: color1,
        title: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            "Notes",
            style: TextStyle(
              color: color4,
              fontWeight: FontWeight.bold,
              fontSize: 35,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: showCloudDialog,
            color: color4,
            iconSize: 30,
            icon: const Icon(Icons.cloud),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: signOut,
            color: color4,
            iconSize: 30,
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 20),
        ],
        toolbarHeight: 100,
      ),

      // Add Button
      floatingActionButton: FloatingActionButton(
        onPressed: addNote,
        backgroundColor: color2,
        child: const Icon(
          Icons.add,
          color: color4,
          size: 30,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30,
        ),
        child: ListView.builder(
          itemBuilder: (context, i) => Column(
            children:
                (i == 0 ? <Widget>[const SizedBox(height: 20)] : <Widget>[]) +
                    [
                      const SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () => toNotePage(notes[i]),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notes[i].title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: color1,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () => deleteNote(notes[i]),
                                color: color1,
                                iconSize: 30,
                                icon: const Icon(
                                  Icons.delete,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] +
                    (i != notes.length - 1
                        ? <Widget>[
                            const SizedBox(
                              height: 20,
                            ),
                            const Divider(
                              color: color1,
                            ),
                          ]
                        : <Widget>[
                            const SizedBox(
                              height: 100,
                            ),
                          ]),
          ),
          itemCount: notes.length,
        ),
      ),
    );
  }
}
