import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/api_service.dart';
import '../services/supabase_client.dart';

class UmpireMatchManagementScreen extends StatefulWidget {
  const UmpireMatchManagementScreen({super.key});

  @override
  State<UmpireMatchManagementScreen> createState() => _UmpireMatchManagementScreenState();
}

class _UmpireMatchManagementScreenState extends State<UmpireMatchManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _locationController = TextEditingController();
  final _oversController = TextEditingController(text: '20');

  List<Map<String, dynamic>> _locations = [];
  String? _selectedLocationId;
  bool _useNewLocation = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) return;

      final response = await ApiService.listLocations(token);
      setState(() {
        _locations = List<Map<String, dynamic>>.from(response['locations'] ?? []);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load locations: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _teamAController.dispose();
    _teamBController.dispose();
    _locationController.dispose();
    _oversController.dispose();
    super.dispose();
  }

  Future<void> _createMatch() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_useNewLocation && _selectedLocationId == null && _locations.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location or create a new one')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Not authenticated');
      }

      final token = await supabase.auth.currentSession?.accessToken;
      if (token == null) {
        throw Exception('No session token');
      }

      final overs = int.tryParse(_oversController.text) ?? 20;

      final response = await ApiService.createMatch(
        token: token,
        teamAName: _teamAController.text.trim(),
        teamBName: _teamBController.text.trim(),
        locationId: _useNewLocation ? null : _selectedLocationId,
        locationName: _useNewLocation ? _locationController.text.trim() : null,
        overs: overs,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Match created: ${response['matchId']}')),
        );
        Navigator.pop(context, response['matchId']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create match: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Match'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _inputField(
                controller: _teamAController,
                label: 'Team A name',
                icon: Icons.flag,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              _inputField(
                controller: _teamBController,
                label: 'Team B name',
                icon: Icons.outlined_flag,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              _inputField(
                controller: _oversController,
                label: 'Overs',
                icon: Icons.timer,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final val = int.tryParse(v);
                  if (val == null || val < 1) return 'Enter valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Location',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              if (!_useNewLocation && _locations.isNotEmpty) ...[
                DropdownButtonFormField<String>(
                  value: _selectedLocationId,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.textSecondary),
                    labelText: 'Select location',
                    filled: true,
                    fillColor: AppColors.backgroundCardAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.backgroundCardAlt),
                    ),
                  ),
                  items: _locations.map((loc) {
                    return DropdownMenuItem(
                      value: loc['id'].toString(),
                      child: Text(loc['name'] ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedLocationId = value);
                  },
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _useNewLocation = true;
                      _selectedLocationId = null;
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add new location'),
                ),
              ] else ...[
                _inputField(
                  controller: _locationController,
                  label: 'Location name',
                  icon: Icons.location_on,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                if (_locations.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _useNewLocation = false;
                        _locationController.clear();
                      });
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Select existing location'),
                  ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _loading ? null : _createMatch,
                  child: _loading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Create Match'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary),
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.backgroundCardAlt,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.backgroundCardAlt),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primaryBlue),
          ),
        ),
      ),
    );
  }
}

