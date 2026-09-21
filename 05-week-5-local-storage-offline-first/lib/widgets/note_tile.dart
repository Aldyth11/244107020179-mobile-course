import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        '${note.body}\nDiperbarui: ${note.updatedAt}',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.dirty)
            const Tooltip(
              message: 'Belum disinkronisasi',
              child: Icon(Icons.cloud_off, color: Colors.orange, size: 20),
            )
          else
            const Tooltip(
              message: 'Sudah disinkronisasi',
              child: Icon(Icons.cloud_done, color: Colors.green, size: 20),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
