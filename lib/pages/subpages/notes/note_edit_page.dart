import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lexikon/utils/controllers/note_controller.dart';
import 'package:lexikon/utils/models/note.dart';

class NoteEditPage extends ConsumerStatefulWidget {
  const NoteEditPage({super.key});

  @override
  ConsumerState<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends ConsumerState<NoteEditPage> {
  late final QuillController _quillController;
  late final TextEditingController _titleController;
  late final FocusNode _editorFocusNode;
  late final ScrollController _editorScrollController;

  String? _noteId;

  bool _isEditing = false;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    _quillController = QuillController.basic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final argument = ModalRoute.of(context)?.settings.arguments;

    if (argument is String && argument.isNotEmpty) {
      _noteId = argument;
      _loadNote(argument);
    } else {
      // New notes immediately open in editing mode.
      _isEditing = true;
    }
  }

  // ===========================================================================
  // LOAD NOTE
  // ===========================================================================

  void _loadNote(String noteId) {
    final note =
        ref.read(noteControllerProvider.notifier).getNoteById(noteId);

    if (note == null) {
      return;
    }

    try {
      final decoded = jsonDecode(note.document);

      final document = Document.fromJson(
        List<Map<String, dynamic>>.from(
          decoded.map(
            (item) => Map<String, dynamic>.from(item),
          ),
        ),
      );

      _quillController.document = document;
    } catch (error) {
      // If the document is invalid, start with an empty document rather
      // than crashing the entire page.
      _quillController.document = Document();
    }

    _titleController.text = note.title;

    // Existing notes open in preview mode.
    _isEditing = false;
  }

  // ===========================================================================
  // IMAGE INSERTION
  // ===========================================================================

  Future<void> _insertImage() async {
    if (!_isEditing) {
      return;
    }

    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );

