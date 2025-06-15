import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'market_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get uid => _auth.currentUser!.uid;

  List<Map<String, dynamic>> markets = [];

  final List<String> predefinedMarkets = [
    'NYSE',
    'NASDAQ',
    'TSE',
    'PSX',
    'NSE',
    'LSE',
    'CRYPTO',
    'COMEX',
  ];

  @override
  void initState() {
    super.initState();
    _loadMarkets();
  }

  Future<void> _loadMarkets() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('markets')
        .get();

    final List<Map<String, dynamic>> loadedMarkets = [];

    for (var doc in snapshot.docs) {
      double floating = doc.data()['floating'] ?? 0;

      final assetsSnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('markets')
          .doc(doc.id)
          .collection('assets')
          .get();

      double totalValue = 0;
      for (var assetDoc in assetsSnapshot.docs) {
        final data = assetDoc.data();
        totalValue += (data['quantity'] ?? 0) * (data['rate'] ?? 0);
      }

      loadedMarkets.add({
        'name': doc.id,
        'floating': floating,
        'total': totalValue + floating,
        'marketValue': totalValue,
      });
    }

    setState(() {
      markets = loadedMarkets;
    });
  }

  double _getOverallValue() {
    return markets.fold(0, (sum, m) => sum + (m['total'] ?? 0));
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _showAddMarketDialog() async {
    final existingMarketNames = markets.map((m) => m['name']).toList();
    final List<String> availableMarkets = predefinedMarkets
        .where((m) => !existingMarketNames.contains(m))
        .toList();

    String? selectedMarket;

    if (availableMarkets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All markets already added")),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Market"),
        content: DropdownButtonFormField<String>(
          value: selectedMarket,
          items: availableMarkets.map((market) {
            return DropdownMenuItem(value: market, child: Text(market));
          }).toList(),
          onChanged: (value) {
            selectedMarket = value!;
          },
          decoration: const InputDecoration(labelText: "Select Market"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (selectedMarket == null) return;

              await _firestore
                  .collection('users')
                  .doc(uid)
                  .collection('markets')
                  .doc(selectedMarket)
                  .set({'floating': 0.0});

              Navigator.pop(context);
              _loadMarkets();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final overall = _getOverallValue();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Investment Asset Tracker"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadMarkets,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome, ${widget.username}",
                  style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text("Total Portfolio Value: \$${overall.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              const Text("Markets", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Expanded(
                child: markets.isEmpty
                    ? const Center(child: Text("No markets added yet"))
                    : ListView.builder(
                        itemCount: markets.length,
                        itemBuilder: (context, index) {
                          final market = markets[index];
                          return Card(
                            child: ListTile(
                              title: Text(market['name']),
                              subtitle: Text(
                                "Market Value: \$${market['marketValue'].toStringAsFixed(2)} | Floating: \$${market['floating'].toStringAsFixed(2)}",
                              ),
                              trailing: Text(
                                "Total: \$${market['total'].toStringAsFixed(2)}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MarketDetailScreen(
                                      marketName: market['name'],
                                    ),
                                  ),
                                );
                                _loadMarkets();
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMarketDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
