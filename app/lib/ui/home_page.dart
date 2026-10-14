import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notes/note_bloc.dart';
import '../blocs/customers/customer_bloc.dart';
import '../blocs/sites/site_bloc.dart';
import 'customers_page.dart';
import 'sites_page.dart';
import 'notes_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    context.read<CustomerBloc>().add(CustomersLoad());
    context.read<SiteBloc>().add(SitesLoad());
    context.read<NoteBloc>().add(NotesLoad());
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [NotesPage(), CustomersPage(), SitesPage(), SettingsPage()];
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.note_alt_outlined), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.business_outlined), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.place_outlined), label: 'Sites'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}
