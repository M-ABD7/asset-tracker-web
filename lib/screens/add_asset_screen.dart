import 'package:flutter/material.dart';
import 'services/firebase_service.dart';

class AddAssetScreen extends StatefulWidget {
  final String marketName;
  final double floatingValue;
  final List<String> existingAssets;

  const AddAssetScreen({
    super.key,
    required this.marketName,
    required this.floatingValue,
    required this.existingAssets,
  });

  @override
  State<AddAssetScreen> createState() => _AddAssetScreenState();
}

class _AddAssetScreenState extends State<AddAssetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _rateController = TextEditingController();
  String? _selectedAsset;

  final Map<String, List<String>> assetOptions = {
    'Binance': ['BTC', 'ETH', 'BNB', 'ADA', 'DOGE'],
    'NASDAQ': ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'],
  };

  @override
  Widget build(BuildContext context) {
    final availableAssets = assetOptions[widget.marketName]
        ?.where((asset) => !widget.existingAssets.contains(asset))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text('Add Asset - ${widget.marketName}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Asset'),
                items: availableAssets?.map((asset) {
                  return DropdownMenuItem(value: asset, child: Text(asset));
                }).toList(),
                onChanged: (value) => setState(() => _selectedAsset = value),
                validator: (value) =>
                    value == null ? 'Please select an asset' : null,
              ),
              TextFormField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
                validator: (value) {
                  final qty = double.tryParse(value ?? '');
                  return (qty == null || qty <= 0)
                      ? 'Enter valid quantity'
                      : null;
                },
              ),
              TextFormField(
                controller: _rateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rate per unit'),
                validator: (value) {
                  final rate = double.tryParse(value ?? '');
                  return (rate == null || rate <= 0)
                      ? 'Enter valid rate'
                      : null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitAsset,
                child: const Text('Add Asset'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _submitAsset() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(_quantityController.text);
    final rate = double.parse(_rateController.text);
    final total = qty * rate;

    if (total > widget.floatingValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Total exceeds floating value')),
      );
      return;
    }

    final assetData = {
      'name': _selectedAsset!,
      'quantity': qty,
      'rate': rate,
    };

    await FirebaseService.addAsset(widget.marketName, assetData);

    Navigator.pop(context, assetData);
  }
}
