import 'package:application/models/wanderlist.dart';
import 'package:application/repositories/wanderlist/i_wanderlist_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WanderlistRepository implements IWanderlistRepository {
  final CollectionReference _wanderlists =
      FirebaseFirestore.instance.collection('wanderlists');

  @override
  Future<Wanderlist> getWanderlist(String id) async {
    DocumentSnapshot snapshot = await _wanderlists.doc(id).get();
    return Wanderlist.fromJson(snapshot.data() as Map<String, dynamic>);
  }
}
