import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../models/food_resource.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  late Future<List<FoodResource>> _futureResources;
  final TextEditingController _searchController = TextEditingController();
  List<FoodResource> _allResources = [];
  String _searchQuery = '';
  Position? _userPosition;

  @override
  void initState() {
    super.initState();
    _futureResources = loadResourcesFromJson();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    setState(() => _userPosition = position);
  }

  Future<List<FoodResource>> loadResourcesFromJson() async {
    final jsonString = await DefaultAssetBundle.of(context).loadString('assets/data/resources.json');
    final List jsonData = json.decode(jsonString);
    final parsed = jsonData.map((e) => FoodResource.fromJson(e)).toList();
    setState(() => _allResources = parsed);
    return parsed;
  }

  double? _calculateDistance(double? lat, double? lon) {
    if (_userPosition == null || lat == null || lon == null) return null;
    const earthRadius = 6371;
    final dLat = _deg2rad(lat - _userPosition!.latitude);
    final dLon = _deg2rad(lon - _userPosition!.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(_userPosition!.latitude)) *
            cos(_deg2rad(lat)) *
            sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  void _launchURL(String? url) async {
    if (url == null || url.isEmpty || !url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid website available.")),
      );
      return;
    }

    final uri = Uri.parse(url);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception("Could not launch $url");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open site: $e")),
      );
    }
  }

  void _launchMaps(String address) async {
    print("Launching address: $address");
    final testAddress = "219 E 1st St, Duluth, MN 55802";
    final testUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(testAddress)}';
    final uri = Uri.parse(testUrl);

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
          throw Exception("Could not launch map.");
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to open map: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Resources')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search by name or type...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<FoodResource>>(
              future: _futureResources,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading resources."));
                } else if (_allResources.isEmpty) {
                  return const Center(child: Text("No resources found."));
                }

                final filtered = _allResources
                    .where((r) => r.name.toLowerCase().contains(_searchQuery) ||
                        r.type.toLowerCase().contains(_searchQuery))
                    .toList();

                filtered.sort((a, b) {
                  final d1 = _calculateDistance(a.latitude, a.longitude) ?? double.infinity;
                  final d2 = _calculateDistance(b.latitude, b.longitude) ?? double.infinity;
                  return d1.compareTo(d2);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text("No matching results."));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final r = filtered[index];
                    final distance = _calculateDistance(r.latitude, r.longitude);

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    r.imageUrl,
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.image, size: 70),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.name,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text(r.type,
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.blue)),
                                      const SizedBox(height: 2),
                                      Text(r.address,
                                          style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 2),
                                      Text("Hours: ${r.hours}",
                                          style: const TextStyle(fontSize: 12)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.amber, size: 16),
                                          const SizedBox(width: 4),
                                          Text('${r.rating}',
                                              style:
                                                  const TextStyle(fontSize: 12)),
                                          if (distance != null) ...[
                                            const SizedBox(width: 10),
                                            const Icon(Icons.location_on,
                                                size: 16, color: Colors.red),
                                            Text("${distance.toStringAsFixed(1)} km",
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500)),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _launchMaps(r.address);
                                    },
                                    icon: const Icon(Icons.directions),
                                    label: const Text("Get Directions"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _launchURL(r.website),
                                    icon: const Icon(Icons.link),
                                    label: const Text("Website"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
