// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:movers_lorry_owner/AppConstData/typographyy.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/subdrivers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/managepage.dart';
import '../../AppConstData/routes.dart';
import '../../AppConstData/api_config.dart';
import '../../models/home_model.dart';
import '../../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = Get.put(HomePageController());
  MapController? _mapController;
  Position? _currentPosition;
  bool _isLocationLoading = true;
  
  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _getCurrentLocation();
    homePageController.getDataFromLocalData().then((value) {
      if (homePageController.userData != null && (homePageController.userData?.id?.isNotEmpty ?? false)) {
        homePageController.getHomePageData(uid: homePageController.userData!.id!);
      } else {
        homePageController.setIsLoading(false);
      }
      homePageController.setIcon(homePageController.verification12(homePageController.userData?.isVerify ?? ''));
      ManagePageCalling().setLogin(false);
    });
    ManagePageCalling().setLogin(false);
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLocationLoading = false;
      });

      // Move camera to current location if map controller is available
      if (_mapController != null && _currentPosition != null) {
        _mapController!.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          15.0,
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _searchNearbyFuelStations() async {
    // Navigate to the dedicated fuel stations screen
    Get.toNamed(Routes.fuelStations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<HomePageController>(
        builder: (homePageController) {
          if (homePageController.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (homePageController.userData == null || (homePageController.userData?.id?.isEmpty ?? true)) {
            // Redirect to login screen if no user is found
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.offAllNamed(Routes.loginScreen);
            });
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    homePageController.updateUserProfile(context);
                  },
                );
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(100),
                  child: AppBar(
                      toolbarHeight: 100,
                      backgroundColor: priMaryColor,
                      elevation: 0,
                      titleSpacing: 0,
                      title: Column(
                        children: [
                          ListTile(
                            dense: true,
                            leading: homePageController.userData?.proPic.toString() == "null"
                                ? const CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage(
                                      "assets/image/05.png",
                                    ),
                                    radius: 25,
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      "$basUrl${homePageController.userData?.proPic}",
                                    ),
                                    radius: 25,
                                    child: Image.network(
                                      "$basUrl${homePageController.userData?.proPic}",
                                      color: Colors.transparent,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return commonSimmer(height: 50, width: 50);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        return (loadingProgress == null)
                                            ? child
                                            : commonSimmer(height: 50, width: 50);
                                      },
                                    ),
                                  ),
                            trailing: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.notification);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                radius: 20,
                                child: SvgPicture.asset(
                                  "assets/icons/notification.svg",
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            title: Transform.translate(
                              offset: const Offset(0, -5),
                              child: Text(
                                "Hello..".tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontFamily: "urbani_regular",
                                ),
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  homePageController.userData?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontFamily: "urbani_extrabold",
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // User Role text styled like Find Loads button
                                if (homePageController.userData?.userRole != null)
                                  Text(
                                    'Role: ${homePageController.userData?.userRole}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "urbani_extrabold",
                                      fontSize: 14,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              color: priMaryColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Post your truck and get loads".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32,
                                      color: Color(0xff18FF13),
                                      fontFamily: "urbani_extrabold",
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          homePageController.homePageData?.homeData?.topMsg?.tr ?? '',
                                          style: const TextStyle(
                                            fontFamily: "urbani_extrabold",
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Transform.translate(
                                        offset: const Offset(0, -1),
                                        child: SvgPicture.asset(
                                          homePageController.verification!,
                                          height: 18,
                                          width: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Check if user is dispatcher or driver
                                        if (homePageController.userData?.userRole == 'dispatcher')
                                          // Dispatcher menu
                                          for (int a = 0; a < 4; a++)
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // Allow Create Order without verification (case 0)
                                                    if (a == 0) {
                                                      Get.toNamed(Routes.assignOrder);
                                                    } else if (homePageController.userData?.isVerify == "2") {
                                                      switch (a) {
                                                        case 1:
                                                          Get.to(Subdrivers()); // Manage Drivers
                                                          break;
                                                        case 2:
                                                          Get.toNamed(Routes.assignedOrders); // Order History
                                                          break;
                                                        case 3:
                                                          // Dashboard - stay on home page
                                                          break;
                                                      }
                                                    } else if (homePageController.userData?.isVerify == "1") {
                                                      if (("verification Under Process" ?? "").trim().isNotEmpty) {
                                                        showCommonToast("verification Under Process");
                                                      }
                                                    } else {
                                                      Get.toNamed(Routes.verifyIdentity);
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 40,
                                                    width: 110,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(12),
                                                      ),
                                                      border: Border.all(
                                                        color: Colors.white.withOpacity(0.8),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            homePageController.dispatcherMenuList[a].toString().tr,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: "urbani_extrabold",
                                                              fontSize: 14,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10)
                                              ],
                                            )
                                        else
                                          // Driver menu (existing)
                                          for (int a = 0; a < 4; a++)
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // Remove identity verification for Find Loads (case 0)
                                                    if (a == 0) {
                                                      // Allow Find Loads without verification
                                                      Get.toNamed(Routes.findLorry);
                                                    } else if (homePageController.userData?.isVerify == "2") {
                                                      switch (a) {
                                                        case 1:
                                                          Get.toNamed(Routes.nearLoad);
                                                          break;
                                                        case 2:
                                                          Get.toNamed(Routes.attachLorry);
                                                          break;
                                                        case 3:
                                                          Get.toNamed(Routes.assignedOrders);
                                                          break;
                                                        case 4:
                                                          Get.toNamed('/fuel-stations');
                                                          break;
                                                      }
                                                    } else if (homePageController.userData?.isVerify == "1") {
                                                      if (("verification Under Process" ?? "").trim().isNotEmpty) {
                                                        showCommonToast("verification Under Process");
                                                      }
                                                    } else {
                                                      Get.toNamed(Routes.verifyIdentity);
                                                    }
                                                  },
                                                child: Container(
                                                  height: 40,
                                                  width: 110,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(12),
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(0.8),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          homePageController.menuList[a].toString().tr,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: "urbani_extrabold",
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10)
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 2.0,
                            height: 200,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            viewportFraction: 1,
                            autoPlay: true,
                          ),
                          items: [
                            for (int a = 0; a < (homePageController.homePageData?.homeData?.banner?.length ?? 0); a++)
                              homePageController.homePageData?.homeData?.banner?[a].img?.isEmpty ?? true
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      enabled: true,
                                      child: Container(
                                        height: 200,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        "$basUrl${homePageController.homePageData?.homeData?.banner?[a].img ?? ''}",
                                        fit: BoxFit.cover,
                                        width: Get.width,
                                        errorBuilder: (context, error, stackTrace) {
                                          return commonSimmer(height: 200, width: Get.width);
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          return (loadingProgress == null)
                                              ? child
                                              : commonSimmer(height: 200,width: Get.width);
                                        },
                                      ),
                                    ),
                          ],
                        ),
                      ),
                      homePageController.homePageData?.homeData?.mylorrylist?.isNotEmpty ?? false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "My Lorry's".tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "urbani_extrabold",
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 125,
                                  width: Get.width,
                                  child: ListView.separated(
                                    clipBehavior: Clip.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        alignment: Alignment.topRight,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Image.network(
                                                      "$basUrl${homePageController.homePageData?.homeData?.mylorrylist?[index].lorryImg ?? ''}",
                                                      height: 70,
                                                      width: 90,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return commonSimmer(height: 58, width: 58);
                                                      },
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        return (loadingProgress == null)
                                                            ? child
                                                            : commonSimmer(height: 58, width: 58);
                                                      },
                                                    ),
                                                    Text(
                                                      "${homePageController.homePageData?.homeData?.mylorrylist?[index].lorryNo ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: textBlackColor,
                                                        fontFamily: fontFamilyBold,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(
                                                      "${homePageController.homePageData?.homeData?.mylorrylist?[index].lorryTitle ?? ''}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: textBlackColor,
                                                        fontFamily: fontFamilyBold,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/route.svg",
                                                          height: 22,
                                                          width: 22,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          "${homePageController.homePageData?.homeData?.mylorrylist?[index].routes?.toString() ?? ''} + Routs",
                                                          style: TextStyle(
                                                            color: textGreyColor,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          homePageController.homePageData?.homeData?.mylorrylist?[index].rcVerify == "2"
                                                              ? "assets/icons/ic_unverified.svg"
                                                              : "assets/icons/badge-check.svg",
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          homePageController.homePageData?.homeData?.mylorrylist?[index].rcVerify == '2'
                                                              ? "Document Reupload"
                                                              : "RC Verified",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: -5,
                                            top: -5,
                                            child: InkWell(
                                              onTap: () async {
                                                SharedPreferences preferences = await SharedPreferences.getInstance();
                                                Mylorrylist? data = homePageController.homePageData?.homeData?.mylorrylist?[index];

                                                Map editData = {
                                                  "lorryNo": data?.lorryNo,
                                                  "numberOfTones": data?.weight,
                                                  "vehicle": data?.lorryTitle,
                                                  "description": data?.description,
                                                  "isedite": true,
                                                  "statelist": data?.totalRoutes,
                                                  "record_id": data?.id
                                                };
                                                debugPrint("========== data ========= $data");
                                                debugPrint("======== editData ======= $editData");
                                                preferences.setString("EditLorryData",jsonEncode(editData));
                                                Get.toNamed(Routes.attachLorry);
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: priMaryColor,
                                                radius: 13,
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    "assets/icons/edit-2.svg",
                                                    color: Colors.white,
                                                    height: 14,
                                                    width: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(width: 10);
                                    },
                                    itemCount: homePageController.homePageData?.homeData?.mylorrylist?.length ?? 0,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          height: 300,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _isLocationLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Stack(
                                    children: [
                                      FlutterMap(
                                        mapController: _mapController ?? MapController(),
                                        options: MapOptions(
                                          initialCenter: _currentPosition != null
                                              ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                              : const LatLng(54.6872, 25.2797), // Fallback to Vilnius
                                          initialZoom: _currentPosition != null ? 15.0 : 10.0,
                                          onMapReady: () {
                                            // Move camera to current location if available
                                            if (_currentPosition != null && _mapController != null) {
                                              _mapController!.move(
                                                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                                15.0,
                                              );
                                            }
                                          },
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate: 'https://maps.hereapi.com/v3/maptile/newest/normal.traffic.day/{z}/{x}/{y}/256/png8?apikey=${ApiConfig.hereMapsApiKey}',
                                            userAgentPackageName: 'com.moverslorryowner.app',
                                          ),
                                          if (_currentPosition != null)
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                                  width: 80,
                                                  height: 80,
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    color: Colors.blue,
                                                    size: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                                                               // Fuel button positioned at bottom left of map
                                         Positioned(
                                           left: 26,
                                           bottom: 50,
                                           child: Row(
                                             children: [
                                               ElevatedButton(
                                                 onPressed: _searchNearbyFuelStations,
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: Colors.blue,
                                                   foregroundColor: Colors.white,
                                                   padding: EdgeInsets.all(16),
                                                   elevation: 4,
                                                   shape: CircleBorder(),
                                                 ),
                                                 child: Icon(Icons.local_gas_station),
                                               ),
                                               SizedBox(width: 8),
                                               ElevatedButton(
                                                 onPressed: () {
                                                   // TODO: Implement truck stops functionality
                                                 },
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: Colors.blue,
                                                   foregroundColor: Colors.white,
                                                   padding: EdgeInsets.all(16),
                                                   elevation: 4,
                                                   shape: CircleBorder(),
                                                 ),
                                                 child: Icon(Icons.local_shipping),
                                               ),
                                               SizedBox(width: 8),
                                               ElevatedButton(
                                                 onPressed: () {
                                                   // TODO: Implement weigh functionality
                                                 },
                                                 style: ElevatedButton.styleFrom(
                                                   backgroundColor: Colors.blue,
                                                   foregroundColor: Colors.white,
                                                   padding: EdgeInsets.all(16),
                                                   elevation: 4,
                                                   shape: CircleBorder(),
                                                 ),
                                                 child: Icon(Icons.scale),
                                               ),
                                             ],
                                           ),
                                         ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
