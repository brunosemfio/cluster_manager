import 'package:cluster_manager/src/cluster_item.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class Cluster<T extends ClusterItem> {
  Cluster(this.items, {required this.location});

  Cluster.fromItems(this.items)
      : location = LatLng(
          items.fold<double>(0.0, (t, c) => t + c.location.latitude) /
              items.length,
          items.fold<double>(0.0, (t, c) => t + c.location.longitude) /
              items.length,
        );

  final List<T> items;

  final LatLng location;

  String get id => '${location.latitude}_${location.longitude}_$count';

  T get first => items.first;

  int get count => items.length;

  bool get isMultiple => count > 1;

  @override
  bool operator ==(Object other) => other is Cluster<T> && other.id == id;

  @override
  int get hashCode => items.hashCode ^ location.hashCode;
}
