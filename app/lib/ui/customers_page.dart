import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/customers/customer_bloc.dart';

class CustomersPage extends StatelessWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
              icon: const Icon(Icons.sync),
              onPressed: () => context.read<CustomerBloc>().add(CustomersSync())),
          IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => context.read<AuthBloc>().add(AuthLogout())),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null, '', ''),
        child: const Icon(Icons.add),
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message!)));
          }
        },
        builder: (context, state) {
          if (state.items.isEmpty) {
            return const Center(child: Text('No customers yet. Tap + to add.'));
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<CustomerBloc>().add(CustomersSync()),
            child: ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final c = state.items[i];
                return ListTile(
                  leading: CircleAvatar(child: Text(c.name.isEmpty ? '?' : c.name[0].toUpperCase())),
                  title: Text(c.name),
                  subtitle: Text(c.contactInfo.isEmpty ? 'No contact info' : c.contactInfo),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (c.dirty) const Icon(Icons.cloud_off, size: 18, color: Colors.orange),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') {
                          _showForm(context, c.localId, c.name, c.contactInfo);
                        } else {
                          context.read<CustomerBloc>().add(CustomerDelete(c.localId));
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

  void _showForm(BuildContext context, String? localId, String name, String contact) {
    final nameC = TextEditingController(text: name);
    final contactC = TextEditingController(text: contact);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localId == null ? 'New customer' : 'Edit customer'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameC, decoration: const InputDecoration(labelText: 'Name *')),
          TextField(controller: contactC, decoration: const InputDecoration(labelText: 'Contact info')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (nameC.text.trim().isEmpty) return;
              context.read<CustomerBloc>().add(CustomerSave(
                  localId: localId, name: nameC.text.trim(), contactInfo: contactC.text.trim()));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
