import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

abstract class ClusterItem {
  LatLng get location;
  String get geohash;
}
