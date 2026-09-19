import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:lexikon/utils/controllers/note_controller.dart';
import 'package:lexikon/utils/models/note.dart';

/// Decode Base64 outside the UI isolate.
///
/// This prevents large images from blocking the editor while they are
/// being decoded.
Uint8List _decodeBase64(String base64Data) {
  return Uint8List.fromList(base64Decode(base64Data));
}

enum _LeaveAction {
  cancel,
  discard,
  save,
}

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

  bool _initialized = false;
  bool _isEditing = false;
  bool _isSaving = false;

  DateTime? _createdAt;

  String? _savedTitle;
  String? _savedDocument;
  final Map<String, String> _savedAttachments = {};

  /// Attachment ID -> Base64.
  ///
  /// This is the temporary working attachment store.
  final Map<String, String> _attachments = {};

  /// Attachment ID -> decoded image Future.
  ///
  /// Once an image starts decoding, we keep the Future here.
  /// Rebuilding the editor therefore does NOT restart decoding.
  final Map<String, Future<Uint8List>> _decodedImages = {};

  bool _hasUnsavedChanges() {
    if (!_isEditing) {
      return false;
    }

    final currentTitle = _titleController.text;

    final currentDocument = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );

    return currentTitle != _savedTitle ||
        currentDocument != _savedDocument ||
        !mapEquals(
          _attachments,
          _savedAttachments,
        );
  }

  Future<bool> _confirmLeave() async {
    if (!_hasUnsavedChanges()) {
      return true;
    }

    final action = await showDialog<_LeaveAction>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Unsaved changes'),
          content: const Text(
            'You have unsaved changes to this note. '
            'Would you like to save them before leaving?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _LeaveAction.cancel,
                );
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _LeaveAction.discard,
                );
              },
              child: const Text('Discard'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  _LeaveAction.save,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    switch (action) {
      case _LeaveAction.discard:
        return true;

      case _LeaveAction.save:
        await _saveNote();

        return !_hasUnsavedChanges();

      case _LeaveAction.cancel:
      case null:
        return false;
    }
  }

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController();

    _editorFocusNode = FocusNode();

    _editorScrollController = ScrollController();

    _quillController = QuillController.basic();
  }

  // ===========================================================================
  // INITIALIZATION
  // ===========================================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) {
      return;
    }

    _initialized = true;

    final argument = ModalRoute.of(context)?.settings.arguments;

    if (argument is String && argument.isNotEmpty) {
      _noteId = argument;
      _loadNote(argument);
    } else {
      // New note.
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

    _titleController.text = note.title;
    _createdAt = note.createdAt;

    _attachments
      ..clear()
      ..addAll(note.attachments);

    try {
      final decoded = jsonDecode(note.document);

      final json = List<Map<String, dynamic>>.from(
        (decoded as List).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );

      _quillController.document = Document.fromJson(json);
    } catch (_) {
      // Gracefully recover from invalid/old document data.
      _quillController.document = Document();
    }

    // Existing notes open in preview mode.
    _isEditing = false;
  }

  // ===========================================================================
  // ATTACHMENTS
  // ===========================================================================

  Future<void> _insertImage() async {
    if (!_isEditing || _isSaving) {
      return;
    }

    final source = await _showImageSourceDialog();

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

    final attachmentId =
        '${DateTime.now().microsecondsSinceEpoch}_${_attachments.length}';

    final base64Data = base64Encode(bytes);

    // Store the persistent representation.
    _attachments[attachmentId] = base64Data;

    // Do NOT decode it again.
    //
    // We already have the bytes from image_picker, so cache them directly.
    _decodedImages[attachmentId] = Future.value(bytes);

    _insertAttachmentIntoDocument(attachmentId);

    setState(() {});
  }

  Future<ImageSource?> _showImageSourceDialog() {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Insert image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _insertAttachmentIntoDocument(String attachmentId) {
    final selection = _quillController.selection;

    int index = selection.baseOffset;

    if (index < 0) {
      index = _quillController.document.length - 1;
    }

    if (index < 0) {
      index = 0;
    }

    final embed = CustomBlockEmbed(
      'attachment',
      attachmentId,
    );

    _quillController.document.insert(
      index,
      embed,
    );

    // New paragraph after the image.
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
  // IMAGE CACHE
  // ===========================================================================

  Future<Uint8List> _getDecodedImage(
    String attachmentId,
  ) {
    final existing = _decodedImages[attachmentId];

    if (existing != null) {
      return existing;
    }

    final base64Data = _attachments[attachmentId];

    if (base64Data == null) {
      return Future.error(
        Exception('Attachment not found'),
      );
    }

    final future = compute(
      _decodeBase64,
      base64Data,
    );

    _decodedImages[attachmentId] = future;

    return future;
  }

  // ===========================================================================
  // FORMATTING
  // ===========================================================================

  void _toggleBold() {
    _quillController.formatSelection(Attribute.bold);
  }

  void _toggleItalic() {
    _quillController.formatSelection(Attribute.italic);
  }

  void _toggleUnderline() {
    _quillController.formatSelection(Attribute.underline);
  }

  void _toggleBulletList() {
    _quillController.formatSelection(Attribute.ul);
  }

  void _toggleNumberedList() {
    _quillController.formatSelection(Attribute.ol);
  }

  void _toggleQuote() {
    _quillController.formatSelection(Attribute.blockQuote);
  }

  void _toggleCodeBlock() {
    _quillController.formatSelection(Attribute.codeBlock);
  }

  void _setHeading(int level) {
    final attribute = switch (level) {
      1 => Attribute.h1,
      2 => Attribute.h2,
      3 => Attribute.h3,
      _ => Attribute.h1,
    };

    _quillController.formatSelection(attribute);
  }

  // ===========================================================================
  // TOOLS MENU
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

                ListTile(
                  leading: const Icon(
                    Icons.format_list_bulleted,
                  ),
                  title: const Text('Bullet list'),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleBulletList();
                  },
                ),

                ListTile(
                  leading: const Icon(
                    Icons.format_list_numbered,
                  ),
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

                ListTile(
                  leading: const Icon(
                    Icons.image_outlined,
                  ),
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

    final document = _quillController.document;

    final plainText = document.toPlainText().trim();

    final hasAttachments = document.toDelta().toList().any(
          (operation) {
            final data = operation.data;

            return data is Map &&
                data.containsKey('attachment');
          },
        );

    if (plainText.isEmpty && !hasAttachments) {
      _showMessage('Note cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final controller =
          ref.read(noteControllerProvider.notifier);

      final now = DateTime.now();

      final createdAt = _createdAt ?? now;

      // -----------------------------------------------------------------------
      // Remove attachments that are no longer referenced by the document.
      //
      // This is intentionally done ONLY during saving.
      // -----------------------------------------------------------------------

      final usedAttachmentIds = <String>{};

      for (final operation in document.toDelta().toList()) {
        final data = operation.data;

        if (data is Map &&
            data.containsKey('attachment')) {
          final id = data['attachment'];

          if (id is String) {
            usedAttachmentIds.add(id);
          }
        }
      }

      _attachments.removeWhere(
        (id, _) => !usedAttachmentIds.contains(id),
      );

      _decodedImages.removeWhere(
        (id, _) => !usedAttachmentIds.contains(id),
      );

      // -----------------------------------------------------------------------
      // Serialize Quill document.
      // -----------------------------------------------------------------------

      final documentJson = jsonEncode(
        document.toDelta().toJson(),
      );

      final note = Note(
        id: _noteId ??
            now.millisecondsSinceEpoch.toString(),
        title: title,
        document: documentJson,
        attachments: Map<String, String>.from(
          _attachments,
        ),
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

      // IMPORTANT:
      //
      // We do NOT leave the page.
      //
      // We keep the decoded image cache alive so the preview can immediately
      // display images without decoding them again.
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
  // ENTER EDIT MODE
  // ===========================================================================

  void _enterEditMode() {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isEditing = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _editorFocusNode.requestFocus();
    });
  }

  // ===========================================================================
  // IMAGE EMBED BUILDER
  // ===========================================================================

  Widget _buildAttachment(
    BuildContext context,
    String attachmentId,
  ) {
    final future = _getDecodedImage(attachmentId);

    return FutureBuilder<Uint8List>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _ImagePlaceholder(
            loading: true,
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const _ImagePlaceholder(
            loading: false,
          );
        }

        final imageBytes = snapshot.data!;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: GestureDetector(
              onTap: () {
                _showImageFullscreen(imageBytes);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        );
      },
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
          _AttachmentEmbedBuilder(
            buildAttachment: _buildAttachment,
          ),

          ...FlutterQuillEmbeds.editorBuilders(),
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
          _AttachmentEmbedBuilder(
            buildAttachment: _buildAttachment,
          ),

          ...FlutterQuillEmbeds.editorBuilders(),
        ],
      ),
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
  // SHOW IMAGE AS FULLSCREEN
  // ===========================================================================

  void _showImageFullscreen(Uint8List imageBytes) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              // Image
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 16,
                right: 16,
                child: SafeArea(
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: 'Close',
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }  

  // ===========================================================================
  // BUILD
  // ===========================================================================

  void _undo() {
    if (!_isEditing || _isSaving) {
      return;
    }

    _quillController.undo();
  }

  void _redo() {
    if (!_isEditing || _isSaving) {
      return;
    }

    _quillController.redo();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges(),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldLeave = await _confirmLeave();

        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
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
              hintText: 'Untitled',
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

            // AppBar menu is now ONLY for things such as attachments.
          PopupMenuButton<String>(
            tooltip: 'More',
            enabled: !_isSaving,
            onSelected: (value) {
              switch (value) {
                case 'image':
                  _insertImage();
                  break;

                case 'undo':
                  _undo();
                  break;

                case 'redo':
                  _redo();
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
                  const PopupMenuDivider(),

                if (_isEditing)
                  const PopupMenuItem(
                    value: 'undo',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.undo,
                      ),
                      title: Text('Undo'),
                    ),
                  ),

                if (_isEditing)
                  const PopupMenuItem(
                    value: 'redo',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.redo,
                      ),
                      title: Text('Redo'),
                    ),
                  ),

                if (!_isEditing)
                  const PopupMenuItem(
                    enabled: false,
                    value: 'info',
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.info_outline,
                      ),
                      title: Text(
                        'Tap Edit to modify',
                      ),
                    ),
                  ),
              ];
            },
          ),        ],
        ),

        body: SafeArea(
          child: _isEditing
              ? _buildEditor()
              : _buildPreview(),
        ),

        // ------------------------------------------------------------
        // Floating formatting button
        // ------------------------------------------------------------
        floatingActionButton: _isEditing
            ? FloatingActionButton(
                heroTag: 'formattingButton',
                tooltip: 'Formatting',
                onPressed: _showToolsMenu,
                child: const Icon(
                  Icons.text_format,
                ),
              )
            : null,

        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat,
      )
    );
  }

  // ===========================================================================
  // DISPOSE
  // ===========================================================================

  @override
  void dispose() {
    // This is where the temporary decoded image cache dies.
    //
    // The Base64 data remains safely stored in Hive through Note.
    _decodedImages.clear();

    _attachments.clear();

    _quillController.dispose();
    _titleController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();

    super.dispose();
  }
}

// =============================================================================
// CUSTOM ATTACHMENT EMBED BUILDER
// =============================================================================

class _AttachmentEmbedBuilder extends EmbedBuilder {
  final Widget Function(
    BuildContext context,
    String attachmentId,
  ) buildAttachment;

  _AttachmentEmbedBuilder({
    required this.buildAttachment,
  });

  @override
  String get key => 'attachment';

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final node = embedContext.node;

    final data = node.value.data;

    if (data is! String) {
      return const _ImagePlaceholder(
        loading: false,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: buildAttachment(
        context,
        data,
      ),
    );
  }
}

// =============================================================================
// IMAGE PLACEHOLDER
// =============================================================================

class _ImagePlaceholder extends StatelessWidget {
  final bool loading;

  const _ImagePlaceholder({
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 280,
        height: 190,
        margin: const EdgeInsets.symmetric(
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: loading
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text('Decoding image...'),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.broken_image_outlined,
                      size: 42,
                    ),
                    SizedBox(height: 8),
                    Text('Unable to load image'),
                  ],
                ),
        ),
      ),
    );
  }
}