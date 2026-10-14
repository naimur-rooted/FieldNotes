import 'dart:io';
import 'package:flutter/foundation.dart';
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
            const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Location permission denied')));
      }
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition();
      locC.text = '${pos.latitude.toStringAsFixed(6)}, ${pos.longitude.toStringAsFixed(6)}';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text('Location error: $e')));
      }
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final img = await ImagePicker().pickImage(source: source, maxWidth: 1600);
      if (img != null) setState(() => photoPath = img.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(behavior: SnackBarBehavior.floating, content: Text('Photo error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _initOnce();
    final sites = context.watch<SiteBloc>().state.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLocalId == null ? 'New Field Note' : 'Edit Note'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check_rounded, color: Color(0xFF4F46E5)),
            label: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
            onPressed: _save,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Selector Chips
              const Text('Status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
              const SizedBox(height: 8),
              Row(
                children: SettingsService.statuses.map((s) {
                  final isSelected = status == s;
                  final color = s == 'DONE' ? const Color(0xFF10B981) : s == 'IN_PROGRESS' ? const Color(0xFF0284C7) : const Color(0xFFF59E0B);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        onTap: () => setState(() => status = s),
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade300,
                              width: isSelected ? 1.8 : 1,
                            ),
                          ),
                          child: Text(
                            s,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? color : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Site Selector
              DropdownButtonFormField<String>(
                initialValue: siteLocalId,
                items: sites
                    .map((s) => DropdownMenuItem(
                        value: s.localId,
                        child: Text('${s.name} (${s.customerName})', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => siteLocalId = v),
                decoration: const InputDecoration(
                  labelText: 'Inspection Site *',
                  prefixIcon: Icon(Icons.place_rounded, color: Color(0xFF4F46E5)),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              TextField(
                controller: titleC,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Note Title *',
                  prefixIcon: Icon(Icons.title_rounded, color: Color(0xFF4F46E5)),
                ),
              ),
              const SizedBox(height: 12),

              // Description
              TextField(
                controller: descC,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Observations & Description',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 50),
                    child: Icon(Icons.description_outlined, color: Color(0xFF4F46E5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Location with GPS button
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: locC,
                      decoration: const InputDecoration(
                        labelText: 'Location / Coordinates',
                        prefixIcon: Icon(Icons.my_location_rounded, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.gps_fixed_rounded),
                    tooltip: 'Get Current GPS',
                    onPressed: _useCurrentLocation,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date & Time Picker Card
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5)),
                  title: const Text('Inspection Timestamp', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.edit_calendar_rounded, size: 20),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: dateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d == null) return;
                    if (!context.mounted) return;
                    final t = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(dateTime),
                    );
                    if (mounted) {
                      setState(() => dateTime = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0));
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Photo Section
              Card(
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.photo_camera_rounded, color: Color(0xFF4F46E5), size: 20),
                              SizedBox(width: 8),
                              Text('Photo Evidence', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton.filledTonal(
                                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                                tooltip: 'Camera',
                                onPressed: () => _pickPhoto(ImageSource.camera),
                              ),
                              const SizedBox(width: 6),
                              IconButton.filledTonal(
                                icon: const Icon(Icons.photo_library_rounded, size: 18),
                                tooltip: 'Gallery',
                                onPressed: () => _pickPhoto(ImageSource.gallery),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (photoPath != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(photoPath!, height: 160, width: double.infinity, fit: BoxFit.cover)
                              : Image.file(File(photoPath!), height: 160, width: double.infinity, fit: BoxFit.cover),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Action Button
              Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save_rounded, color: Colors.white),
                  label: const Text(
                    'Save Note (Offline-First)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (siteLocalId == null || titleC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(behavior: SnackBarBehavior.floating, content: Text('Site and Title are required')),
      );
      return;
    }
    context.read<NoteBloc>().add(NoteSave(
          localId: widget.existingLocalId,
          siteLocalId: siteLocalId!,
          title: titleC.text.trim(),
          description: descC.text.trim(),
          location: locC.text.trim(),
          dateTime: dateTime,
          status: status,
          photoLocalPath: photoPath,
        ));
    Navigator.pop(context);
  }
}