    // User dismissed the dialog.
    if (source == null) {
      return;
    }

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 90,
    );

    if (pickedFile == null) {
      return;
    }

    final bytes = await pickedFile.readAsBytes();

    if (!mounted) {
      return;
    }

    final base64Image = base64Encode(bytes);

    final imageUrl = 'data:image/jpeg;base64,$base64Image';

    final selection = _quillController.selection;

    int index = selection.baseOffset;

    if (index < 0) {
      index = _quillController.document.length - 1;
    }

    _quillController.document.insert(
      index,
      BlockEmbed.image(imageUrl),
    );

    // Add a new line after the image so the user can continue typing.
    _quillController.document.insert(
      index + 1,
      '\n',
    );

    _quillController.updateSelection(
      TextSelection.collapsed(
        offset: index + 2,
      ),
      ChangeSource.local,
    );

    _editorFocusNode.requestFocus();
  }

  // ===========================================================================
  // SAVE
  // ===========================================================================

  Future<void> _saveNote() async {
    if (_isSaving) {
      return;
    }

    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showMessage('Please enter a title.');
      return;
    }

    final plainText = _quillController.document.toPlainText().trim();

    // An image-only note is still a valid note.
    final hasContent = plainText.isNotEmpty ||
        _quillController.document
            .toDelta()
            .toList()
            .any((operation) => operation.data is Map);

    if (!hasContent) {
      _showMessage('Note cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final controller = ref.read(noteControllerProvider.notifier);

      final now = DateTime.now();

      DateTime createdAt = now;

      if (_noteId != null) {
        final oldNote = controller.getNoteById(_noteId!);

        if (oldNote != null) {
          createdAt = oldNote.createdAt;
        }
      }

      final documentJson = jsonEncode(
        _quillController.document.toDelta().toJson(),
      );

      final note = Note(
        id: _noteId ?? now.millisecondsSinceEpoch.toString(),
        title: title,
        document: documentJson,
        createdAt: createdAt,
        updatedAt: now,
      );

      if (_noteId == null) {
        _noteId = note.id;
        await controller.addNote(note);
      } else {
        await controller.updateNote(note);
      }

      if (!mounted) {
        return;
      }

      // Saving does NOT leave the page.
      // Instead, switch back to preview mode.
      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      FocusScope.of(context).unfocus();

      _showMessage('Note saved.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });

      _showMessage('Failed to save note.');
    }
  }

  // ===========================================================================
  // EDIT MODE
  // ===========================================================================

  void _enterEditMode() {
    setState(() {
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editorFocusNode.requestFocus();
      }
    });
  }

  // ===========================================================================
  // TOOLS
  // ===========================================================================

  void _toggleBold() {
    _quillController.formatSelection(
      Attribute.bold,
    );
  }

  void _toggleItalic() {
    _quillController.formatSelection(
      Attribute.italic,
    );
  }

  void _toggleUnderline() {
    _quillController.formatSelection(
      Attribute.underline,
    );
  }

  void _toggleBulletList() {
    _quillController.formatSelection(
      Attribute.ul,
    );
  }

  void _toggleNumberedList() {
    _quillController.formatSelection(
      Attribute.ol,
    );
  }

  void _toggleCodeBlock() {
    _quillController.formatSelection(
      Attribute.codeBlock,
    );
  }

  void _toggleQuote() {
    _quillController.formatSelection(
      Attribute.blockQuote,
    );
  }

  void _setHeading(int level) {
    final attribute = switch (level) {
      1 => Attribute.h1,
      2 => Attribute.h2,
      3 => Attribute.h3,
      _ => Attribute.header,
    };

    _quillController.formatSelection(attribute);
  }

  // ===========================================================================
  // MENU
  // ===========================================================================

  Future<void> _showToolsMenu() async {
    if (!_isEditing) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ListTile(
                  title: Text(
                    'Formatting',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ----------------------------------------------------------------
                // Text formatting
                // ----------------------------------------------------------------

                ListTile(
                  leading: const Icon(Icons.format_bold),
                  title: const Text('Bold'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleBold();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.format_italic),
                  title: const Text('Italic'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleItalic();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.format_underlined),
                  title: const Text('Underline'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleUnderline();
                  },
                ),

                const Divider(),

                // ----------------------------------------------------------------
                // Headings
                // ----------------------------------------------------------------

                const ListTile(
                  title: Text(
                    'Headings',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.looks_one),
                  title: const Text('Heading 1'),
                  onTap: () {
                    Navigator.pop(context);
                    _setHeading(1);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.looks_two),
                  title: const Text('Heading 2'),
                  onTap: () {
                    Navigator.pop(context);
                    _setHeading(2);
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.looks_3),
                  title: const Text('Heading 3'),
                  onTap: () {
                    Navigator.pop(context);
                    _setHeading(3);
                  },
                ),

                const Divider(),

                // ----------------------------------------------------------------
                // Lists / blocks
                // ----------------------------------------------------------------

                ListTile(
                  leading: const Icon(Icons.format_list_bulleted),
                  title: const Text('Bullet list'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleBulletList();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.format_list_numbered),
                  title: const Text('Numbered list'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleNumberedList();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.format_quote),
                  title: const Text('Quote'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleQuote();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Code block'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleCodeBlock();
                  },
                ),

                const Divider(),

                // ----------------------------------------------------------------
                // Attachments
                // ----------------------------------------------------------------

                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Insert image'),
                  onTap: () {
                    Navigator.pop(context);
                    _insertImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MESSAGE
  // ===========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ===========================================================================
  // EDITOR
  // ===========================================================================

  Widget _buildEditor() {
    return QuillEditor(
      controller: _quillController,
      focusNode: _editorFocusNode,
      scrollController: _editorScrollController,
      config: QuillEditorConfig(
        placeholder: 'Start writing...',
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32,
        ),
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfig: QuillEditorImageEmbedConfig(
              imageProviderBuilder: (context, imageUrl) {
                if (imageUrl.startsWith('data:image')) {
                  try {
                    final commaIndex = imageUrl.indexOf(',');

                    if (commaIndex == -1) {
                      return null;
                    }

                    final encoded = imageUrl.substring(
                      commaIndex + 1,
                    );

                    final bytes = base64Decode(encoded);

                    return MemoryImage(
                      Uint8List.fromList(bytes),
                    );
                  } catch (_) {
                    return null;
                  }
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PREVIEW
  // ===========================================================================

  Widget _buildPreview() {
    return QuillEditor(
      controller: _quillController,
      focusNode: FocusNode(),
      scrollController: _editorScrollController,
      config: QuillEditorConfig(
        padding: const EdgeInsets.fromLTRB(
          20,
          16,
          20,
          32,
        ),
        showCursor: false,
        enableInteractiveSelection: true,
        scrollable: true,
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(
            imageEmbedConfig: QuillEditorImageEmbedConfig(
              imageProviderBuilder: (context, imageUrl) {
                if (imageUrl.startsWith('data:image')) {
                  try {
                    final commaIndex = imageUrl.indexOf(',');

                    if (commaIndex == -1) {
                      return null;
                    }

                    final encoded = imageUrl.substring(
                      commaIndex + 1,
                    );

                    final bytes = base64Decode(encoded);

                    return MemoryImage(
                      Uint8List.fromList(bytes),
                    );
                  } catch (_) {
                    return null;
                  }
                }

                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,

        title: TextField(
          controller: _titleController,
          readOnly: !_isEditing,
          textInputAction: TextInputAction.done,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          decoration: const InputDecoration(
            hintText: 'Click here to add title...',
            hintStyle: TextStyle(
              color: Color(0xFFC2C2C2),
            ),
            border: InputBorder.none,
          ),
        ),

        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              tooltip: _isEditing ? 'Save' : 'Edit',
              icon: Icon(
                _isEditing
                    ? Icons.check
                    : Icons.edit_outlined,
              ),
              onPressed: _isEditing
                  ? _saveNote
                  : _enterEditMode,
            ),

          PopupMenuButton<String>(
            tooltip: 'More',
            enabled: !_isSaving,
            onSelected: (value) {
              switch (value) {
                case 'tools':
                  _showToolsMenu();
                  break;

                case 'image':
                  _insertImage();
                  break;
              }
            },
            itemBuilder: (context) {
              return [
                if (_isEditing)
                  const PopupMenuItem(
                    value: 'image',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.image_outlined,
                      ),
                      title: Text('Insert image'),
                    ),
                  ),

                if (_isEditing)
                  const PopupMenuItem(
                    value: 'tools',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.text_format,
                      ),
                      title: Text('Formatting'),
                    ),
                  ),

                if (!_isEditing)
                  const PopupMenuItem(
                    value: 'tools',
                    enabled: false,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.info_outline,
                      ),
                      title: Text('Tap Edit to modify'),
                    ),
                  ),
              ];
            },
          ),
        ],
      ),

      body: SafeArea(
        child: _isEditing
            ? _buildEditor()
            : _buildPreview(),
      ),
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    _quillController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();

    super.dispose();
  }
}