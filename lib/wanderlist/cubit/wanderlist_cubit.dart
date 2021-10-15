import 'package:application/models/activity.dart';
import 'package:application/models/user_wanderlist.dart';
import 'package:application/models/wanderlist.dart';
import 'package:application/repositories/wanderlist/i_wanderlist_repository.dart';
import 'package:application/wanderlist/cubit/wanderlist_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WanderlistCubit extends Cubit<WanderlistState> {
  WanderlistCubit(this.wanderlistRepository) : super(Initial());

  IWanderlistRepository wanderlistRepository;

  loadWanderlists(Wanderlist wanderlist) async {
    if (state is Initial) {
      emit(Loading());
      await loadWanderlistActivities(wanderlist);
      emit(Viewing(wanderlist));
    } else {
      emit(state);
    }
  }

  Future<void> loadWanderlistActivities(Wanderlist wanderlist) async {
    if (wanderlist.loadedActivities.length == 0 &&
        wanderlist.activityReferences.length != 0) {
      for (DocumentReference activity in wanderlist.activityReferences) {
        wanderlist.loadedActivities.add(ActivityDetails.fromJson(
            (await activity.get()).data() as Map<String, dynamic>));
      }
    }
  }

  Wanderlist _deepCopyActivityList(Wanderlist wanderlist) {
    List<ActivityDetails> copiedActivities = []
      ..addAll(wanderlist.loadedActivities);
    return wanderlist.copyWith(loadedActivities: copiedActivities);
  }

  startEdit(Wanderlist wanderlist) {
    if (state is Viewing) {
      emit(Editing(wanderlist, _deepCopyActivityList(wanderlist)));
    } else {
      emit(state);
    }
  }

  endEdit() {
    if (state is Editing) {
      Wanderlist wanderlist = (state as Editing).wanderlist;
      emit(Saving());
      _save(wanderlist);
      emit(Viewing(wanderlist));
    } else {
      emit(state);
    }
  }

  cancelEdit() {
    if (state is Editing) {
      emit(Viewing((state as Editing).original));
    } else {
      emit(state);
    }
  }

  madeEdit(Wanderlist wanderlist) {
    if (state is Editing) {
      emit(Editing(wanderlist, (state as Editing).original));
    } else {
      emit(state);
    }
  }

  addActivity(Wanderlist wanderlist, ActivityDetails activity) {
    if (state is Editing) {
      (state as Editing).wanderlist.loadedActivities.add(activity);
      final original = (state as Editing).original;
      emit(Editing(wanderlist, original));
    } else {
      emit(state);
    }
  }

  Future<void> _save(Wanderlist wanderlist) async {
    await wanderlistRepository.setWanderlist(wanderlist);
  }

  Future<Wanderlist> _retrieve(String docReference) async {
    return wanderlistRepository.getWanderlist(docReference);
  }
}
