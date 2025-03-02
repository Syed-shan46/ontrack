import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class HomeHeader extends ConsumerStatefulWidget {
  const HomeHeader({
    super.key,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader> {
  @override
  void initState() {
    super.initState();
    checkPermission();

    // Listen for location service status changes
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        // If location service is turned on, fetch the location
        getLocation();
      }
    });
  }

  final Color myColor = const Color.fromRGBO(128, 178, 247, 1);
  String coordinates = "No Location found";
  String address = 'No Address found';
  bool scanning = false;

  LatLng? currentLocation; // For map center and marker

  // Check permissions and fetch location
  Future<void> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: 'Location services are disabled.');
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: 'Location permissions are permanently denied.');
      return;
    }

    getLocation();
  }

  // Get the current location and update the UI
  Future<void> getLocation() async {
    setState(() {
      scanning = true;
    });

    try {
      // Use locationSettings for specifying accuracy
      LocationSettings locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        coordinates =
            'Latitude: ${position.latitude} \nLongitude: ${position.longitude}';
      });

      // Call Nominatim API to get address
      await fetchAddressFromNominatim(position.latitude, position.longitude);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
      print("Error: ${e.toString()}");
    }

    setState(() {
      scanning = false;
    });
  }

  // Fetch address using Nominatim API
  Future<void> fetchAddressFromNominatim(
      double latitude, double longitude) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          address = data['display_name'] ?? 'No Address Found';
        });
      } else {
        Fluttertoast.showToast(msg: 'Failed to fetch address from Nominatim.');
        print('Error: ${response.body}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error: ${e.toString()}');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, top: 5.h, bottom: 2.h),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              ref.read(userProvider.notifier).logout();
            },
            icon: Icon(
              AntDesign.menu_unfold,
              color: ThemeUtils.dynamicTextColor(context),
            ),
          ),
          Icon(
            Icons.home,
            color: AppColors.primaryColor,
            size: 17.sp,
          ),
          // Left side with welcome title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Adjusts height to fit content
              children: [
                scanning
                    ? const SpinKitThreeBounce(
                        color: AppColors.primaryColor, size: 10)
                    : Text(
                        address,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_forward,
            size: 12.sp,
          ),
          // Cart icon on the right side
          Padding(
            padding: const EdgeInsets.only(right: 5), // Consistent padding
            child: Text(
              getTimeOfDay(),
              style: const TextStyle(fontSize: 25),
            ),
          ),
        ],
      ),
    );
  }

  String getTimeOfDay() {
    DateTime now = DateTime.now();
    int hour = now.hour;

    if (hour >= 0 && hour < 12) {
      return ' ☀️ ';
    } else if (hour >= 12 && hour < 16) {
      return ' ⛅ ';
    } else {
      return ' 🌙 ';
    }
  }
}
