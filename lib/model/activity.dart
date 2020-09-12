import 'package:Space/model/user.dart';
import 'package:location/location.dart';

class Activity {
  final User author;
  final String title;
  final DateTime tarDate;
  final DateTime creDate;
  final LocationData loc;
   
  Activity({ this.author,
    this.title,
    this.tarDate,
    this.creDate,
    this.loc });
}
