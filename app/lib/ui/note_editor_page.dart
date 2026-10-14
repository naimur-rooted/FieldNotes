import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../blocs/notes/note_bloc.dart';
import '../blocs/settings/settings_bloc.dart';
import '../blocs/sites/site_bloc.dart';
import '../data/local/settings_service.dart';

class NoteEditorPage extends StatefulWidget {
  final String? existingLocalId;
  const NoteEditorPage({super.key, this.existingLocalId});
  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  String? siteLocalId;
  final titleC = TextEditingController();
  final descC = TextEditingController();
  final locC = TextEditingController();
  DateTime dateTime = DateTime.now();
  String status = 'OPEN';
  String? photoPath;
  bool loaded = false;

  @override
  void dispose() {
    titleC.dispose();
    descC.dispose();
    locC.dispose();
    super.dispose();
  }

  void _initOnce() {
    if (loaded) return;
    loaded = true;
    status = context.read<SettingsBloc>().state.defaultStatus;
    final sites = context.read<SiteBloc>().state.items;
    if (widget.existingLocalId != null) {
      final notes = context.read<NoteBloc>().state.items;
      for (final n in notes) {
        if (n.localId == widget.existingLocalId) {
          siteLocalId = n.siteLocalId;
          titleC.text = n.title;
          descC.text = n.description;
          locC.text = n.location;
          dateTime = n.dateTime ?? n.updatedAt;
          status = n.status;
          photoPath = n.photoLocalPath;
        }
      }
    } else if (sites.isNotEmpty) {
      siteLocalId = sites.first.localId;
    }
  }

  Future<void> _useCurrentLocation() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')));
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      locC.text = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location error: $e')));
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final img = await ImagePicker().pickImage(source: source, maxWidth: 1600);
      if (img != null) setState(() => photoPath = img.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Photo error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initOnce();
    final sites = context.watch<SiteBloc>().state.items;
    return Scaffold(
      appBar: AppBar(title: Text(widget.existingLocalId == null ? 'New note' : 'Edit note')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          DropdownButtonFormField<String>(
            initialValue: siteLocalId,
            items: sites.map((s) => DropdownMenuItem(
                value: s.localId, child: Text('${s.name} (${s.customerName})'))).toList(),
            onChanged: (v) => setState(() => siteLocalId = v),
            decoration: const InputDecoration(labelText: 'Site *', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(controller: titleC,
              decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: descC, maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: locC,
                decoration: const InputDecoration(labelText: 'Location', border: OutlineInputBorder()))),
            IconButton(icon: const Icon(Icons.my_location),
                tooltip: 'Use current location', onPressed: _useCurrentLocation),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(dateTime)}')),
            TextButton(
              onPressed: () async {
                final d = await showDatePicker(context: context, initialDate: dateTime,
                    firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (d == null) return;
                final t = await showTimePicker(
                    context: context, initialTime: TimeOfDay.fromDateTime(dateTime));
                if (mounted) {
                  setState(() => dateTime =
                      DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0));
                }
              },
              child: const Text('Change'),
            ),
          ]),
          DropdownButtonFormField<String>(
            initialValue: status,
            items: SettingsService.statuses
                .map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => status = v!),
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: photoPath == null
                  ? const Text('No photo (optional)')
                  : Image.file(File(photoPath!), height: 120, fit: BoxFit.cover),
            ),
            Column(children: [
              IconButton(icon: const Icon(Icons.camera_alt),
                  tooltip: 'Camera', onPressed: () => _pickPhoto(ImageSource.camera)),
              IconButton(icon: const Icon(Icons.photo_library),
                  tooltip: 'Gallery', onPressed: () => _pickPhoto(ImageSource.gallery)),
            ]),
          ]),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              if (siteLocalId == null || titleC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Site and title are required')));
                return;
              }
              context.read<NoteBloc>().add(NoteSave(
                  localId: widget.existingLocalId, siteLocalId: siteLocalId!,
                  title: titleC.text.trim(), description: descC.text.trim(),
                  location: locC.text.trim(), dateTime: dateTime,
                  status: status, photoLocalPath: photoPath));
              Navigator.pop(context);
            },
            child: const Text('Save note (works offline)'),
          ),
        ]),
      ),
    );
  }
}
