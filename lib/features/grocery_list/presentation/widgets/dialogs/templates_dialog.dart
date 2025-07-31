import 'package:flutter/material.dart';
import 'package:grocery/features/grocery_list/data/services/grocery_storage_service.dart';
import 'package:grocery/features/grocery_list/domain/entities/grocery_template.dart';
import 'add_template_dialog.dart';

class TemplatesDialog extends StatefulWidget {
  const TemplatesDialog({super.key});

  @override
  State<TemplatesDialog> createState() => _TemplatesDialogState();
}

class _TemplatesDialogState extends State<TemplatesDialog> {
  late Future<List<GroceryTemplate>> _templatesFuture;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  void _loadTemplates() {
    _templatesFuture = GroceryStorageService.instance.loadTemplates();
  }

  void _addTemplate() async {
    final result = await showDialog<GroceryTemplate>(
      context: context,
      builder: (ctx) => const AddTemplateDialog(),
    );
    if (result != null) {
      await GroceryStorageService.instance.saveTemplate(result);
      setState(_loadTemplates);
    }
  }

  void _deleteTemplate(String id) async {
    await GroceryStorageService.instance.deleteTemplate(id);
    setState(_loadTemplates);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Shopping Templates'),
      content: SizedBox(
        width: 350,
        child: FutureBuilder<List<GroceryTemplate>>(
          future: _templatesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No templates saved yet.');
            }
            final templates = snapshot.data!;
            return ListView.separated(
              shrinkWrap: true,
              itemCount: templates.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  title: Text(template.name),
                  subtitle: Text(
                    template.items.map((e) => e.title).join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteTemplate(template.id),
                  ),
                  onTap: () {
                    Navigator.of(context).pop(template);
                  },
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(onPressed: _addTemplate, child: const Text('Add Template')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
