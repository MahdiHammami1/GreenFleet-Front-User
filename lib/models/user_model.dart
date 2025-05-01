import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../dto/FriendChatDto.dart';
import '../dto/RideDTO.dart';
import '../dto/VehicleDTO.dart';
import 'booking_response_data.dart';
class UserModel with ChangeNotifier {
  Map<String, dynamic>? _user;
  String? _token;
  List<RideDTO> rides = [];
  List<VehicleDTO> vehicles = [];
  List<BookingResponseDto> bookings = [];
  List<FriendChatDTO> friends = [];



  bool isLoading = false;

  Timer? _autoRefreshTimer;

  Map<String, dynamic>? get user => _user;
  String? get token => _token;
  List<FriendChatDTO> get getFriends => friends;

  void updateUser(Map<String, dynamic> updatedUser) {
    _autoRefreshTimer?.cancel();
    _user = updatedUser;
    notifyListeners();
  }

  Future<void> setUserData(Map<String, dynamic> user, String token) async {
    //('Setting user data: $user');
    _user = user;
    _token = token;
    isLoading = true;
    notifyListeners();

    //('Starting to fetch rides and vehicles...');
    try {
      // Wait for both fetches to complete
      await Future.wait([
        _fetchRides(),
        _fetchVehicles(),
        _fetchBookings(),
        _fetchFriends(),
      ]);
      //('Finished fetching rides and vehicles');
      //('Final rides count: ${rides.length}');
      //('Final vehicles count: ${vehicles.length}');
      //('Final bookings count: ${bookings.length}');
    } catch (e) {
      //('Error in setUserData: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
    _startAutoRefresh();
  }

  Future<void> refreshBookings() async {
    await _fetchBookings();
  }

  // Getter for rides
  List<RideDTO> get getRides => rides;

  // Getter for vehicles
  List<VehicleDTO> get getVehicles => vehicles;

  List<BookingResponseDto> get getBookings => bookings;

  Future<void> _fetchRides() async {
    //('Starting _fetchRides()');
    if (_user == null) {
      //('_user is null, returning');
      return;
    }

    if (_user!['publishedRides'] == null) {
      //('publishedRides is null, returning');
      return;
    }

    //('publishedRides: ${_user!['publishedRides']}');
    List<RideDTO> fetchedRides = [];

    for (var rideId in _user!['publishedRides']) {
      //('Fetching ride with ID: $rideId');
      try {
        var rideResponse = await _getRideById(rideId);
        if (rideResponse != null) {
          //('Successfully fetched ride: ${rideResponse.rideId}');
          fetchedRides.add(rideResponse);
        } else {
          //('Failed to fetch ride with ID: $rideId');
        }
      } catch (e) {
        //('Error fetching ride $rideId: $e');
      }
    }

    //('Total rides fetched: ${fetchedRides.length}');
    rides = fetchedRides;
    notifyListeners();
  }

  Future<RideDTO?> _getRideById(int rideId) async {
    try {
      final url = Uri.parse('http://localhost:8080/rides/$rideId');
      ////('Sending GET request to: $url');

      // Add authorization header with bearer token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      ////('Request headers: $headers');
      final response = await http.get(url, headers: headers);

      //('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        //('Response body: ${JsonEncoder.withIndent('  ').convert(jsonDecode(response.body))}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final ride = jsonDecode(decodedBody);


        //('YOYOYOYOYOY:\n${JsonEncoder.withIndent('  ').convert(ride)}');

        // Tu peux aussi inspecter manuellement certains champs :
        //('Preferences field: ${ride["preferences"]}');
        //('Stopovers field: ${ride["stopovers"]}');
        //('Booking field: ${ride["booking"]}');



        return RideDTO.fromJson(ride);
      } else {
        //('Error response: ${response.body}');
      }
    } catch (e) {
      //('Exception in _getRideById: $e');
    }
    return null;
  }

  Future<void> _fetchVehicles() async {
    //('Starting _fetchVehicles()');
    if (_user == null) {
      //('_user is null, returning');
      return;
    }

    if (_user!['vehicles'] == null) {
      //('vehicles is null, returning');
      return;
    }

    //('vehicles: ${_user!['vehicles']}');
    List<VehicleDTO> fetchedVehicles = [];

    for (var vehicleId in _user!['vehicles']) {
      //('Fetching vehicle with ID: $vehicleId');
      try {
        var vehicleResponse = await _getVehicleById(vehicleId);
        if (vehicleResponse != null) {
          //('Successfully fetched vehicle: ${vehicleResponse.vehicleId}');
          fetchedVehicles.add(vehicleResponse);
        } else {
          //('Failed to fetch vehicle with ID: $vehicleId');
        }
      } catch (e) {
        //('Error fetching vehicle $vehicleId: $e');
      }
    }

    //('Total vehicles fetched: ${fetchedVehicles.length}');
    vehicles = fetchedVehicles;
    notifyListeners();
  }

  Future<VehicleDTO?> _getVehicleById(int vehicleId) async {
    try {
      final url = Uri.parse('http://localhost:8080/vehicles/$vehicleId');
      //('Sending GET request to: $url');

      // Add authorization header with bearer token
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      //('Request headers: $headers');
      final response = await http.get(url, headers: headers);

      //('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        //('Response body: ${JsonEncoder.withIndent('  ').convert(jsonDecode(response.body))}');
        final decodedBody = utf8.decode(response.bodyBytes);
        final vehicleData = jsonDecode(decodedBody);

        return VehicleDTO.fromJson(vehicleData);
      } else {
        //('Error response: ${response.body}');
      }
    } catch (e) {
      //('Exception in _getVehicleById: $e');
    }
    return null;
  }

  Future<void> _fetchBookings() async {
    //('Starting _fetchBookings()');
    if (_user == null || _user!['userId'] == null) return;

    final userId = _user!['userId'];
    final url = Uri.parse('http://localhost:8080/bookings/user/$userId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        bookings = responseData.map((booking) => BookingResponseDto.fromJson(booking)).toList();
        //('Fetched ${bookings.length} bookings.');
        bookings.forEach((booking) {
          //(booking);
        });

      } else {
        //('Failed to fetch bookings. Status: ${response.statusCode}');
      }
    } catch (e) {
      //('Exception in _fetchBookings: $e');
    }
    notifyListeners();
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();

    _autoRefreshTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //('Auto-refreshing...');
      try {
        await Future.wait([
          _fetchRides(),
          _fetchVehicles(),
          _fetchBookings(),
          _fetchFriends()
        ]);
      } catch (e) {
        //('Error during auto-refresh: $e');
      }
    });
  }

  Future<void> _fetchFriends() async {
    if (_user == null || _user!['userId'] == null) return;

    final userId = _user!['userId'];
    final url = Uri.parse('http://localhost:8080/messages/friends/$userId');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        friends = data.map((e) => FriendChatDTO.fromJson(e)).toList();
      } else {
        print('Failed to fetch friends: ${response.statusCode}');
      }
    } catch (e) {
        print('Exception while fetching friends: $e');
    }

    notifyListeners();
  }


}

// rideId -> list of booking ->



/*

   -Enit         Start

   -Beb saadoun   arrived     (passengerId , rideId)

   -Ensi(entreprise)   arrived

 */











