import 'package:flutter/material.dart';
import 'package:Space/screens/home/activity_list/activity_botton.dart';

class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {

  var targetWidget = List<Widget>();

  void _search(){
    showModalBottomSheet(
      context: context ,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0), 
        topRight: Radius.circular(15.0)),
      ),
      builder: (context){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            //SizedBox(height: 20.0,),
            Container(
              padding: EdgeInsets.all(20.0),
              child: TextFormField(
                onChanged: (val)=>{

                },
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  prefixIcon: Icon(Icons.search),
                  hintText: "Search",
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(//SingleChildScrollView做水平捲軸比較好控制，垂直捲軸用ListView
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.0, 0, 4.0, 20.0),
            child:FlatButton(
              padding: EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 60.0,
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.add)
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 20.0),
            child:FlatButton(
              padding: EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 60.0,
              minWidth: 130.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{_search()}, 
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Icon(Icons.search),
                  Container(width: 10, height: 10.0,),
                  Text("Search", style: TextStyle(fontSize:16.0),),
                ],
              )
            ),
          ),
          ActivityButton(category: Icons.directions_car),
          ActivityButton(category: Icons.free_breakfast),
          ActivityButton(category: Icons.help),
          ActivityButton(category: Icons.hotel),
          ActivityButton(category: Icons.movie),
          ActivityButton(category: Icons.school),                                   
        ]
      ),
    );
  }
}