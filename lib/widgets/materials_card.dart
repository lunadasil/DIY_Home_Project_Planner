import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/material_item.dart';
import '../services/project_repository.dart';

class MaterialsCard extends StatefulWidget {
  final String projectId;
  final List<MaterialItem> materials;
  final double total;

  const MaterialsCard({
    super.key,
    required this.projectId,
    required this.materials,
    required this.total,
  });

  @override
  State<MaterialsCard> createState() => _MaterialsCardState();
}

class _MaterialsCardState extends State<MaterialsCard> {
  final _name = TextEditingController();
  final _cost = TextEditingController();
  final _qty = TextEditingController(text: '1');
  final _unit = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _cost.dispose();
    _qty.dispose();
    _unit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ProjectStore>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Materials & Cost',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Total: \$${widget.total.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 8),

            // existing items
            ...widget.materials.map(
              (m) => ListTile(
                title: Text(m.name),
                subtitle: Text('${m.quantity} ${m.unit ?? ''}'.trim()),
                trailing: Text('\$${(m.cost * m.quantity).toStringAsFixed(2)}'),
              ),
            ),

            const Divider(),

            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Material'),
                onPressed: () async {
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Add Material'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: 'Name'),
                          ),
                          TextField(
                            controller: _cost,
                            decoration:
                                const InputDecoration(labelText: 'Cost per unit'),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                          TextField(
                            controller: _qty,
                            decoration:
                                const InputDecoration(labelText: 'Quantity'),
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                          ),
                          TextField(
                            controller: _unit,
                            decoration:
                                const InputDecoration(labelText: 'Unit (optional)'),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final name = _name.text.trim();
                            final cost =
                                double.tryParse(_cost.text.trim()) ?? 0.0;
                            final qty =
                                double.tryParse(_qty.text.trim()) ?? 1.0;
                            final unit = _unit.text.trim().isEmpty
                                ? null
                                : _unit.text.trim();

                            if (name.isEmpty) return;

                            store.addMaterial(
                              widget.projectId,
                              name,
                              cost,
                              quantity: qty,
                              unit: unit,
                            );

                            _name.clear();
                            _cost.clear();
                            _qty.text = '1';
                            _unit.clear();

                            Navigator.pop(context);
                          },
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
