import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/customers/customer_bloc.dart';
import '../blocs/sites/site_bloc.dart';

class SitesPage extends StatelessWidget {
  const SitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sites'),
        actions: [
          IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => context.read<SiteBloc>().add(SitesSync())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null, null, '', ''),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<SiteBloc, SiteState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('No sites yet. Create a customer first, then tap +.'));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<SiteBloc>().add(SitesSync()),
            child: ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final s = state.items[i];
                return ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(s.name),
                  subtitle: Text('${s.customerName}${s.address.isEmpty ? '' : ' • ${s.address}'}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (s.dirty) const Icon(Icons.cloud_off, size: 18, color: Colors.orange),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') {
                          _showForm(context, s.localId, s.customerLocalId, s.name, s.address);
                        } else {
                          context.read<SiteBloc>().add(SiteDelete(s.localId));
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ]),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, String? localId, String? customerLocalId, String name, String address) {
    final customers = context.read<CustomerBloc>().state.items;
    if (customers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create a customer first')));
      return;
    }
    String selected = customerLocalId ?? customers.first.localId;
    final nameC = TextEditingController(text: name);
    final addrC = TextEditingController(text: address);
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(localId == null ? 'New site' : 'Edit site'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: selected,
              items: customers
                  .map((c) => DropdownMenuItem(value: c.localId, child: Text(c.name)))
                  .toList(),
              onChanged: (v) => setState(() => selected = v!),
              decoration: const InputDecoration(labelText: 'Customer *'),
            ),
            TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Site name *')),
            TextField(controller: addrC, decoration: const InputDecoration(labelText: 'Address')),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (nameC.text.trim().isEmpty) return;
                context.read<SiteBloc>().add(SiteSave(
                    localId: localId, customerLocalId: selected,
                    name: nameC.text.trim(), address: addrC.text.trim()));
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
