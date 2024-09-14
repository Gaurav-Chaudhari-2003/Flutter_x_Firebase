import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_x_firebase/components/MyDrawer.dart';
import 'package:flutter_x_firebase/services/FirestoreService.dart';
import 'package:provider/provider.dart';
import '../../themes/ThemeProvider.dart';
import '../NoteEditorPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();
  late FirestoreService firestoreService;
  String searchQuery = '';
  final Map<String, bool> expandedNotes = {};
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    firestoreService = FirestoreService();
  }

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white,
      floatingActionButton: _buildFloatingActionButton(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildNotesList(),
          ),
        ],
      ),
      drawer: const MyDrawer(),
    );
  }

  // Add this method to your HomePage widget
  AppBar _buildAppBar(BuildContext context) {
    // Use Provider or any other state management solution to get the theme mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor:
          isDarkMode ? Colors.black : Colors.white.withOpacity(0.1),
      title: Text(
        "N O T E S",
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            isDarkMode
                ? Icons.brightness_7
                : Icons.brightness_2, // Adjust icon based on theme
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
          onPressed: () {
            // Toggle theme mode
            final themeProvider =
                Provider.of<ThemeProvider>(context, listen: false);
            themeProvider.toggleTheme();
          },
        ),
      ],
    );
  }

  FloatingActionButton _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: Colors.blueGrey,
      onPressed: _openNoteBox,
      child: Icon(Icons.add,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: textController,
        decoration: InputDecoration(
          hintText: 'Search notes...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
          ),
        ),
        onChanged: _onSearchQueryChanged,
      ),
    );
  }

  void _performSearch() {
    setState(() {
      searchQuery = textController.text.toLowerCase();
      if (searchQuery.isEmpty) {
        expandedNotes.clear();
      }
      _keys.clear();
    });
    _scrollToFirstMatch();
  }

  void _onSearchQueryChanged(String value) {
    setState(() {
      searchQuery = value.toLowerCase();
      if (searchQuery.isEmpty) {
        expandedNotes.clear();
      }
      _keys.clear();
    });
  }

  StreamBuilder<QuerySnapshot> _buildNotesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: firestoreService.getNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> notesList = snapshot.data!.docs;

          notesList = _filterNotes(notesList);

          if (searchQuery.isNotEmpty && _keys.isEmpty) {
            _scrollToFirstMatch();
          }

          if (notesList.isEmpty && searchQuery.isNotEmpty) {
            return Center(
              child: Text(
                "No match found!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
            );
          }

          return _buildNotesListView(notesList);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  List<QueryDocumentSnapshot> _filterNotes(
      List<QueryDocumentSnapshot> notesList) {
    if (searchQuery.isNotEmpty) {
      return notesList.where((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String noteText = data['note'].toString().toLowerCase();
        return noteText.contains(searchQuery);
      }).toList();
    }
    return notesList;
  }

  ListView _buildNotesListView(List<QueryDocumentSnapshot> notesList) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: notesList.length,
      itemBuilder: (context, index) {
        return _buildNoteItem(notesList[index]);
      },
    );
  }

  Widget _buildNoteItem(DocumentSnapshot documentSnapshot) {
    String docID = documentSnapshot.id;
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    // Fetch the title, or use the first 20 characters of the note if the title is missing
    String noteText = data['note'] ?? '';

    // Remove newline characters from noteText
    String cleanedTitleText = noteText.replaceAll('\n', '');
    // Determine title
    String title = data['title']?.isNotEmpty == true
        ? data['title']!
        : cleanedTitleText.substring(
            0, cleanedTitleText.length > 40 ? 40 : cleanedTitleText.length);

    Timestamp timestamp = data['timestamp'] as Timestamp;
    DateTime dateTime = timestamp.toDate();

    String body = noteText.isNotEmpty ? noteText : 'No text';

    String formattedDate = dateTime.toLocal().toString().split(' ')[0];
    String formattedTime =
        dateTime.toLocal().toString().split(' ')[1].substring(0, 5);

    bool isExpanded = expandedNotes[docID] ?? false;

    final key = GlobalKey();
    _keys[docID] = key;

    return Padding(
      padding: const EdgeInsets.only(
          left: 10.0, right: 10.0, top: 10.0, bottom: 5.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            expandedNotes[docID] = !isExpanded;
          });
        },
        child: Container(
          key: key,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness != Brightness.dark
                ? Colors.black.withOpacity(0.1)
                : Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
          ),
          child: Container(
            margin: const EdgeInsets.only(left: 15, bottom: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildNoteHeadline(title)),
                    IconButton(
                      icon: Icon(Icons.edit,
                          color: Theme.of(context).brightness != Brightness.dark
                              ? Colors.black.withOpacity(0.5)
                              : Colors.white.withOpacity(0.5)),
                      onPressed: () => _openNoteBox(docID: docID),
                    ),
                  ],
                ),
                _buildNoteBody(body, isExpanded),
                const SizedBox(height: 4.0),
                _buildNoteTimestamp(formattedDate, formattedTime),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Text _buildNoteHeadline(String headline) {
    return Text(
      headline,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).brightness != Brightness.dark
            ? Colors.black.withOpacity(1)
            : Colors.white.withOpacity(1),
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  RichText _buildNoteBody(String body, bool isExpanded) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16.0,
          color: Theme.of(context).brightness != Brightness.dark
              ? Colors.black.withOpacity(0.7)
              : Colors.white.withOpacity(0.7),
        ),
        children: _highlightText(body),
      ),
      maxLines: isExpanded ? null : 2,
      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
    );
  }

  Text _buildNoteTimestamp(String date, String time) {
    return Text(
      '$date - $time',
      style: TextStyle(
        fontSize: 14.0,
        color: Theme.of(context).brightness != Brightness.dark
            ? Colors.black.withOpacity(0.6)
            : Colors.white.withOpacity(0.6),
      ),
    );
  }

  List<TextSpan> _highlightText(String text) {
    if (searchQuery.isEmpty) {
      return [TextSpan(text: text)];
    }

    final List<TextSpan> spans = [];
    final RegExp regExp =
        RegExp(RegExp.escape(searchQuery), caseSensitive: false);
    int start = 0;

    for (final Match match in regExp.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: const TextStyle(
          backgroundColor: Colors.yellow,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return spans;
  }

  void _toggleNoteExpansion(String docID, bool isExpanded) {
    setState(() {
      expandedNotes[docID] = !isExpanded;
    });
  }

  void _scrollToFirstMatch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool matched = false;
      for (String key in _keys.keys) {
        if (_keys[key]!.currentContext != null) {
          final renderBox =
              _keys[key]!.currentContext!.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final offset = renderBox.localToGlobal(Offset.zero);
            final itemOffset = offset.dy;
            final itemHeight = renderBox.size.height;
            final itemTop = itemOffset;
            final itemBottom = itemTop + itemHeight;

            if (itemTop <
                    _scrollController.offset +
                        _scrollController.position.viewportDimension &&
                itemBottom > _scrollController.offset) {
              setState(() {
                expandedNotes[key] = true;
              });

              _scrollController.animateTo(
                itemOffset -
                    _scrollController.position.viewportDimension / 2 +
                    itemHeight / 2,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
              matched = true;
              break;
            }
          }
        }
      }

      if (!matched && searchQuery.isNotEmpty) {
        if (_keys.isNotEmpty) {
          final firstItemKey = _keys.values.first;
          final renderBox =
              firstItemKey.currentContext?.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            final offset = renderBox.localToGlobal(Offset.zero);
            final itemOffset = offset.dy;
            _scrollController.animateTo(
              itemOffset - _scrollController.position.viewportDimension / 2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      }
    });
  }

  void _openNoteBox({String? docID}) async {
    String initialNote = '';
    if (docID != null) {
      DocumentSnapshot docSnapshot = await firestoreService.getNoteById(docID);
      if (docSnapshot.exists) {
        Map<String, dynamic>? data =
            docSnapshot.data() as Map<String, dynamic>?;
        initialNote = data?['note'] ?? '';
      }
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorPage(
          docID: docID,
          initialNote: initialNote,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }
}
