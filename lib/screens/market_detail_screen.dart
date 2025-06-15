import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_asset_screen.dart';
import 'edit_asset_screen.dart';

class MarketDetailScreen extends StatefulWidget {
  final String marketName;

  const MarketDetailScreen({super.key, required this.marketName});

  @override
  State<MarketDetailScreen> createState() => _MarketDetailScreenState();
}

class _MarketDetailScreenState extends State<MarketDetailScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String userId;
  double floating = 0;
  List<Map<String, dynamic>> assets = [];

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser!.uid;
    _loadData();
  }

  Future<void> _loadData() async {
    final marketDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('markets')
        .doc(widget.marketName)
        .get();

    final assetsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('markets')
        .doc(widget.marketName)
        .collection('assets')
        .get();

    setState(() {
      floating = marketDoc.data()?['floating'] ?? 0;
      assets = assetsSnapshot.docs.map((doc) {
        return {
          'name': doc.id,
          'quantity': doc['quantity'],
          'rate': doc['rate'],
        };
      }).toList();
    });
  }

  Future<void> _liquidate() async {
    double amount = 0;

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Liquidate Amount'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Enter amount'),
            onChanged: (value) => amount = double.tryParse(value) ?? 0,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (amount > 0 && amount <= floating) {
                  Navigator.pop(context, amount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid liquidation amount")),
                  );
                }
              },
              child: const Text("Liquidate"),
            ),
          ],
        );
      },
    );

    if (result != null && result > 0) {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('markets')
          .doc(widget.marketName)
          .update({'floating': floating - result});

      _loadData();
    }
  }

  void _navigateToAddAsset() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddAssetScreen(marketName: widget.marketName, floatingValue: 0, existingAssets: [],),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  void _navigateToEditAsset(Map<String, dynamic> asset) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditAssetScreen(
          marketName: widget.marketName,
          assetName: asset['name'],
          currentQty: asset['quantity'],
          currentRate: asset['rate'],
          marketFloating: floating ?? 0,
        ),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  double _calculateTotalValue() {
    double total = 0;
    for (var asset in assets) {
      total += asset['quantity'] * asset['rate'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    double marketValue = _calculateTotalValue();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.marketName} Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Total Market Value: \$${marketValue.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18)),
            Text("Floating: \$${floating.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            const Text("Assets", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: assets.isEmpty
                  ? const Center(child: Text("No assets yet"))
                  : ListView.builder(
                      itemCount: assets.length,
                      itemBuilder: (context, index) {
                        final asset = assets[index];
                        final total = asset['quantity'] * asset['rate'];
                        return ListTile(
                          title: Text(asset['name']),
                          subtitle: Text(
                            "Qty: ${asset['quantity']} | Rate: \$${asset['rate']} | Total: \$${total.toStringAsFixed(2)}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _navigateToEditAsset(asset),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: _liquidate,
            label: const Text("Liquidate"),
            icon: const Icon(Icons.money_off),
            backgroundColor: Colors.red,
            heroTag: "liquidate",
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _navigateToAddAsset,
            child: const Icon(Icons.add),
            heroTag: "addAsset",
          ),
        ],
      ),
    );
  }
}
