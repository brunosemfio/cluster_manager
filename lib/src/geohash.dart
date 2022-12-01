import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class GeoHash {
  final _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  String encode(double latitude, double longitude, {int precision = 9}) {
    List<String> chars = [];

    bool isEven = true;

    int bits = 0, index = 0;

    double maxLat = 90, minLat = -90, maxLng = 180, minLng = -180, mid;

    while (chars.length < precision) {
      if (isEven) {
        mid = (maxLng + minLng) / 2;
        if (longitude > mid) {
          index = (index << 1) + 1;
          minLng = mid;
        } else {
          index = (index << 1) + 0;
          maxLng = mid;
        }
      } else {
        mid = (maxLat + minLat) / 2;
        if (latitude > mid) {
          index = (index << 1) + 1;
          minLat = mid;
        } else {
          index = (index << 1) + 0;
          maxLat = mid;
        }
      }

      isEven = !isEven;

      if (++bits == 5) {
        chars.add(_base32[index]);
        bits = 0;
        index = 0;
      }
    }

    return chars.join('');
  }

  LatLng decode(String hashString) {
    final bounds = _bounds(hashString);
    final lat = (bounds[0] + bounds[2]) / 2;
    final lng = (bounds[1] + bounds[3]) / 2;
    return LatLng(lat, lng);
  }

  List<double> _bounds(String hashString) {
    bool isEven = true;

    double maxLat = 90, minLat = -90, maxLng = 180, minLng = -180, mid;

    int index = 0;

    for (var i = 0, l = hashString.length; i < l; i++) {
      final code = hashString[i].toLowerCase();

      index = _base32.indexOf(code);

      for (var bits = 4; bits >= 0; bits--) {
        var bit = (index >> bits) & 1;

        if (isEven) {
          mid = (maxLng + minLng) / 2;
          if (bit == 1) {
            minLng = mid;
          } else {
            maxLng = mid;
          }
        } else {
          mid = (maxLat + minLat) / 2;
          if (bit == 1) {
            minLat = mid;
          } else {
            maxLat = mid;
          }
        }
        isEven = !isEven;
      }
    }
    return [minLat, minLng, maxLat, maxLng];
  }
}
