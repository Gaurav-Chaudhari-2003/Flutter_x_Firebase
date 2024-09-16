import 'package:flutter/material.dart';
import 'package:flutter_x_firebase/services/firestore_services.dart';
import 'package:intl/intl.dart'; // For date formatting

class NoteEditorPage extends StatefulWidget {
  final String? docID;
  final String initialNote;
  final String initialTitle;

  const NoteEditorPage(
      {super.key, this.docID, this.initialNote = '', this.initialTitle = ''});

  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  late FirestoreService firestoreService;
  final List<String> _history = [];
  int _historyIndex = -1;
  bool _showIcons = false;
  bool _hasUnsavedChanges = false;
  final FocusNode _focusNode = FocusNode();
  String? _timestampText;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService();
    textController.text = widget.initialNote;
    titleController.text = widget.initialTitle;

    // Set character count
    _characterCount = widget.initialNote.length;

    _saveState(); // Save initial state

    if (widget.docID != null) {
      // Fetch note from Firestore and update fields if it's an existing note
      _fetchNoteFromDatabase(widget.docID!);
    } else {
      // New note, set current date/time
      _timestampText = DateFormat.yMMMd().add_jm().format(DateTime.now());
    }

    // Update flag when text changes
    textController.addListener(() {
      setState(() {
        _characterCount = textController.text.length;
        _hasUnsavedChanges = true; // Mark as having unsaved changes
        _showIcons = _hasUnsavedChanges; // Show icons if there are unsaved changes
      });
    });

    titleController.addListener(() {
      setState(() {
        _hasUnsavedChanges = true; // Mark as having unsaved changes
        _showIcons = _hasUnsavedChanges; // Show icons if there are unsaved changes
      });
    });

    // Add listener to detect focus changes
    _focusNode.addListener(() {
      // Remove focus change handling for icons
    });
  }

  Future<void> _fetchNoteFromDatabase(String docID) async {
    try {
      final note = await firestoreService.getNoteById(docID);
      setState(() {
        titleController.text = note['title'] ?? '';
        textController.text = note['note'] ?? '';
        _timestampText =
            DateFormat.yMMMd().add_jm().format(note['timestamp'].toDate());
        _characterCount = textController.text.length;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load note: $e')),
      );
    }
  }

  @override
  void dispose() {
    textController.dispose();
    titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _saveState() {
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    _history.add(textController.text);
    _historyIndex++;
  }

  void _undo() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        textController.text = _history[_historyIndex];
        _hasUnsavedChanges = true; // Mark as having unsaved changes
      });
    }
  }

  void _redo() {
    if (_historyIndex < _history.length - 1) {
      setState(() {
        _historyIndex++;
        textController.text = _history[_historyIndex];
        _hasUnsavedChanges = true; // Mark as having unsaved changes
      });
    }
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this note?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete',
                  style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        );
      },
    );

    if (confirm == true && widget.docID != null) {
      try {
        await firestoreService.deleteNote(widget.docID!);
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete note: $e')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    String title = titleController.text.trim();
    String note = textController.text;

    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note cannot be empty!')),
      );
      return;
    }

    try {
      if (widget.docID == null) {
        await firestoreService.addNote(title, note);
      } else {
        await firestoreService.updateNote(widget.docID!, title, note);
      }
      setState(() {
        _hasUnsavedChanges = false; // No unsaved changes after saving
        _showIcons = false; // Hide icons after saving
      });
      Navigator.of(context).pop(true); // Close page after save
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save note: $e')),
      );
    }
  }

  Future<bool> _onWillPop() async {
    // Hide icons on back button press
    if (_showIcons) {
      setState(() {
        _showIcons = false;
      });
      return true; // Allow default back action
    }
    _showIcons = false;
    return true; // Allow default back action
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Handle back button press
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          title: Text(
            widget.docID == null ? 'Add Note' : 'Update Note',
            style: TextStyle(
                color: Theme.of(context).brightness != Brightness.dark
                    ? Colors.black
                    : Colors.white),
          ),
          elevation: 4,
          centerTitle: true,
          actions: [
            if (widget.docID != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: _confirmDelete,
              ),
            if (_showIcons) ...[
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: () {
                  print("Undo pressed"); // Debug statement
                  _undo();
                },
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: () {
                  print("Redo pressed"); // Debug statement
                  _redo();
                },
              ),
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: () {
                  print("Save pressed"); // Debug statement
                  _saveNote();
                },
              ),
            ],
          ],
        ),
        body: Container(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title TextField
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary),
                ),
                const SizedBox(height: 8.0),
                // Timestamp display
                if (_timestampText != null)
                  Text(
                    _timestampText!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: TextField(
                    controller: textController,
                    focusNode: _focusNode, // Attach focus node
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration(
                      hintText: "Enter your note here",
                      border: InputBorder.none, // Remove border
                      contentPadding: EdgeInsets.all(16),
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onChanged: (text) => _saveState(), // Save state on change
                  ),
                ),
                const SizedBox(height: 16.0),
                // Character count display
                Text(
                  'Total characters: $_characterCount',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
