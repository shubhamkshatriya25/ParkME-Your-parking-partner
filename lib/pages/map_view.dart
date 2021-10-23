import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parkme/booking/Booking_Confirmation.dart';
import 'package:parkme/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  CameraPosition _initialLocation =
  CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 5);
  GoogleMapController mapController;
  final Geolocator _geolocator = Geolocator();
  Position _currentPosition;
  final myController = TextEditingController();
  bool _showClearButton = false;
  Set<Marker> markers = {};
  BitmapDescriptor _mapMarker;
  BuildContext mContext;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void dispose() {
    myController.dispose();
    super.dispose();
  }

  void customMarker() async {
    _mapMarker = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(), 'assets/images/parkmeIcon.png');
  }

  void closeModal() {
    Navigator.pop(mContext);
  }

  void addMarkers() async {
    //List _spots;
     await firestore
        .collection('parkingCenters')
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((spot) async {
        List<Placemark> marker =
            await _geolocator.placemarkFromAddress(spot['address']);
        Position markerCoordinates = marker[0].position;
        Marker destinationMarker = Marker(
          onTap: () {
            showModalBottomSheet<void>(
              context: context,
              builder: (BuildContext context) {
                mContext = context;
                return Container(
                  width: MediaQuery.of(context).size.width,
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10)),
                    color: Colors.white70,
                  ),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Hero(
                                  tag: 'centerName',
                                  child: Text(
                                    spot['name'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: kprimaryColor,
                                        fontSize: 20),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 15,
                                    ),
                                    Text(spot['address']),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        IntrinsicHeight(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '\u{20B9} ${spot['costPerHour']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text('per hour')
                                  ],
                                ),
                                VerticalDivider(
                                  thickness: 2,
                                  width: 20,
                                  color: Colors.black26,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (spot['totalSpots'] -
                                          spot['occupiedSpots'])
                                          .toString(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text('seats left')
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: FlatButton(
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(5.0)),
                            padding: EdgeInsets.all(10),
                            splashColor: Colors.blue,
                            color: kprimaryColor,
                            child: const Text(
                              'RESERVE',
                              style: TextStyle(color: Colors.white, fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) {
                                    return BookingConfirmation(
                                      spot: spot,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
          // Plotting the marker
          markerId: MarkerId('$markerCoordinates'),
          position: LatLng(
            markerCoordinates.latitude,
            markerCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: spot['name'],
          ),
          icon: _mapMarker,
        );
        markers.add(destinationMarker);
      });
    });
  }

  _updateLocation(address) async {
    List<Placemark> destinationPlacemark =
        await _geolocator.placemarkFromAddress(address);
    Position destinationCoordinates = destinationPlacemark[0].position;

    setState(() {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(destinationCoordinates.latitude,
                destinationCoordinates.longitude),
            zoom: 15.0,
          ),
        ),
      );
    });
  }

  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 15.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getClearButton() {
    if (!_showClearButton) {
      return null;
    }
    return IconButton(
      onPressed: () => myController.clear(),
      icon: Icon(Icons.clear),
    );
  }

  @override
  void initState() {
    super.initState();
    customMarker();
    _getCurrentLocation();
    addMarkers();
    myController.addListener(() {
      setState(() {
        _showClearButton = myController.text.length > 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: _initialLocation,
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: kprimaryColor,
                      child: InkWell(
                        splashColor: Colors.blue,
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location, color: kBtnTextColor),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 15.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: myController,
                  onSubmitted: (text) => _updateLocation(myController.text),
                  style: TextStyle(
                    fontSize: 18,
                  ),
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 18),
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Search here',
                    suffixIcon: _getClearButton(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 0, color: Colors.white),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
