import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditAssetScreen extends StatefulWidget {
  final String marketName;
  final String assetName;
  final double currentQty;
  final double currentRate;

  const EditAssetScreen({
    super.key,
    required this.marketName,
    required this.assetName,
    required this.currentQty,
    required this.currentRate, required double marketFloating,
  });

  @override
  State<EditAssetScreen> createState() => _EditAssetScreenState();
}

class _EditAssetScreenState extends State<EditAssetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _qtyController = TextEditingController();
  final _rateController = TextEditingController();
  double marketFloating = 0.0;

  final uid = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchFloating();
  }

  Future<void> _fetchFloating() async {
    final doc = await _firestore.collection('users').doc(uid).collection('markets').doc(widget.marketName).get();
    setState(() {
      marketFloating = doc.data()?['floating']?.toDouble() ?? 0.0;
    });
  }

  Future<void> _updateAsset(bool isBuy) async {
    final qty = double.tryParse(_qtyController.text.trim()) ?? 0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0;

    if (qty <= 0 || rate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid quantity and rate')));
      return;
    }

    final docRef = _firestore.collection('users').doc(uid).collection('markets').doc(widget.marketName);
    final assetRef = docRef.collection('assets').doc(widget.assetName);

    final snapshot = await assetRef.get();
    double existingQty = snapshot.data()?['quantity']?.toDouble() ?? 0.0;
    double existingRate = snapshot.data()?['rate']?.toDouble() ?? 0.0;

    double newQty = isBuy ? existingQty + qty : existingQty - qty;

    if (!isBuy && qty > existingQty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot sell more than owned')));
      return;
    }
    if (isBuy && (qty * rate) > marketFloating) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not enough floating value')));
      return;
    }

    double newTotal = isBuy
        ? (existingQty * existingRate) + (qty * rate)
        : (newQty * existingRate); // keep rate same after selling

    double newAvgRate = isBuy ? (newTotal / newQty) : existingRate;

    await assetRef.set({'quantity': newQty, 'rate': newAvgRate});
    await docRef.update({
      'floating': isBuy ? marketFloating - (qty * rate) : marketFloating + (qty * rate),
    });

    Navigator.pop(context); // return to market detail screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit ${widget.assetName}")),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Buy'),
              Tab(text: 'Sell'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildForm(true),
                _buildForm(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isBuy) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _qtyController,
            decoration: const InputDecoration(labelText: "Quantity"),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _rateController,
            decoration: const InputDecoration(labelText: "Rate"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _updateAsset(isBuy),
            child: Text(isBuy ? "Buy Asset" : "Sell Asset"),
          )
        ],
      ),
    );
  }
}
