import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import '/models/location_data.dart';

class LocationPickerScreen extends StatefulWidget {
  final String title;

  const LocationPickerScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController mapController;
  final TextEditingController searchController = TextEditingController();
  List<SearchInfo> searchResults = [];
  bool isSearching = false;
  bool isMapReady = false;
  GeoPoint? selectedLocation;
  final GeoPoint defaultLocation = GeoPoint(latitude: 36.81292, longitude: 10.06189);
  String? selectedAddress;

  @override
  void initState() {
    super.initState();
    mapController = MapController(initPosition: defaultLocation);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeMap();
    });
  }

  Future<void> _initializeMap() async {
    try {
      await mapController.goToLocation(defaultLocation);
      final address = await addressFromGeoPoint(defaultLocation);
      setState(() {
        selectedLocation = defaultLocation;
        selectedAddress = address;
        isMapReady = true;
      });
    } catch (e) {
      print("Error initializing map: $e");
    }
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      var results = await addressSuggestion(query);
      setState(() {
        searchResults = results;
        isSearching = false;
      });
    } catch (e) {
      print("Error searching places: $e");
      setState(() {
        searchResults = [];
        isSearching = false;
      });
    }
  }

  Future<void> _handleLocationSelected(GeoPoint point, {String? address}) async {
    try {
      final locationAddress = address ?? await addressFromGeoPoint(point);

      await mapController.goToLocation(point);
      await mapController.addMarker(point);
      await mapController.drawRoad(
        defaultLocation,
        point,
        roadType: RoadType.car,
        roadOption: RoadOption(
          roadColor: Colors.blue,
          roadWidth: 5,
        ),
      );

      setState(() {
        selectedLocation = point;
        selectedAddress = locationAddress;
        searchResults = [];
        searchController.clear();
      });
    } catch (e) {
      print("Error handling location selection: $e");
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF1b4242),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
          children: [
      // Search Field
      Padding(
      padding: const EdgeInsets.all(12.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search location...',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _searchPlaces,
      ),
    ),

    // Search results dropdown
    if (searchResults.isNotEmpty)
    Container(
    margin: const EdgeInsets.symmetric(horizontal: 12),
    padding: const EdgeInsets.symmetric(vertical: 6),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
    ),
    child: ListView.separated(
    shrinkWrap: true,
    itemCount: searchResults.length,
    separatorBuilder: (_, __) => const Divider(height: 0),
    itemBuilder: (context, index) {
    return ListTile(
    title: Text(searchResults[index].address.toString()),
    onTap: () async {
    try {
    final point = await searchResults[index].point;
    if (point != null) {
    await _handleLocationSelected(
    point,
    address: searchResults[index].address.toString(),
    );
    }
    } catch (e) {
    print("Error selecting search result: $e");
    }
    },
    );
    },
    ),
    ),

    // Map view
    Expanded(
    child: Stack(
    children: [
    ClipRRect(
    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
    child: OSMFlutter(
    controller: mapController,
    osmOption: OSMOption(
    userTrackingOption: UserTrackingOption(
    enableTracking: true,
    unFollowUser: true,
    ),
    zoomOption: ZoomOption(
    initZoom: 15,
    minZoomLevel: 3,
    maxZoomLevel: 19,
    ),
    userLocationMarker: UserLocationMaker(
    personMarker: MarkerIcon(
    icon: Icon(Icons.location_history_rounded, color: Colors.blue, size: 48),
    ),
    directionArrowMarker: MarkerIcon(
    icon: Icon(Icons.navigation, color: Colors.blue, size: 48),
    ),
    ),
    roadConfiguration: RoadOption(roadColor: Colors.blueAccent),
    markerOption: MarkerOption(
    defaultMarker: MarkerIcon(
    icon: Icon(Icons.location_pin, color: Colors.red, size: 56),
    ),
    ),
    ),
    onMapIsReady: (ready) {
    if (ready && !isMapReady) {
    _initializeMap();
    }
    },
    onGeoPointClicked: (point) async {
    await _handleLocationSelected(point);
    },
    mapIsLoading: const Center(child: CircularProgressIndicator()),
    ),
    ),

    // Address card
    if (selectedAddress != null)
    Positioned(
    bottom: 90,
    left: 20,
    right: 20,
    child: Material(
    elevation: 4,
    borderRadius: BorderRadius.circular(12),
    child: Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
    selectedAddress!,
    textAlign: TextAlign.center,
    style: const TextStyle(fontSize: 14),
    ),
    ),
    ),
    ),
    ],
    ),
    ),

    // Confirm button
    // Confirm small check button
    if (selectedLocation != null && selectedAddress != null)
    Positioned(
    bottom: 20,
    right: 20,
    child: FloatingActionButton(
    backgroundColor: const Color(0xFF1b4242),
    onPressed: () {
    Navigator.pop(
    context,
    Location(
    latitude: selectedLocation!.latitude,
    longitude: selectedLocation!.longitude,
    nameLocation: selectedAddress!,
    ),
    );
    },
    child: const Icon(Icons.check, color: Colors.white),
    ),
    ),

    ],
    ),
    );
  }
}

Future<String> addressFromGeoPoint(GeoPoint point) async {
  try {
    final addresses = await addressSuggestion("${point.latitude},${point.longitude}");
    if (addresses.isNotEmpty) {
      String fullAddress = addresses.first.address.toString();
      List<String> parts = fullAddress.split(',').map((e) => e.trim()).toList();
      String cleanAddress = parts.take(3).join(', ');
      return cleanAddress;
    }
  } catch (e) {
    print("Error getting address: $e");
  }
  return "Location near ${point.latitude.toStringAsFixed(4)}, ${point.longitude.toStringAsFixed(4)}";
}