import 'package:flutter/material.dart';

class ActivityList extends StatefulWidget {
  @override
  _ActivityListState createState() => _ActivityListState();
}

class _ActivityListState extends State<ActivityList> {
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
              onPressed: ()=>{
                //showModalBottomSheet(context: null, builder: null)
              }, 
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
          Padding(
            padding: EdgeInsets.fromLTRB(4.0, 0, 4.0, 20.0),
            child:FlatButton(
              padding: EdgeInsets.all(5.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              height: 60.0,
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.directions_car)
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
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.free_breakfast)
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
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.help)
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
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.hotel)
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
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.movie)
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
              minWidth: 60.0,
              color:  Colors.orange.withOpacity(0.7),            
              onPressed: ()=>{}, 
              child: Icon(Icons.school)
            ),
          ),                                     
        ]
      ),
    );
  }
}