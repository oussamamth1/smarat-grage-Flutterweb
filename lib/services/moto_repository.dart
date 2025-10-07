import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/MotoModel.dart';





class MotoRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<Moto>> streamMotos() {
    return _db
        .collection('motos')
        .orderBy('brandName')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Moto.fromDoc(d)).toList());
  }

  Future<void> addMoto(Moto moto) async {
    await _db.collection('motos').add(moto.toMap());
  }

  Future<void> updateMoto(Moto moto) async {
    await _db.collection('motos').doc(moto.id).update(moto.toMap());
  }

  Future<void> deleteMoto(String id) async {
    await _db.collection('motos').doc(id).delete();
  }
}
