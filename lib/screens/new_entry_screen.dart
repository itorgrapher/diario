import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../app_state.dart';
import '../services/cloudinary_service.dart';

class NewEntryScreen extends StatefulWidget {
  const NewEntryScreen({super.key});

  @override
  State<NewEntryScreen> createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  late final TextEditingController _gratitudeController;
  late final TextEditingController _textController;
  bool _saved = false;
  bool _uploadingPhoto = false;
  Timer? _debounce;

  static const _trackerKeys = ['animo', 'sueno', 'energia', 'libido', 'estres'];

  @override
  void initState() {
    super.initState();
    final app = context.read<AppState>();
    _gratitudeController = TextEditingController(text: app.gratitudeText);
    _textController = TextEditingController(text: app.entryText);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _gratitudeController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _scheduleSave() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 700), _saveNow);
  }

  Future<void> _saveNow() async {
    final app = context.read<AppState>();
    await app.saveEntryNow(text: _textController.text, gratitude: _gratitudeController.text);
    if (!mounted) return;
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _pickValue(BuildContext context, AppState app, String fieldKey) {
    final f = fieldDefs[fieldKey]!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _optionChip(ctx, app, fieldKey, null, Icons.close, Colors.grey.shade200, Colors.grey.shade700),
                ...f.order.map((v) => _optionChip(ctx, app, fieldKey, v, valueIcon(fieldKey, v), valueColorBg(fieldKey, v), valueColorFg(fieldKey, v))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _optionChip(BuildContext ctx, AppState app, String fieldKey, String? value, IconData icon, Color bg, Color fg) {
    return GestureDetector(
      onTap: () {
        app.setNewEntryField(fieldKey, value);
        Navigator.pop(ctx);
        _scheduleSave();
      },
      child: CircleAvatar(radius: 20, backgroundColor: bg, child: Icon(icon, size: 18, color: fg)),
    );
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    setState(() => _uploadingPhoto = true);
    try {
      final url = await CloudinaryService.uploadImage(File(picked.path));
      if (!mounted) return;
      context.read<AppState>().addPhotoUrl(url);
      _scheduleSave();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo subir la foto: $e')));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final animoValue = app.newEntryFields['animo'];
    final washColor = animoValue != null ? valueColorBg('animo', animoValue).withOpacity(0.5) : null;

    return Scaffold(
      backgroundColor: washColor,
      appBar: AppBar(
        title: const Text('Hoy', style: TextStyle(fontSize: 14)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedOpacity(
                opacity: _saved ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: const Row(
                  children: [
                    Icon(Icons.cloud_done_outlined, size: 14, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Guardado', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _trackerKeys.map((key) {
              final f = fieldDefs[key]!;
              final selected = app.newEntryFields[key];
              return GestureDetector(
                onTap: () => _pickValue(context, app, key),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected != null ? valueColorBg(key, selected) : const Color(0xFFF1EFE8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    selected != null ? valueIcon(key, selected) : f.icon,
                    size: 16,
                    color: selected != null ? valueColorFg(key, selected) : Colors.grey.shade600,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(color: const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.favorite_border, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _gratitudeController,
                    decoration: const InputDecoration(hintText: 'Algo por lo que estás agradecido hoy', border: InputBorder.none, isDense: true),
                    onChanged: (_) => _scheduleSave(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _textController,
            maxLines: 8,
            minLines: 6,
            decoration: const InputDecoration(hintText: 'Escribe lo que quieras...', border: InputBorder.none),
            onChanged: (_) => _scheduleSave(),
          ),
          const SizedBox(height: 14),
          if (app.entryPhotoUrls.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: app.entryPhotoUrls
                  .map((url) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(url, width: 70, height: 70, fit: BoxFit.cover),
                      ))
                  .toList(),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _uploadingPhoto ? null : _addPhoto,
            icon: _uploadingPhoto
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.photo_outlined, size: 16),
            label: Text(_uploadingPhoto ? 'Subiendo...' : 'Añadir foto'),
          ),
        ],
      ),
    );
  }
}
