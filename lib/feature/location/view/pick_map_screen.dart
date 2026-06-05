import 'package:demandium_provider/util/core_export.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class PickMapScreen extends StatefulWidget {
  final LatLng? initialPosition;
  final String? initialAddress;
  final Completer<GoogleMapController>? googleMapController;
  const PickMapScreen({
    super.key,
    this.initialPosition,
    this.initialAddress,
    this.googleMapController,
  });

  @override
  State<PickMapScreen> createState() => _PickMapScreenState();
}

class _PickMapScreenState extends State<PickMapScreen> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();
    final config = Get.find<SplashController>().configModel.content;
    final defaultLat = config?.defaultLocation?.defaultLocation?.lat ?? 23.777176;
    final defaultLon = config?.defaultLocation?.defaultLocation?.lon ?? 90.399452;

    _initialPosition = widget.initialPosition ??
        LatLng(
          defaultLat,
          defaultLon,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'address'.tr),
      body: SafeArea(
        child: GetBuilder<LocationController>(
          builder: (locationController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      SizedBox.expand(
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _initialPosition,
                            zoom: 16,
                          ),
                          minMaxZoomPreference: const MinMaxZoomPreference(0, 20),
                          onMapCreated: (GoogleMapController mapController) {
                            _mapController = mapController;
                            Get.find<LocationController>().initializePickMapPosition(
                              _initialPosition,
                              mapController: mapController,
                            );
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          myLocationEnabled: true,
                          onCameraMove: (CameraPosition cameraPosition) {
                            _cameraPosition = cameraPosition;
                          },
                          onCameraMoveStarted: () {
                            locationController.disableButton();
                          },
                          onCameraIdle: () {
                            if (_cameraPosition != null) {
                              try {
                                Get.find<LocationController>().updatePosition(_cameraPosition!);
                              } catch (e) {
                                if (kDebugMode) {
                                  print(e);
                                }
                              }
                            }
                          },
                        ),
                      ),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(Images.marker, height: 50, width: 50),
                            if (locationController.loading)
                              Positioned(
                                top: -36,
                                child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: Dimensions.paddingSizeLarge,
                        left: Dimensions.paddingSizeSmall,
                        right: Dimensions.paddingSizeSmall,
                        child: InkWell(
                          onTap: () {
                            if (_mapController == null) {
                              showCustomSnackBar('please_wait'.tr, type: ToasterMessageType.info);
                              return;
                            }
                            showCustomDialog(
                              child: LocationSearchDialog(mapController: _mapController!),
                              barrierDismissible: true,
                            );
                          },
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 25,
                                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Expanded(
                                  child: Text(
                                    (locationController.pickAddress.address?.isNotEmpty ?? false)
                                        ? locationController.pickAddress.address!
                                        : (widget.initialAddress ?? 'search_location'.tr),
                                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                                Icon(
                                  Icons.search,
                                  size: 25,
                                  color: Theme.of(context).textTheme.bodyLarge!.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 80,
                        right: Dimensions.paddingSizeSmall,
                        child: FloatingActionButton(
                          hoverColor: Colors.transparent,
                          mini: true,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          onPressed: () => _checkPermission(() {
                            Get.find<LocationController>().getCurrentLocation(
                              false,
                              mapController: _mapController,
                            );
                          }),
                          child: Icon(Icons.my_location, color: Theme.of(context).cardColor),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeSmall,
                    Dimensions.paddingSizeDefault,
                  ),
                  child: CustomButton(
                    fontSize: Dimensions.fontSizeDefault,
                    btnTxt: 'pick_address'.tr,
                    onPressed: locationController.loading
                        ? null
                        : () {
                            if (locationController.pickPosition.latitude != 0 &&
                                (locationController.pickAddress.address?.isNotEmpty ?? false)) {
                              Get.back();
                            } else {
                              showCustomSnackBar('pick_an_address'.tr, type: ToasterMessageType.info);
                            }
                          },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr, type: ToasterMessageType.info);
    } else if (permission == LocationPermission.deniedForever) {
      showCustomDialog(child: const PermissionDialog(), barrierDismissible: true);
    } else {
      onTap();
    }
  }
}
