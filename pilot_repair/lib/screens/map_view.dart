import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MapViewPage extends StatefulWidget {
  final String? initialAddress;
  final LatLng? initialPosition;

  const MapViewPage({
    super.key,
    this.initialAddress,
    this.initialPosition,
  });

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  LatLng? _selectedPosition;
  String? _selectedAddress;
  bool _isLoading = false;

  // Koordinat pusat Jogja
  final LatLng _jogjaCenter = const LatLng(-7.7956, 110.3695);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLat = prefs.getDouble('last_lat');
      final savedLng = prefs.getDouble('last_lng');

      if (savedLat != null && savedLng != null) {
        // Kedua kali dan seterusnya → pakai lokasi terakhir
        _selectedPosition = LatLng(savedLat, savedLng);
        _currentPosition = _selectedPosition;
        _selectedAddress =
            await _getAddressFromCoordinates(_selectedPosition!);
      } else {
        // Pertama kali → ambil lokasi terkini
        _currentPosition = await _getCurrentLocation();
        if (_currentPosition != null) {
          _selectedPosition = _currentPosition;
          _selectedAddress =
              await _getAddressFromCoordinates(_currentPosition!);
        }
      }
    } catch (e) {
      print('Error initializing map: $e');
      _currentPosition = const LatLng(-6.2088, 106.8456); // Jakarta fallback
      _selectedPosition = _currentPosition;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveLastLocation(LatLng position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('last_lat', position.latitude);
    await prefs.setDouble('last_lng', position.longitude);
  }

  Future<LatLng?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<String?> _getAddressFromCoordinates(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];

        if (place.street?.isNotEmpty ?? false) {
          addressParts.add(place.street!);
        }
        if (place.subLocality?.isNotEmpty ?? false) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty ?? false) {
          addressParts.add(place.locality!);
        }
        if (place.subAdministrativeArea?.isNotEmpty ?? false) {
          addressParts.add(place.subAdministrativeArea!);
        }
        if (place.administrativeArea?.isNotEmpty ?? false) {
          addressParts.add(place.administrativeArea!);
        }

        return addressParts.join(', ');
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      return null;
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng position) async {
    setState(() => _selectedPosition = position);

    final address = await _getAddressFromCoordinates(position);
    setState(() => _selectedAddress = address);

    _saveLastLocation(position); // simpan lokasi setiap kali pilih
  }

  void _getCurrentLocationAndCenter() async {
    setState(() => _isLoading = true);

    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentPosition = position;
          _selectedPosition = position;
        });

        _mapController.move(position, 15.0);

        final address = await _getAddressFromCoordinates(position);
        setState(() => _selectedAddress = address);

        _saveLastLocation(position);
      }
    } catch (e) {
      print('Error getting current location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF16A07A)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peta Lokasi',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF16A07A)),
            onPressed: _getCurrentLocationAndCenter,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter:
                    _selectedPosition ?? const LatLng(-6.2088, 106.8456),
                initialZoom: 15.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'pilot_repair_app',
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _jogjaCenter,
                      color: Colors.blue.withOpacity(0.1),
                      borderStrokeWidth: 1,
                      borderColor: Colors.blue,
                      useRadiusInMeter: true,
                      radius: 10000,
                    ),
                  ],
                ),
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF16A07A).withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF16A07A),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Color(0xFF16A07A),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (_selectedPosition != null &&
                    _selectedPosition != _currentPosition)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedPosition!,
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (_selectedAddress != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lokasi Terpilih:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedAddress!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_selectedPosition != null) {
                          final distance = Distance();
                          final double meterDistance =
                              distance(_jogjaCenter, _selectedPosition!);

                          if (meterDistance > 10000) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text("Di luar radius layanan"),
                                content: const Text(
                                  "Lokasi ini berada di luar layanan kami.\n"
                                  "Harap pilih lokasi yang berada dalam radius 10 km dari pusat Jogja.",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }
                        }

                        Navigator.pop(context, {
                          'address': _selectedAddress,
                          'position': _selectedPosition,
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A07A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Pilih Lokasi Ini',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
