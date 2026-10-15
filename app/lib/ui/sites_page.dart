import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/customers/customer_bloc.dart';
import '../blocs/sites/site_bloc.dart';
import 'widgets/app_top_actions.dart';

class SitesPage extends StatelessWidget {
  const SitesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_rounded, color: Color(0xFF4F46E5), size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Sites'),
          ],
        ),
        actions: [
          AppTopActions(
            leadingAction: IconButton.filledTonal(
              icon: const Icon(Icons.sync_rounded),
              tooltip: 'Sync',
              onPressed: () => context.read<SiteBloc>().add(SitesSync()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('New Site', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => _showForm(context, null, null, '', ''),
      ),
      body: BlocConsumer<SiteBloc, SiteState>(
        listener: (context, state) {
          if (state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(state.message!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_location_outlined, size: 48, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Inspection Sites',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Create a customer first, then add work sites and projects.',
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF4F46E5),
            onRefresh: () async => context.read<SiteBloc>().add(SitesSync()),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.items.length,
              itemBuilder: (context, i) {
                final s = state.items[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.place_rounded, color: Color(0xFF4F46E5), size: 24),
                    ),
                    title: Text(
                      s.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  s.customerName,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (s.address.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              s.address,
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s.dirty)
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.cloud_off_rounded, size: 16, color: Color(0xFFEA580C)),
                          ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded, size: 20),
                          onSelected: (v) {
                            if (v == 'edit') {
                              _showForm(context, s.localId, s.customerLocalId, s.name, s.address);
                            } else {
                              context.read<SiteBloc>().add(SiteDelete(s.localId));
                            }
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, String? localId, String? currentCustomerLocalId, String name, String address) {
    final nameC = TextEditingController(text: name);
    final addrC = TextEditingController(text: address);
    final customers = context.read<CustomerBloc>().state.items;
    String? selectedCustomer = currentCustomerLocalId ?? (customers.isNotEmpty ? customers.first.localId : null);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.place_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 10),
              Text(localId == null ? 'Add Site' : 'Edit Site'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (customers.isEmpty)
                const Text('No customers found. Please add a customer first.', style: TextStyle(color: Colors.red))
              else
                DropdownButtonFormField<String>(
                  initialValue: selectedCustomer,
                  decoration: const InputDecoration(labelText: 'Customer', prefixIcon: Icon(Icons.business_rounded)),
                  items: customers
                      .map((c) => DropdownMenuItem(value: c.localId, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setDState(() => selectedCustomer = v),
                ),
              const SizedBox(height: 12),
              TextField(
                controller: nameC,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Site / Project Name', prefixIcon: Icon(Icons.apartment_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrC,
                decoration: const InputDecoration(labelText: 'Physical Address', prefixIcon: Icon(Icons.map_outlined)),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameC.text.trim().isEmpty || selectedCustomer == null) return;
                context.read<SiteBloc>().add(SiteSave(
                      localId: localId,
                      customerLocalId: selectedCustomer!,
                      name: nameC.text.trim(),
                      address: addrC.text.trim(),
                    ));
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
