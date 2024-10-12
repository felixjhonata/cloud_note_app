import 'package:cloud_note_app/color_pallete.dart';
import 'package:cloud_note_app/model/note.dart';
import 'package:flutter/material.dart';

class NotePage extends StatelessWidget {
  const NotePage({super.key, required this.note, required this.deleteFunc});
  final Note note;
  final Function(Note) deleteFunc;

  void deleteNote(BuildContext context) {
    deleteFunc(note);
    Navigator.pop(context);
  }

  void goBack(BuildContext context, String title, String content) {
    if (title.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => const Dialog(
          backgroundColor: color1,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Center(
                child: Text(
                  "Title can't be empty!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color4,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      return;
    }
    popFunc(context, title, content);
  }

  Future<bool> popFunc(
      BuildContext context, String title, String content) async {
    Navigator.pop(context, [title, content]);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController titleController =
        TextEditingController(text: note.title);
    TextEditingController contentController =
        TextEditingController(text: note.content);

    return WillPopScope(
      onWillPop: () =>
          popFunc(context, titleController.text, contentController.text),
      child: Scaffold(
        backgroundColor: color3,

        // AppBar
        appBar: AppBar(
          backgroundColor: color3,
          toolbarHeight: 80,
          leadingWidth: 80,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                goBack(context, titleController.text, contentController.text),
            iconSize: 30,
            color: color1,
          ),
          actions: [
            IconButton(
              onPressed: () => deleteNote(context),
              icon: const Icon(Icons.delete),
              iconSize: 30,
              color: color1,
            ),
            const SizedBox(
              width: 20,
            ),
          ],
        ),

        // Body
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: ListView(
            children: [
              TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: color1,
                ),
                controller: titleController,
              ),
              const Divider(
                color: color1,
              ),
              TextField(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(
                  color: color1,
                  fontSize: 15,
                ),
                controller: contentController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
