import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'api_service.dart';
import 'dart:async';

class HealthReportsPage extends StatefulWidget {
  final User user;
  
  const HealthReportsPage({super.key, required this.user});

  @override
  State<HealthReportsPage> createState() => _HealthReportsPageState();
}

class _HealthReportsPageState extends State<HealthReportsPage> {
  List<Map<String, dynamic>> _healthReports = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Location search variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  OverlayEntry? _overlayEntry;

  // Selected location details
  String _selectedPlaceName = '';
  String _selectedAddress = '';
  String _selectedCity = '';
  String _selectedDistrict = '';
  String _selectedPostalCode = '';
  double? _selectedLatitude;
  double? _selectedLongitude;

  // Debounce timer for search
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadHealthReports();
    _searchFocusNode.addListener(_onSearchFocusChange);
    
    // Connect the search controller to the search function
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(() {});
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _searchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus && _searchController.text.isNotEmpty) {
      _handleLocationSearch(_searchController.text);
    } else {
      _removeOverlay();
    }
  }

  // ============ INSTANT LOCATION SEARCH ============

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();
    
    // Start new timer with very short debounce (100ms) for instant search
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      _handleLocationSearch(query);
    });
  }

  Future<void> _handleLocationSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _removeOverlay();
      return;
    }

    // Show results after just 2 characters
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _searchWithNominatim(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
      _showSearchOverlay();
    } catch (e) {
      print('Error searching locations: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _errorMessage = 'Failed to search locations. Please check your internet connection.';
      });
      _removeOverlay();
    }
  }

  Future<List<dynamic>> _searchWithNominatim(String query) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'format=json&'
        'q=${Uri.encodeQueryComponent(query)}&'
        'countrycodes=in&'
        'addressdetails=1&'
        'limit=15&'
        'dedupe=1'
      );

      print('Searching for: $query');
      print('URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'HealthApp/1.0',
          'Accept-Language': 'en',
          'Referer': 'https://yourapp.com',
        },
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List) {
          print('Found ${data.length} results');
          return data;
        }
        return [];
      } else {
        throw Exception('API returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Nominatim search error: $e');
      throw Exception('Failed to search locations: $e');
    }
  }

  void _showSearchOverlay() {
    _removeOverlay();

    if (_searchResults.isEmpty && !_isSearching) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 2,
        width: size.width,
        child: Material(
          elevation: 4,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.4,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  blurRadius: 6,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Search Results (${_searchResults.length})',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (_isSearching)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade700),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Results list
                Expanded(
                  child: _isSearching
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Searching locations...',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _searchResults.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_off, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text(
                                      'No locations found',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                    Text(
                                      'Try different search terms',
                                      style: TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                final displayName = location['display_name'] ?? 'Unknown location';
                                final address = location['address'] is Map ? location['address'] as Map<String, dynamic> : {};
                                
                                return ListTile(
                                  dense: true,
                                  leading: Icon(Icons.location_on, 
                                      color: Colors.blue.shade600, size: 20),
                                  title: Text(
                                    _extractPlaceName(location),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    displayName.length > 60 
                                        ? '${displayName.substring(0, 60)}...' 
                                        : displayName,
                                    style: const TextStyle(fontSize: 12),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () {
                                    _selectLocation(location);
                                  },
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  String _extractPlaceName(dynamic location) {
    final address = location['address'] is Map ? location['address'] as Map<String, dynamic> : {};
    
    // Try to get the most specific name first
    return address['hospital'] ?? 
           address['clinic'] ?? 
           address['name'] ?? 
           location['name'] ?? 
           address['building'] ?? 
           address['amenity'] ?? 
           (location['display_name'] ?? '').split(',').first.trim();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectLocation(dynamic location) {
    final addressParts = location['address'] is Map ? location['address'] as Map<String, dynamic> : {};
    
    setState(() {
      _selectedLatitude = double.tryParse(location['lat']?.toString() ?? '');
      _selectedLongitude = double.tryParse(location['lon']?.toString() ?? '');
      _searchController.text = location['display_name'] ?? '';
      
      // Extract place name
      _selectedPlaceName = _extractPlaceName(location);
      
      // Set full address
      _selectedAddress = location['display_name'] ?? '';
      
      // Extract address components
      _selectedCity = addressParts['city'] ?? 
                     addressParts['town'] ?? 
                     addressParts['village'] ?? 
                     addressParts['municipality'] ?? 
                     '';
      
      _selectedDistrict = addressParts['state_district'] ?? 
                         addressParts['county'] ?? 
                         addressParts['city_district'] ?? 
                         '';
      
      _selectedPostalCode = addressParts['postcode']?.toString() ?? '';
    });
    
    print('Selected Location:');
    print('Name: $_selectedPlaceName');
    print('Address: $_selectedAddress');
    print('City: $_selectedCity');
    print('District: $_selectedDistrict');
    print('Postal: $_selectedPostalCode');
    print('Lat: $_selectedLatitude, Lon: $_selectedLongitude');
    
    // Auto-close the search and show details
    _removeOverlay();
    _searchFocusNode.unfocus();
    _showLocationConfirmation();
  }
  void _showCreateReportDialog() {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'wait_time';
  String _selectedSeverity = 'medium';
  bool _isSubmitting = false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Create Health Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location Preview
                if (_selectedPlaceName.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedPlaceName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              if (_selectedAddress.isNotEmpty)
                                Text(
                                  _selectedAddress,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Title
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Report Title*',
                    hintText: 'e.g., Long wait times at emergency',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description*',
                    hintText: 'Describe the issue or situation...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Type
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'wait_time', child: Text('Wait Time')),
                    DropdownMenuItem(value: 'medication', child: Text('Medication')),
                    DropdownMenuItem(value: 'service_quality', child: Text('Service Quality')),
                    DropdownMenuItem(value: 'facility_condition', child: Text('Facility Condition')),
                    DropdownMenuItem(value: 'staff_behavior', child: Text('Staff Behavior')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Severity
                DropdownButtonFormField<String>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedSeverity = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isSubmitting ? null : () async {
                if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                setDialogState(() {
                  _isSubmitting = true;
                });

                try {
                  await ApiService.createHealthReport(
  title: _titleController.text,
  description: _descriptionController.text,
  location: _selectedAddress.isNotEmpty ? _selectedAddress : _selectedPlaceName,
  type: _selectedType,
  severity: _selectedSeverity,
  placeName: _selectedPlaceName,
  city: _selectedCity,
  district: _selectedDistrict,
  latitude: _selectedLatitude,
  longitude: _selectedLongitude,
);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  
                  // Refresh the reports list
                  _loadHealthReports();
                  
                } catch (e) {
                  print('Error creating report: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create report: $e')),
                  );
                } finally {
                  setDialogState(() {
                    _isSubmitting = false;
                  });
                }
              },
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create Report'),
            ),
          ],
        );
      },
    ),
  );
}
  void _showLocationConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Location Selected'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedPlaceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedAddress,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              if (_selectedCity.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'City: $_selectedCity',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
              const SizedBox(height: 16),
              const Text(
                'You can now proceed to add your health report for this location.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Change'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToAddReportWithLocation();
            },
            child: const Text('Continue to Report'),
          ),
        ],
      ),
    );
  }

  // ... (rest of the code remains the same for health reports methods, UI build methods, etc.)
  // Keep all the existing _loadHealthReports, _getSeverityColor, _buildBody, etc. methods
  // They should remain unchanged from your original code

  // ============ HEALTH REPORTS METHODS ============

  Future<void> _loadHealthReports() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final reports = await ApiService.getHealthReports();
      setState(() {
        _healthReports = List<Map<String, dynamic>>.from(reports);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getReportIcon(String type) {
    switch (type) {
      case 'wait_time':
        return Icons.access_time;
      case 'medication':
        return Icons.medication;
      case 'service_quality':
        return Icons.star;
      case 'facility_condition':
        return Icons.business;
      case 'staff_behavior':
        return Icons.people;
      default:
        return Icons.report;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return timestamp;
    }
  }

  String _getReportTypeLabel(String type) {
    switch (type) {
      case 'wait_time':
        return 'Wait Time';
      case 'medication':
        return 'Medication';
      case 'service_quality':
        return 'Service Quality';
      case 'facility_condition':
        return 'Facility Condition';
      case 'staff_behavior':
        return 'Staff Behavior';
      default:
        return type;
    }
  }

  // ============ ADD REPORT DIALOG ============

  void _showAddReportDialog() {
  // Clear previous selection
  setState(() {
    _selectedPlaceName = '';
    _selectedAddress = '';
    _selectedCity = '';
    _selectedDistrict = '';
    _selectedPostalCode = '';
    _selectedLatitude = null;
    _selectedLongitude = null;
    _searchController.clear();
  });

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.add_location_alt, color: Colors.blue),
              SizedBox(width: 8),
              Text('Find Location'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Search for hospitals, clinics, or medical facilities',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    hintText: 'Type hospital name, area, or city...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Start typing to search real locations from OpenStreetMap',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _removeOverlay();
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeOverlay();
                Navigator.pop(context);
                _showManualLocationEntry();
              },
              child: const Text('Enter Manually'),
            ),
          ],
        );
      },
    ),
  );
}
  void _showManualLocationEntry() {
    // ... keep existing manual entry code
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Location Manually'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Place Name*',
                  hintText: 'e.g., City General Hospital',
                ),
                onChanged: (value) => _selectedPlaceName = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Full address',
                ),
                onChanged: (value) => _selectedAddress = value,
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'City',
                  hintText: 'City name',
                ),
                onChanged: (value) => _selectedCity = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_selectedPlaceName.isNotEmpty) {
                Navigator.pop(context);
                _navigateToAddReportWithLocation();
              }
            },
            child: const Text('Use This Location'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddReportWithLocation() {
  final locationData = {
    'placeName': _selectedPlaceName,
    'address': _selectedAddress,
    'city': _selectedCity,
    'district': _selectedDistrict,
    'postalCode': _selectedPostalCode,
    'latitude': _selectedLatitude,
    'longitude': _selectedLongitude,
  };
  
  print('Selected Location Data:');
  print('Place: $_selectedPlaceName');
  print('Address: $_selectedAddress');
  print('City: $_selectedCity');
  print('District: $_selectedDistrict');
  print('Postal Code: $_selectedPostalCode');
  print('Latitude: $_selectedLatitude');
  print('Longitude: $_selectedLongitude');
  
  // Show success message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Location selected: $_selectedPlaceName'),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 2),
    ),
  );
  
  // Show the report creation dialog
  _showCreateReportDialog();
}

  // ============ UI BUILD METHODS ============

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Reports'),
        backgroundColor: const Color(0xFF667EEA),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHealthReports,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportDialog,
        backgroundColor: const Color(0xFF667EEA),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }
    
    if (_healthReports.isEmpty) {
      return _buildEmptyWidget();
    }
    
    return _buildReportsList();
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Error loading reports',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHealthReports,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No health reports yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first health report to help others',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAddReportDialog,
            child: const Text('Add First Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return RefreshIndicator(
      onRefresh: _loadHealthReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _healthReports.length,
        itemBuilder: (context, index) {
          final report = _healthReports[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getSeverityColor(report['severity']).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getReportIcon(report['type']),
            color: _getSeverityColor(report['severity']),
            size: 24,
          ),
        ),
        title: Text(
          report['title'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report['location'],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(report['timestamp']),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getSeverityColor(report['severity']).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            report['severity'].toString().toUpperCase(),
            style: TextStyle(
              color: _getSeverityColor(report['severity']),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showReportDetails(report),
      ),
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report['title']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailItem('Description', report['description']),
              _buildDetailItem('Type', _getReportTypeLabel(report['type'])),
              _buildDetailItem('Severity', report['severity'].toString().toUpperCase()),
              _buildDetailItem('Location', report['location']),
              if (report['placeName'] != null) 
                _buildDetailItem('Place Name', report['placeName']),
              if (report['city'] != null) 
                _buildDetailItem('City', report['city']),
              if (report['district'] != null) 
                _buildDetailItem('District', report['district']),
              _buildDetailItem('Reported', _formatTimestamp(report['timestamp'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}