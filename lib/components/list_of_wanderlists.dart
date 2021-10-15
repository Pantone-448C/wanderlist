import 'package:application/apptheme.dart';
import 'package:application/components/searchfield.dart';
import 'package:application/components/wanderlist_summary_item.dart';
import 'package:application/models/user_wanderlist.dart';
import 'package:application/models/wanderlist.dart';
import 'package:flutter/material.dart';

class ListOfWanderlists extends StatefulWidget {
  const ListOfWanderlists({
    Key? key,
    required this.onWanderlistTap,
    required this.wanderlists,
    this.readOnly = false,
    this.onReorder,
    this.onPinTap,
  }) : super(key: key);
  final void Function(UserWanderlist) onWanderlistTap;
  final void Function(int, int)? onReorder;
  final void Function(UserWanderlist)? onPinTap;
  final readOnly;
  final List<UserWanderlist> wanderlists;

  @override
  _ListOfWanderlistsState createState() => _ListOfWanderlistsState();
}

class _ListOfWanderlistsState extends State<ListOfWanderlists> {
  List<UserWanderlist> matchedWanderlists = [];
  bool searching = false;

  @override
  Widget build(BuildContext context) {
    List<UserWanderlist> displayedWanderlists;
    if (searching) {
      displayedWanderlists = matchedWanderlists;
    } else {
      displayedWanderlists = widget.wanderlists;
    }

    var searchBar = Padding(
      // search bar
      padding: EdgeInsets.symmetric(
          horizontal: WanTheme.CARD_PADDING,
          vertical: MediaQuery.of(context).padding.top + WanTheme.CARD_PADDING),
      child: TextField(
        keyboardType: TextInputType.text,
        onChanged: (value) => filterSearch(value),
        decoration: SearchField.defaultDecoration.copyWith(
          hintText: "Search Your Wanderlists",
        ),
      ),
    );

    // TODO: Factor out more arguments somehow
    if (widget.readOnly) {
      return ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: true,
        padding: EdgeInsets.all(WanTheme.CARD_PADDING),
        physics: WanTheme.scrollPhysics,
        children: [
          searchBar,
          for (int index = 0; index < displayedWanderlists.length; index++)
            _TappableWanderlistCard(
              key: Key('$index'),
              wanderlist: displayedWanderlists[index],
              onWanderlistTap: widget.onWanderlistTap,
            )
        ],
      );
    } else {
      return ReorderableListView(
        header: searchBar,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        primary: true,
        padding: EdgeInsets.all(WanTheme.CARD_PADDING),
        physics: WanTheme.scrollPhysics,
        onReorder: widget.onReorder ?? (_, __) {},
        children: [
          for (int index = 0; index < displayedWanderlists.length; index++)
            _TappableWanderlistCard(
              key: Key('$index'),
              wanderlist: displayedWanderlists[index],
              onWanderlistTap: widget.onWanderlistTap,
              onPinTap: widget.onPinTap,
            )
        ],
      );
    }
  }

  void filterSearch(String query) {
    if (query == "") {
      setState(() {
        searching = false;
      });
    } else {
      setState(() {
        searching = true;
      });
    }
    List<UserWanderlist> matches = [];
    List<String> words = query.split(" ");
    Set<int> added = Set<int>();
    for (var word in words) {
      for (var wanderlist in widget.wanderlists) {
        Wanderlist wlist = wanderlist.wanderlist;
        if (!added.contains(wlist)) {
          if (wlist.name.contains(word) || wlist.creatorName.contains(word)) {
            added.add(wlist.hashCode);
            matches.add(wanderlist);
          }
        }
      }
    }
    setState(() {
      matchedWanderlists = matches;
    });
  }
}

class _TappableWanderlistCard extends StatelessWidget {
  _TappableWanderlistCard({
    required this.key,
    required this.wanderlist,
    required this.onWanderlistTap,
    this.onPinTap,
  });

  final Key key;
  final UserWanderlist wanderlist;
  final void Function(UserWanderlist) onWanderlistTap;
  final void Function(UserWanderlist)? onPinTap;

  @override
  Widget build(BuildContext context) {
    Wanderlist wlist = wanderlist.wanderlist;
    return Container(
      margin: EdgeInsets.only(bottom: WanTheme.CARD_PADDING),
      key: ValueKey(wanderlist.hashCode),
      child: InkWell(
        borderRadius: BorderRadius.all(
          Radius.circular(WanTheme.CARD_CORNER_RADIUS),
        ),
        onTap: () => onWanderlistTap(wanderlist),
        child: WanderlistSummaryItem(
          isPinned: wanderlist.inTrip,
          onPinTap: () {
            onPinTap?.call(wanderlist);
          },
          imageUrl: wlist.icon,
          authorName: wlist.creatorName,
          listName: wlist.name,
          numCompletedItems: 0,
          numTotalItems: wlist.activities.length,
        ),
      ),
    );
  }
}
