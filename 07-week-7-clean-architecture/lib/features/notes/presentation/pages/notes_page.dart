import 'package:flutter/material.dart';

import '../widgets/notes_body.dart';
import '../widgets/notes_search_field.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Clean Architecture'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: NotesSearchField(),
        ),
      ),
      body: const NotesBody(),
    );
  }
}
