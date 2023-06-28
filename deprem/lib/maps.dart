import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  List<Marker> markers = [];

  @override
  void initState() {
    super.initState();
    fetchMapData();
  }

  void fetchMapData() async {
    final url = Uri.parse(
        'https://www.emsc-csem.org/service/api/1.6/get.geojson?type=full');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final features = data['features'];

      for (var feature in features) {
        final coordinates = feature['geometry']['coordinates'];
        final latLng = LatLng(coordinates[1], coordinates[0]);
        final marker = Marker(
          markerId: MarkerId(feature['id'].toString()),
          position: latLng,
          infoWindow: InfoWindow(
            title: feature['properties']['place'].toString(),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarkerDetailsPage(feature: feature),
              ),
            );
          },
        );
        markers.add(marker);
      }

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Harita'),
      ),
      body: GoogleMap(
        onMapCreated: (controller) {
          mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: LatLng(39.9208, 32.8541), // Türkiye'nin koordinatları
          zoom: 6.0, // Yakınlaştırma seviyesi
        ),
        markers: markers.toSet(),
      ),
    );
  }
}

class MarkerDetailsPage extends StatelessWidget {
  final dynamic feature;

  MarkerDetailsPage({this.feature});

  @override
  Widget build(BuildContext context) {
    final place = feature['properties']['place'].toString();
    final description = feature['properties']['magnitude'].toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Deprem Detayları'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              place,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
