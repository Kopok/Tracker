import 'package:flappy_search_bar/search_bar_style.dart';
import 'package:flutter/material.dart';
import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flappy_search_bar/scaled_tile.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:numberpicker/numberpicker.dart';
import 'Shelf.dart';
import 'package:string_similarity/string_similarity.dart';

class EncounterBuilder extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _EncounterBuilderState();
  }
}

class _EncounterBuilderState extends State<EncounterBuilder>{
  SlidableController slidableController;
  final SearchBarController<Creature> _searchBarController = SearchBarController();
  bool isReplay = false;

  Future<List<Creature>> searchPosts(String text) async {

    List<Creature> posts = Creature.getAllPosts();
    posts.sort((a, b) => StringSimilarity.compareTwoStrings(b.getSearchString(), text).compareTo(StringSimilarity.compareTwoStrings(a.getSearchString(), text)));
    ListVisible=false;
    return posts;
  }
  bool ListVisible = true;
  int numberPicker = 0 ;
  String dropdownValueTest = "One";
  String dropdownValueCR = "1";
  CreatureType dropdownValueType = CreatureType.Player;

  var Types = CreatureType.values;
  var CR = new List<String>.generate(10, (int index) => index.toString());

  final List<CreatureType> selectedTypes = <CreatureType>[];
  final List<String> selectedCR = <String>[];

  final List<Creature> returnedCreatures = <Creature>[];

  @protected
  void initState() {
    slidableController = SlidableController();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(resizeToAvoidBottomInset : false,
      body: SafeArea(
        child:
        Stack(fit: StackFit.expand,
            children:<Widget>[
            SearchBar<Creature>(
              onSearch: searchPosts,
              onCancelled: ()=>setState(() {ListVisible=true;}),
              searchBarController: _searchBarController,
              emptyWidget: Text("empty"),
              onItemFound: (Creature post, int index) {
                return Container(color: Colors.white,child:ListTile(
                    title: Text(post.Name),
                    subtitle: Text(post.getTypeString()),
                    onTap: () {returnedCreatures.add(post);setState(() {});}
                ));
              },
            ),
             if (ListVisible) Positioned(top:80,width:MediaQuery.of(context).size.width,child: _buildList(context, Axis.vertical)),
             if (!ListVisible) Positioned(top:80,right: -290, width:MediaQuery.of(context).size.width,child: _buildList(context, Axis.vertical)),
            Positioned(bottom:0,left:50,child:RaisedButton(
                child: Text('Roll Initative'),
                onPressed: () {Navigator.of(context).push( MaterialPageRoute(builder: (context) => InitativeInput(returnedCreatures: returnedCreatures)), );},
              )
            )
          ]
        )
      )
    );

  }

  Widget _buildList(BuildContext context, Axis direction) {
    return ListView.builder(
      scrollDirection: direction,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final Axis slidableDirection =
        direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
        return _getSlidableWithLists(context, index, slidableDirection);
      },
      itemCount: returnedCreatures.length,
    );
  }

  Widget _getSlidableWithLists(
      BuildContext context, int index, Axis direction) {
    final Creature item = returnedCreatures[index];
    //final int t = index;
    return Slidable(
      key: Key(item.Name),
      controller: slidableController,
      direction: direction,
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      child: VerticalListItem(returnedCreatures[index]),
      actions: <Widget>[
        new NumberPicker.integer(
            initialValue: numberPicker,
            itemExtent: 25,
            minValue: -100,
            maxValue: 100,
            onChanged: (newValue) => setState(() => numberPicker = newValue)),
        IconButton(
          icon: Icon(Icons.favorite_border),
          color: Colors.red,
          onPressed: () => _showSnackBar(context, numberPicker>0?'Healed for '+numberPicker.toString():'Damaged for '+numberPicker.toString()),
        ),
        IconSlideAction(
            caption: 'Delete',
            color: Colors.red,
            icon: Icons.delete,
            onTap: () => setState(() {returnedCreatures.removeAt(index); _showSnackBar(context,'Creature Deleted');})
        )
      ],
      secondaryActions: _getSliders(item, context),
    );
  }


  List<Widget> _getSliders(Creature item, BuildContext context) {
    int noOfSliders = item.getNoOfConsumableActions();
    if (noOfSliders<1)return null;
    List<Widget> sliders = new List<Widget>(noOfSliders);
    for (int i = 0; i < noOfSliders; i++) {
      sliders[i]=
      new Column(
          children: <Widget>[
            Text(item.ConsumableActions[i].Name),
            Expanded(child: NumberPicker.integer(
              highlightSelectedValue: true,
              initialValue: item.ConsumableActions[i].Value,
              itemExtent: 25,
              minValue: -100,
              maxValue: 100,
              onChanged: (newValue) => setState(() => item.ConsumableActions[i].Value = newValue))
            )
          ]
      );
    }
    return sliders;
  }

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class VerticalListItem extends StatelessWidget {
  VerticalListItem(this.item);
  final Creature item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
      Slidable.of(context)?.renderingMode == SlidableRenderingMode.none
          ? Slidable.of(context)?.open()
          : Slidable.of(context)?.close(),
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: item.getColour(),
            child: Icon(Icons.accessibility),
            foregroundColor: Colors.white,
          ),
          title: Text(item.Name),
          subtitle: Text(item.toString()),
        ),
      ),
    );
  }
}






