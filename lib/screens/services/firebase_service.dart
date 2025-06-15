import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final String userId = FirebaseAuth.instance.currentUser!.uid;

  static Future<void> addAsset(String marketName, Map<String, dynamic> assetData) async {
    final assetName = assetData['name'];
    final quantity = assetData['quantity'];
    final rate = assetData['rate'];
    final totalCost = quantity * rate;

    final marketRef = _firestore
        .collection('usersc')
        .doc(userId)
        .collection('markets')
        .doc(marketName);

    final assetRef = marketRef.collection('assets').doc(assetName);

    // Add the asset
    await assetRef.set({
      'quantity': quantity,
      'rate': rate,
    });

    // Decrease floating value
    await marketRef.update({
      'floating': FieldValue.increment(-totalCost),
    });
  }
}
