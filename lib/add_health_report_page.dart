import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';

class AddHealthReportPage extends StatefulWidget {
  final Map<String, dynamic> user;
  
  const AddHealthReportPage({super.key, required this.user});

  @override
  State<AddHealthReportPage> createState() => _AddHealthReportPageState();
}

class _AddHealthReportPageState extends State<AddHealthReportPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _placeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  String _selectedType = 'wait_time';
  String _selectedSeverity = 'medium';
  bool _isSubmitting = false;
  int _currentStep = 0;
  File? _selectedImage;
  String? _uploadedImageUrl;
  bool _isLoadingLocation = false;
  bool _isUploadingImage = false;
  bool _isAiProcessing = false;
  bool _showSuggestions = false;

  // Location variables
  double? _latitude;
  double? _longitude;
  List<dynamic> _searchResults = [];
  final FocusNode _searchFocusNode = FocusNode();

  // AI/ML variables
  String? _aiPrediction;
  double? _aiConfidence;
  String? _aiMessage;

  // Color scheme - Teal & Orange theme
  final Color _primaryColor = const Color(0xFF007B8C);
  final Color _primaryDark = const Color(0xFF005F6B);
  final Color _secondaryColor = const Color(0xFFFF8C00);
  final Color _accentColor = const Color(0xFF8FD85B);
  final Color _backgroundColor = const Color(0xFFF9FAFC);
  final Color _cardColor = const Color(0xFFEBF2F6);
  final Color _textPrimary = const Color(0xFF333333);
  final Color _textSecondary = const Color(0xFF666666);
  final Color _borderColor = const Color(0xFFDDE5ED);

  final List<Map<String, String>> _reportTypes = [
    {'value': 'wait_time', 'label': 'Wait Time'},
    {'value': 'medication', 'label': 'Medication Availability'},
    {'value': 'service_quality', 'label': 'Service Quality'},
    {'value': 'facility_condition', 'label': 'Facility Condition'},
    {'value': 'staff_behavior', 'label': 'Staff Behavior'},
    {'value': 'hygiene', 'label': 'Hygiene & Cleanliness'},
    {'value': 'accessibility', 'label': 'Accessibility'},
  ];

  final List<Map<String, String>> _severityLevels = [
    {'value': 'low', 'label': 'Low'},
    {'value': 'medium', 'label': 'Medium'},
    {'value': 'high', 'label': 'High'},
    {'value': 'critical', 'label': 'Critical'},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocusChange);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _placeNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _postalCodeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (!_searchFocusNode.hasFocus) {
      setState(() {
        _showSuggestions = false;
      });
    }
  }

  // ============ STEP WIDGETS ============

  Widget _buildStep1() {
    return Column(
      children: [
        _buildSectionHeader('Report Details'),
        const SizedBox(height: 16),
        
        // Report Type
        _buildDropdown(
          value: _selectedType,
          items: _reportTypes,
          label: 'Report Type',
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
        const SizedBox(height: 16),

        // Title
        _buildTextFormField(
          controller: _titleController,
          label: 'Title',
          hint: 'Enter a descriptive title',
          validator: (value) => value?.isEmpty == true ? 'Please enter a title' : null,
        ),
        const SizedBox(height: 16),

        // Description
        _buildTextFormField(
          controller: _descriptionController,
          label: 'Description',
          hint: 'Describe the issue in detail',
          maxLines: 4,
          validator: (value) => value?.isEmpty == true ? 'Please enter a description' : null,
        ),
        const SizedBox(height: 16),

        // Severity
        _buildDropdown(
          value: _selectedSeverity,
          items: _severityLevels,
          label: 'Severity Level',
          onChanged: (value) => setState(() => _selectedSeverity = value!),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        _buildSectionHeader('Image & AI Verification'),
        const SizedBox(height: 16),

        // Image Upload Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload Image (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Image Upload Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildIconButton(
                        icon: Icons.photo_library,
                        label: 'Gallery',
                        color: _primaryColor,
                        onPressed: _pickImageFromGallery,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildIconButton(
                        icon: Icons.camera_alt,
                        label: 'Camera',
                        color: _secondaryColor,
                        onPressed: _takePhoto,
                      ),
                    ),
                  ],
                ),

                // Selected Image Preview
                if (_selectedImage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _borderColor),
                    ),
                    child: Stack(
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _uploadedImageUrl = null;
                                  _aiPrediction = null;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedImage!.path.split('/').last}',
                    style: TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                ],

                // Upload Status
                if (_isUploadingImage) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Uploading image...',
                    style: TextStyle(color: _textSecondary, fontSize: 12),
                  ),
                ],
                if (_uploadedImageUrl != null && !_isUploadingImage) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Image uploaded successfully!',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // AI Verification Section
        if (_selectedImage != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Image Verification',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildIconButton(
                    icon: Icons.psychology,
                    label: _isAiProcessing ? 'Processing...' : 'Verify with AI',
                    color: _primaryColor,
                    onPressed: _isAiProcessing ? null : _runAiVerification,
                  ),

                  if (_aiPrediction != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _primaryColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.psychology, color: _primaryColor),
                              const SizedBox(width: 8),
                              Text(
                                'AI Analysis Complete',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prediction: $_aiPrediction',
                            style: TextStyle(color: _textPrimary),
                          ),
                          Text(
                            'Confidence: ${(_aiConfidence! * 100).toStringAsFixed(1)}%',
                            style: TextStyle(color: _textPrimary),
                          ),
                          if (_aiMessage != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _aiMessage!,
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        _buildSectionHeader('Location Details'),
        const SizedBox(height: 16),

        // Location Search Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                Stack(
                  children: [
                    TextFormField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search for hospitals, clinics, medical centers...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: _borderColor),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.search, color: _textSecondary),
                      ),
                      onChanged: _handleLocationSearch,
                    ),
                    
                    // Search Suggestions
                    if (_showSuggestions && _searchResults.isNotEmpty)
                      Positioned(
                        top: 60,
                        left: 0,
                        right: 0,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            constraints: const BoxConstraints(maxHeight: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _borderColor),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _searchResults.length,
                              itemBuilder: (context, index) {
                                final location = _searchResults[index];
                                return ListTile(
                                  leading: Icon(Icons.location_on, color: _primaryColor, size: 20),
                                  title: Text(
                                    location['display_name'] ?? 'Unknown location',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () => _selectLocation(location),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Location Details Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildTextFormField(
                  controller: _placeNameController,
                  label: 'Place Name',
                  hint: 'e.g., City General Hospital',
                ),
                const SizedBox(height: 12),
                
                _buildTextFormField(
                  controller: _addressController,
                  label: 'Address',
                  hint: 'Full street address',
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFormField(
                        controller: _cityController,
                        label: 'City',
                        hint: 'City name',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextFormField(
                        controller: _districtController,
                        label: 'District',
                        hint: 'District name',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                _buildTextFormField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  hint: 'Postal code',
                ),

                // Current Location Section
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Coordinates',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_isLoadingLocation)
                        const Center(child: CircularProgressIndicator()),
                      
                      if (!_isLoadingLocation && _latitude != null && _longitude != null)
                        Row(
                          children: [
                            Icon(Icons.gps_fixed, color: _primaryColor, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                                style: TextStyle(color: _textPrimary, fontSize: 14),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, color: _primaryColor, size: 20),
                              onPressed: _getCurrentLocation,
                            ),
                          ],
                        ),
                      
                      if (!_isLoadingLocation && (_latitude == null || _longitude == null))
                        Row(
                          children: [
                            Icon(Icons.location_off, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Location not available',
                                style: TextStyle(color: Colors.orange, fontSize: 14),
                              ),
                            ),
                            TextButton(
                              onPressed: _getCurrentLocation,
                              child: Text('Retry', style: TextStyle(color: _primaryColor)),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        _buildSectionHeader('Review Your Report'),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Report Details
                _buildReviewSection(
                  title: '📋 Report Details',
                  children: [
                    _buildReviewItem('Report Type', _getReportTypeLabel(_selectedType)),
                    _buildReviewItem('Title', _titleController.text),
                    _buildReviewItem('Description', _descriptionController.text),
                    _buildReviewItem('Severity', _getSeverityLabel(_selectedSeverity)),
                  ],
                ),

                const Divider(height: 32),

                // Image & AI Section
                if (_selectedImage != null || _aiPrediction != null)
                  Column(
                    children: [
                      _buildReviewSection(
                        title: '🖼️ Image & AI Analysis',
                        children: [
                          if (_selectedImage != null)
                            _buildReviewItem('Image', 'Attached (${_selectedImage!.path.split('/').last})'),
                          if (_uploadedImageUrl != null)
                            _buildReviewItem('Upload Status', 'Successfully uploaded'),
                          if (_aiPrediction != null)
                            _buildReviewItem('AI Prediction', '$_aiPrediction (${(_aiConfidence! * 100).toStringAsFixed(1)}% confidence)'),
                        ],
                      ),
                      const Divider(height: 32),
                    ],
                  ),

                // Location Details
                _buildReviewSection(
                  title: '📍 Location Details',
                  children: [
                    _buildReviewItem('Place Name', _placeNameController.text),
                    _buildReviewItem('Address', _addressController.text),
                    _buildReviewItem('City', _cityController.text),
                    _buildReviewItem('District', _districtController.text),
                    _buildReviewItem('Postal Code', _postalCodeController.text),
                    if (_latitude != null && _longitude != null)
                      _buildReviewItem('Coordinates', '${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}'),
                    if (_searchController.text.isNotEmpty)
                      _buildReviewItem('Searched Location', _searchController.text),
                  ],
                ),

                // User Info
                const Divider(height: 32),
                _buildReviewSection(
                  title: '👤 Submitted By',
                  children: [
                    _buildReviewItem('User Type', widget.user['role']?.toString().toUpperCase() ?? 'User'),
                    _buildReviewItem('User ID', widget.user['id']?.toString() ?? 'N/A'),
                    _buildReviewItem('Submission Time', _getCurrentTime()),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),
        
        // Final Note
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: _primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Review all information before submitting. You cannot edit the report after submission.',
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ HELPER WIDGETS ============

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          height: 24,
          width: 4,
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<Map<String, String>> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _borderColor),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: items.map((item) {
              return DropdownMenuItem(
                value: item['value'],
                child: Text(item['label']!),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: _textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: _borderColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildReviewSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.orange : _textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============ LOCATION METHODS ============

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Location permissions are permanently denied');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });

      await _getAddressFromCoordinates(_latitude!, _longitude!);
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      _showSnackBar('Error getting location: $e');
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _addressController.text = [
            place.street,
            place.locality,
            place.administrativeArea,
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          _cityController.text = place.locality ?? '';
          _districtController.text = place.administrativeArea ?? '';
          _postalCodeController.text = place.postalCode ?? '';
          if (_placeNameController.text.isEmpty) {
            _placeNameController.text = place.name?.isNotEmpty == true 
                ? place.name! 
                : 'Current Location';
          }
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  Future<void> _handleLocationSearch(String query) async {
    if (query.length > 2) {
      try {
        final results = await _searchWithNominatim(query);
        setState(() {
          _searchResults = results;
          _showSuggestions = true;
        });
      } catch (e) {
        print('Error searching locations: $e');
        setState(() {
          _searchResults = [];
          _showSuggestions = false;
        });
      }
    } else {
      setState(() {
        _searchResults = [];
        _showSuggestions = false;
      });
    }
  }

  Future<List<dynamic>> _searchWithNominatim(String query) async {
    try {
      final url = 'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeQueryComponent(query)}&countrycodes=in&addressdetails=1';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to search locations');
      }
    } catch (e) {
      throw Exception('Search error: $e');
    }
  }

  void _selectLocation(dynamic location) {
    setState(() {
      _latitude = double.parse(location['lat'].toString());
      _longitude = double.parse(location['lon'].toString());
      _searchController.text = location['display_name'] ?? '';
      
      // Extract address components
      final displayName = location['display_name'] ?? '';
      final parts = displayName.split(',');
      
      _placeNameController.text = location['name'] ?? parts.first.trim();
      _addressController.text = displayName;
      
      if (parts.length >= 2) {
        _cityController.text = parts.length > 2 ? parts[parts.length - 3].trim() : parts[parts.length - 2].trim();
        _districtController.text = parts.length > 3 ? parts[parts.length - 4].trim() : parts[parts.length - 2].trim();
      }
      
      _postalCodeController.text = _extractPostalCode(displayName);
      _showSuggestions = false;
      _searchFocusNode.unfocus();
    });
  }

  String _extractPostalCode(String address) {
    final postalCodeRegex = RegExp(r'\b\d{5,6}\b');
    final match = postalCodeRegex.firstMatch(address);
    return match?.group(0) ?? '';
  }

  // ============ IMAGE METHODS ============

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    
    if (image != null) {
      await _handleImageSelection(File(image.path));
    }
  }

  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1200,
    );
    
    if (image != null) {
      await _handleImageSelection(File(image.path));
    }
  }

  Future<void> _handleImageSelection(File image) async {
    setState(() {
      _selectedImage = image;
      _uploadedImageUrl = null;
      _aiPrediction = null;
      _aiConfidence = null;
      _aiMessage = null;
    });
    
    final imageUrl = await _uploadImage();
    setState(() {
      _uploadedImageUrl = imageUrl;
    });
    
    if (imageUrl == null) {
      _showSnackBar('Image upload failed. Image will be stored locally.');
    } else {
      _showSnackBar('Image uploaded successfully!', isError: false);
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Simulate upload delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would upload to your server or cloud storage
      // For now, we'll return a mock URL
      return 'https://example.com/uploaded-image.jpg';
    } catch (e) {
      print('Image upload error: $e');
      return null;
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  // ============ AI VERIFICATION ============

  Future<void> _runAiVerification() async {
    if (_selectedImage == null) return;

    setState(() {
      _isAiProcessing = true;
      _aiPrediction = null;
      _aiConfidence = null;
      _aiMessage = null;
    });

    try {
      // Simulate AI processing delay
      await Future.delayed(const Duration(seconds: 3));

      final mockPredictions = {
        'wait_time': {'class': 'Waiting Area', 'confidence': 0.87},
        'medication': {'class': 'Pharmacy', 'confidence': 0.92},
        'service_quality': {'class': 'Service Desk', 'confidence': 0.78},
        'facility_condition': {'class': 'Medical Facility', 'confidence': 0.85},
        'staff_behavior': {'class': 'Hospital Staff', 'confidence': 0.73},
        'hygiene': {'class': 'Cleanliness', 'confidence': 0.88},
        'accessibility': {'class': 'Accessibility Feature', 'confidence': 0.82},
      };

      final prediction = mockPredictions[_selectedType] ?? 
                        {'class': 'Medical Facility', 'confidence': 0.80};
      
      setState(() {
        _aiPrediction = prediction['class'] as String?;
        _aiConfidence = (prediction['confidence'] as num?)?.toDouble();
        _aiMessage = 'The image appears to show ${prediction['class']?.toString().toLowerCase()}';
        _isAiProcessing = false;
      });

    } catch (e) {
      setState(() {
        _isAiProcessing = false;
      });
      _showSnackBar('AI verification failed: $e');
    }
  }

  // ============ FORM SUBMISSION ============

  Future<void> _submitReport() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      _showSnackBar('Health report submitted successfully!', isError: false);
      
      // Navigate back after success
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Failed to submit report: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_titleController.text.isEmpty) {
          _showSnackBar('Please enter a title');
          return false;
        }
        if (_descriptionController.text.isEmpty) {
          _showSnackBar('Please enter a description');
          return false;
        }
        return true;
      case 2:
        if (_placeNameController.text.isEmpty && _addressController.text.isEmpty) {
          _showSnackBar('Please provide either a place name or address');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getReportTypeLabel(String value) {
    return _reportTypes.firstWhere(
      (element) => element['value'] == value,
      orElse: () => {'label': 'Unknown'},
    )['label']!;
  }

  String _getSeverityLabel(String value) {
    return _severityLevels.firstWhere(
      (element) => element['value'] == value,
      orElse: () => {'label': 'Unknown'},
    )['label']!;
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Health Report'),
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: _backgroundColor,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _currentStep < 3 ? _goToNextStep : _submitReport,
          onStepCancel: _currentStep > 0 ? _goToPreviousStep : null,
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (details.onStepCancel != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: _primaryColor),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(color: _primaryColor),
                        ),
                      ),
                    ),
                  if (details.onStepCancel != null) const SizedBox(width: 12),
                  if (details.onStepContinue != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                _currentStep == 3 ? 'Submit Report' : 'Continue',
                                style: const TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Report Details'),
              content: _buildStep1(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Image & AI'),
              content: _buildStep2(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Location'),
              content: _buildStep3(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: const Text('Review & Submit'),
              content: _buildStep4(),
              isActive: _currentStep >= 3,
              state: StepState.indexed,
            ),
          ],
        ),
      ),
    );
  }

  void _goToNextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep -= 1;
    });
  }
}