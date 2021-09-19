import 'package:application/models/activity.dart';
import 'package:application/models/user.dart';
import 'package:application/models/user_wanderlist.dart';

abstract class IUserRepository {
  Future<UserDetails> getUserData();
  Future<UserDetails> getUserDataAndWanderlists();
  Future<Iterable<UserWanderlist>> getActiveWanderlists();
  Future<Iterable<UserWanderlist>> getUserWanderlists();
  Future<Iterable<ActivityDetails>> getUserCompletedActivities();
  Future<void> updateUserData(UserDetails details);

  Future<ActivityDetails> getActivity(String id);
}
