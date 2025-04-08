import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/food_resource.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  late Future<List<FoodResource>> _futureResources;

  @override
  void initState() {
    super.initState();
    _futureResources = loadResourcesFromJson();
  }

  Future<List<FoodResource>> loadResourcesFromJson() async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/data/resources.json'); // make sure this matches the path
    final List jsonData = json.decode(jsonString);
    return jsonData.map((e) => FoodResource.fromJson(e)).toList();
  }

void _launchURL(String? url) async {
  if (url == null || url.isEmpty || !url.startsWith('http')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("No valid website available.")),
    );
    return;
  }

  final Uri uri = Uri.parse(url);

  try {
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // ✅ Opens in Chrome/Safari
    );

    if (!launched) {
      throw Exception("Could not launch $url");
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to launch: $url")),
    );
    debugPrint("Launch error: $e");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: const Text('Food Resources'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<FoodResource>>(
        future: _futureResources,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading resources."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No resources found."));
          }

          final resources = snapshot.data!;
          return ListView.builder(
            itemCount: resources.length,
            itemBuilder: (context, index) {
              final resource = resources[index];
              return GestureDetector(
                onTap: () => _launchURL(resource.website),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            resource.imageUrl,
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
                              Text(resource.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  )),
                              const SizedBox(height: 4),
                              Text(resource.type,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.blue)),
                              const SizedBox(height: 2),
                              Text(resource.address,
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 2),
                              Text("Hours: ${resource.hours}",
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star,
                                      color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text('${resource.rating}',
                                      style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
