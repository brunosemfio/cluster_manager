import 'dart:developer';

import 'package:cluster_manager/src/cluster.dart';
import 'package:cluster_manager/src/cluster_item.dart';
import 'package:collection/collection.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class ClusterManager<T extends ClusterItem> {
  ClusterManager(
    this._items, {
    required this.markerBuilder,
    required this.updateMarkers,
    this.zooms = const [2, 3, 6, 9, 11.5, 13.5, 15, 15.5, 16],
    this.extraPercent = 0.5,
  });

  final List<T> _items;

  final Future<Marker> Function(Cluster<T> cluster) markerBuilder;

  final void Function(Set<Marker> markers) updateMarkers;

  final List<double> zooms;

  final double extraPercent;

  late int _mapId;

  void setMapId(int mapId) async {
    _mapId = mapId;
    updateMap();
  }

  void updateMap() async {
    final clusters = await _calculateClusters();
    final markers = await _visibleMarkers(clusters);
    updateMarkers(Set.from(markers));
  }

  Future<List<Cluster<T>>> _calculateClusters() async {
    final zoom = await GoogleMapsFlutterPlatform.instance.getZoomLevel(
      mapId: _mapId,
    );

    final precision = _precisionByZoom(zoom);

    log('zoom: $zoom :: precision: $precision');

    final groups = _items.groupListsBy(
      (item) => item.geohash.substring(0, precision),
    );

    return groups.values.map(Cluster.fromItems).toList();
  }

  Future<List<Marker>> _visibleMarkers(List<Cluster<T>> clusters) async {
    var bounds = await GoogleMapsFlutterPlatform.instance.getVisibleRegion(
      mapId: _mapId,
    );

    bounds = _inflateBounds(bounds);

    final visible = clusters.where(
      (cluster) => bounds.contains(cluster.location),
    );

    final markers = await Future.wait(visible.map(markerBuilder));

    return markers;
  }

  int _precisionByZoom(double zoom) {
    for (var i = zooms.length - 1; i >= 0; i--) {
      if (zooms[i] <= zoom) {
        return i + 1;
      }
    }

    return 1;
  }

  LatLngBounds _inflateBounds(LatLngBounds bounds) {
    double north = bounds.northeast.latitude;
    double south = bounds.southwest.latitude;
    double east = bounds.northeast.longitude;
    double west = bounds.southwest.longitude;

    return LatLngBounds(
      southwest: LatLng(
        south - (north - south) * extraPercent,
        west - (east - west) * extraPercent,
      ),
      northeast: LatLng(
        north + (north - south) * extraPercent,
        east + (east - west) * extraPercent,
      ),
    );
  }
}
