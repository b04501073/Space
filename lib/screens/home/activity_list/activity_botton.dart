import 'package:flutter/material.dart';

class ActivityButton extends StatelessWidget {
  final IconData category;

  const ActivityButton(this.category);

  @override
  Widget build(BuildContext context) {
    return _buildActivityButton(this.category);
  }

  Widget _buildActivityButton(IconData category){
    return Padding(
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
        child: Icon(category),
      ),
    );
  }
}