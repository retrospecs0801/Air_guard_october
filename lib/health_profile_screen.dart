// lib/health_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Guidelines Colors [cite: 7, 9]
  final Color _bgScaffold = const Color(0xFFF4F6F8);
  final Color _primaryNavy = const Color(0xFF1E293B);
  final Color _medicalTeal = const Color(0xFF0F766E);
  final Color _textPrimary = const Color(0xFF111827);
  final Color _textSecondary = const Color(0xFF6B7280);

  // Form State variables [cite: 24, 25, 26, 31, 33, 34]
  bool hasAsthma = false;
  String asthmaSeverity = 'Mild';
  bool hasCOPD = false;
  bool hasBronchitis = false;
  bool hasAllergies = false;
  String allergyTypes = '';
  bool hasPneumoniaHistory = false;
  bool hasSleepApnea = false;
  int age = 25;
  String smokingStatus = 'Non-smoker';
  int cigarettesPerDay = 0;
  int yearsQuit = 0;
  bool usesVape = false;
  bool passiveSmoking = false;
  bool occupationalExposure = false;
  String occupationType = '';
  bool hasAirPurifier = false;
  int purifierHours = 0;
  int indoorPlants = 0;
  String cookingMethod = 'Electric/Induction';
  String ventilationQuality = 'Good';
  bool usesIncense = false;
  int incenseFrequency = 0;
  String commuteMode = 'Personal Vehicle';
  int commuteMinutes = 0;
  String trafficDensity = 'Moderate';
  double waterIntake = 2.0;
  String dietQuality = 'Balanced';
  bool drinksGreenTea = false;
  int sleepHours = 7;
  String stressLevel = 'Medium';
  String maskUsage = 'None';
  bool opensWindows = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgScaffold,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(PhosphorIconsBold.caretLeft, color: _primaryNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Health Profile',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w800, // Uses Inter Bold [cite: 12]
            letterSpacing: 0.3,
          ),
        ),
        shape: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            _buildSectionHeader('Respiratory Health', PhosphorIconsBold.heartbeat),
            _buildCard([
              _buildSwitchTile('Asthma', hasAsthma, (val) => setState(() => hasAsthma = val)),
              if (hasAsthma) _buildDropdown('Severity', asthmaSeverity, ['Mild', 'Moderate', 'Severe'], (val) => setState(() => asthmaSeverity = val!)),
              const Divider(),
              _buildSwitchTile('COPD', hasCOPD, (val) => setState(() => hasCOPD = val)),
              const Divider(),
              _buildSwitchTile('Bronchitis', hasBronchitis, (val) => setState(() => hasBronchitis = val)),
              const Divider(),
              _buildSwitchTile('Allergies', hasAllergies, (val) => setState(() => hasAllergies = val)),
              if (hasAllergies) _buildTextField('Allergy Types (dust, pollen)', allergyTypes, (val) => allergyTypes = val),
              const Divider(),
              _buildSlider('Age', age.toDouble(), 1, 100, (val) => setState(() => age = val.toInt()), suffix: ' years'),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader('Smoking & Exposure', PhosphorIconsBold.prohibit),
            _buildCard([
              _buildDropdown('Smoking Status', smokingStatus, ['Non-smoker', 'Current Smoker', 'Ex-smoker', 'Vaper'], (val) => setState(() => smokingStatus = val!)),
              if (smokingStatus == 'Current Smoker') _buildSlider('Cigarettes per Day', cigarettesPerDay.toDouble(), 0, 40, (val) => setState(() => cigarettesPerDay = val.toInt()), suffix: ' cigs'),
              const Divider(),
              _buildSwitchTile('Passive Exposure', passiveSmoking, (val) => setState(() => passiveSmoking = val)),
              const Divider(),
              _buildSwitchTile('Occupational Hazard', occupationalExposure, (val) => setState(() => occupationalExposure = val)),
              if (occupationalExposure) _buildTextField('Occupation Type', occupationType, (val) => occupationType = val),
            ]),

            const SizedBox(height: 32),
            _buildSectionHeader('Indoor Environment', PhosphorIconsBold.houseLine),
            _buildCard([
              _buildSwitchTile('Air Purifier', hasAirPurifier, (val) => setState(() => hasAirPurifier = val)),
              if (hasAirPurifier) _buildSlider('Hours active', purifierHours.toDouble(), 0, 24, (val) => setState(() => purifierHours = val.toInt()), suffix: ' hrs'),
              const Divider(),
              _buildDropdown('Cooking Method', cookingMethod, ['Electric/Induction', 'Gas Stove', 'Mixed'], (val) => setState(() => cookingMethod = val!)),
              const Divider(),
              _buildSlider('Indoor Plants', indoorPlants.toDouble(), 0, 20, (val) => setState(() => indoorPlants = val.toInt()), suffix: ' plants'),
            ]),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  'SAVE HEALTH PROFILE',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(icon, color: _medicalTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(String label, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: _medicalTeal,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(color: _textSecondary, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              filled: true,
              fillColor: _bgScaffold,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            icon: Icon(PhosphorIconsBold.caretDown, size: 16, color: _primaryNavy),
            style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
            items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
      child: TextFormField(
        initialValue: initialValue,
        style: TextStyle(color: _textPrimary, fontSize: 15),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: _textSecondary, fontSize: 13),
          filled: true,
          fillColor: _bgScaffold,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, Function(double) onChanged, {String suffix = ''}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(color: _textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                '${value.toInt()}$suffix',
                style: TextStyle(color: _medicalTeal, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: _medicalTeal,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.white,
              trackHeight: 4,
            ),
            child: Slider(value: value, min: min, max: max, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile saved successfully', style: TextStyle(fontWeight: FontWeight.w600)),
          backgroundColor: _primaryNavy,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }
}