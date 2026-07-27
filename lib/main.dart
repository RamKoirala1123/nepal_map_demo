import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nepal_map/nepal_map.dart';

void main() => runApp(const NepalMapExampleApp());

class NepalMapExampleApp extends StatelessWidget {
  const NepalMapExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nepal Map — Full Demo',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const FullDemoPage(),
    );
  }
}

class FullDemoPage extends StatefulWidget {
  const FullDemoPage({super.key});

  @override
  State<FullDemoPage> createState() => _FullDemoPageState();
}

class _FullDemoPageState extends State<FullDemoPage> {
  late final NepalMapController _controller;
  String _lastEvent = 'Tap a district to get started';
  String? _hovered;

  // Feature demo state
  bool _showLayers = false;
  bool _showHeatmap = false;
  bool _showMarkers = false;

  // Theme demo state — cycles through theme presets
  int _themeIndex = 0;
  final List<String> _themeLabels = [
    'Default',
    'Province Rainbow',
    'Dark Mode',
    'Custom Colors',
  ];

  @override
  void initState() {
    super.initState();
    _controller = NepalMapController(mode: NepalSelectionMode.singleDistrict);
    _controller.addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    super.dispose();
  }

  void _setMode(NepalSelectionMode mode) {
    setState(() {
      _controller.setMode(mode);
      _lastEvent = 'Switched to ${_labelFor(mode)}';
    });
  }

  String _labelFor(NepalSelectionMode mode) {
    switch (mode) {
      case NepalSelectionMode.singleDistrict:
        return 'Single district';
      case NepalSelectionMode.multiDistrict:
        return 'Multi district';
      case NepalSelectionMode.singleProvince:
        return 'Single province';
      case NepalSelectionMode.multiProvince:
        return 'Multi province';
      case NepalSelectionMode.none:
        return 'None';
    }
  }

  // --- Coverage layer demo ---
  void _toggleCoverageLayers() {
    setState(() {
      _showLayers = !_showLayers;
      if (_showLayers) {
        // Bank branches layer (blue) — central/eastern districts
        _controller.addCoverageLayer(const CoverageLayer(
          id: 'bank_branches',
          name: 'Bank Branches',
          districtIds: [
            'kathmandu', 'lalitpur', 'bhaktapur', 'chitwan',
            'biratnagar', 'janakpur', 'birgunj', 'dharan',
          ],
          color: Color(0xFF2196F3),
          opacity: 0.4,
        ));

        // Delivery zones layer (orange) — valley + nearby
        _controller.addCoverageLayer(const CoverageLayer(
          id: 'delivery_zones',
          name: 'Delivery Zones',
          districtIds: [
            'kathmandu', 'lalitpur', 'bhaktapur', 'dhading',
            'nuwakot', 'sindhuli', 'rasuwa',
          ],
          color: Colors.orange,
          opacity: 0.35,
        ));
      } else {
        _controller.clearCoverageLayers();
      }
    });
  }

  // --- Heatmap demo ---
  void _toggleHeatmap() {
    setState(() {
      _showHeatmap = !_showHeatmap;
      if (_showHeatmap) {
        // Simulated population data (in thousands)
        final data = {
          'kathmandu': 177.0,
          'lalitpur': 29.0,
          'bhaktapur': 30.0,
          'biratnagar': 15.0,
          'janakpur': 12.0,
          'pokhara': 10.0,
          'birgunj': 10.0,
          'dharan': 8.0,
          'butwal': 9.0,
          'bhairahawa': 11.0,
          'chitwan': 13.0,
          'jhapa': 7.0,
          'morang': 8.0,
          'sunsari': 6.0,
          'kapilvastu': 5.0,
          'parasi': 7.0,
          'rukum_west': 2.0,
          'humla': 1.0,
          'mugu': 1.0,
          'dolpa': 1.0,
          'mustang': 2.0,
          'myagdi': 3.0,
          'gorkha': 5.0,
          'sindhupalchok': 4.0,
          'nuwakot': 3.0,
          'dhading': 4.0,
          'kavrepalanchok': 6.0,
          'sindhuli': 3.0,
          'rasuwa': 1.0,
        };

        _controller.setHeatmap(HeatmapConfig(
          dataMap: data,
          label: 'Population (thousands)',
          minValue: 0,
          maxValue: 200,
          colors: [
            const Color(0xFFE8F5E9), // light green
            const Color(0xFF66BB6A), // green
            const Color(0xFFFFA726), // orange
            const Color(0xFFE53935), // red
          ],
        ));
      } else {
        _controller.clearHeatmap();
      }
    });
  }

  // --- Markers demo ---
  void _toggleMarkers() {
    setState(() {
      _showMarkers = !_showMarkers;
      if (_showMarkers) {
        _controller.addMarkers([
          // City markers anchored to district centroids
          const MapMarker(
            id: 'kathmandu_city',
            districtId: 'kathmandu',
            size: 28,
            child: _CityMarker(label: 'KTM', color: Colors.red),
          ),
          const MapMarker(
            id: 'pokhara_city',
            districtId: 'kaski',
            size: 24,
            child: _CityMarker(label: 'PKR', color: Colors.purple),
          ),
          const MapMarker(
            id: 'biratnagar_city',
            districtId: 'morang',
            size: 22,
            child: _CityMarker(label: 'BIR', color: Colors.teal),
          ),
          const MapMarker(
            id: 'janakpur_city',
            districtId: 'dhanusha',
            size: 22,
            child: _CityMarker(label: 'JNP', color: Colors.amber),
          ),
          const MapMarker(
            id: 'butwal_city',
            districtId: 'rupandehi',
            size: 22,
            child: _CityMarker(label: 'BTW', color: Colors.indigo),
          ),
        ]);
      } else {
        _controller.clearMarkers();
      }
    });
  }

  // --- Theme demo ---
  void _cycleTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % _themeLabels.length;
    });
  }

  NepalMapTheme? _getTheme() {
    switch (_themeIndex) {
      case 0:
        // Default — no custom theme
        return null;
      case 1:
        // Province rainbow colors with styled tooltip
        return NepalMapTheme(
          colors: NepalMapColors(
            provinceColors: NepalMapThemePresets.provinceRainbow,
            selectedColor: Colors.blue[800]!,
            hoverColor: Colors.blue[300]!,
            borderColor: Colors.white70,
            borderWidth: 1.5,
          ),
          tooltipStyle: TooltipStyle(
            backgroundColor: Colors.black87,
            borderRadius: 8,
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          markerStyle: const MarkerStyle(
            color: Colors.deepOrange,
            icon: Icons.place,
          ),
        );
      case 2:
        // Dark mode
        return NepalMapTheme(
          colors: NepalMapThemePresets.dark.copyWith(
            borderColor: const Color(0xFF757575),
            borderWidth: 1.2,
          ),
          tooltipStyle: TooltipStyle(
            backgroundColor: const Color(0xFF424242),
            textColor: Colors.white,
            borderRadius: 4,
            elevation: 6,
          ),
        );
      case 3:
        // Custom per-district colors + custom tooltip
        return NepalMapTheme(
          colors: NepalMapColors(
            baseColor: const Color(0xFFF3E5F5),
            selectedColor: Colors.purple[700]!,
            hoverColor: Colors.purple[200]!,
            borderColor: Colors.purple[300]!,
            borderWidth: 1.5,
            districtColors: {
              'kathmandu': Colors.amber[300]!,
              'lalitpur': Colors.amber[200]!,
              'bhaktapur': Colors.amber[100]!,
              'kaski': Colors.teal[200]!,
              'morang': Colors.green[200]!,
              'dhanusha': Colors.orange[200]!,
              'chitwan': Colors.lightGreen[200]!,
            },
          ),
          tooltipStyle: TooltipStyle(
            backgroundColor: Colors.purple[900]!,
            textColor: Colors.white,
            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            borderRadius: 12,
            offset: const Offset(16, -40),
            elevation: 8,
          ),
          markerStyle: const MarkerStyle(
            color: Colors.purple,
            icon: Icons.location_on,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nepal Map — Full Demo'),
        actions: [
          // Feature toggle buttons
          _featureChip('Layers', _showLayers, _toggleCoverageLayers),
          _featureChip('Heatmap', _showHeatmap, _toggleHeatmap),
          _featureChip('Markers', _showMarkers, _toggleMarkers),
          // Theme cycle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text('🎨 ${_themeLabels[_themeIndex]}'),
              selected: false,
              onSelected: (_) => _cycleTheme(),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Map takes most of the space
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // Selection mode chips
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: NepalSelectionMode.values
                        .where((m) => m != NepalSelectionMode.none)
                        .map((mode) {
                      final selected = _controller.mode == mode;
                      return ChoiceChip(
                        label: Text(_labelFor(mode)),
                        selected: selected,
                        onSelected: (_) => _setMode(mode),
                      );
                    }).toList(),
                  ),
                ),
                // Map widget
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Stack(
                      children: [
                        NepalMapWidget(
                          controller: _controller,
                          theme: _getTheme(),
                          onDistrictTap: (district) {
                            setState(() {
                              _lastEvent =
                                  'Tapped ${district.name} (Province ${district.provinceNumber}, HQ: ${district.headquarter})';
                            });
                          },
                          onProvinceTap: (provinceNumber, districts) {
                            final isSelected =
                                _controller.isProvinceSelected(provinceNumber);
                            setState(() {
                              _lastEvent = isSelected
                                  ? 'Province $provinceNumber selected (${districts.length} districts)'
                                  : 'Province $provinceNumber deselected';
                            });
                          },
                          onDistrictHover: (district) {
                            setState(() {
                              _hovered = district?.name;
                            });
                          },
                        ),
                        Positioned(
                          right: 8,
                          top: 8,
                          child: _ZoomControls(controller: _controller),
                        ),
                      ],
                    ),
                  ),
                ),
                // Status bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _lastEvent,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      if (_controller.mode.isDistrictMode)
                        Text(
                          'Selected districts: ${_controller.selectedDistricts.join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (_controller.mode.isProvinceMode)
                        Text(
                          'Selected provinces: ${_controller.selectedProvinces.join(", ")}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _controller.clearSelection,
                          child: const Text('Clear selection'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Legend sidebar
          if (_showLayers || _showHeatmap || _showMarkers)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LegendWidget(
                  controller: _controller,
                  title: 'Legend',
                  showLayers: _showLayers,
                  showHeatmap: _showHeatmap,
                  showSelection: true,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _featureChip(String label, bool active, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.shade100,
    );
  }
}

/// Small floating zoom controls.
class _ZoomControls extends StatelessWidget {
  const _ZoomControls({required this.controller});

  final NepalMapController controller;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.add),
            onPressed: controller.zoomIn,
          ),
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.remove),
            onPressed: controller.zoomOut,
          ),
          IconButton(
            tooltip: 'Reset view',
            icon: const Icon(Icons.refresh),
            onPressed: controller.resetView,
          ),
          IconButton(
            tooltip: 'Fit to screen',
            icon: const Icon(Icons.fit_screen),
            onPressed: controller.fitToScreen,
          ),
        ],
      ),
    );
  }
}

/// Compact city label marker widget.
class _CityMarker extends StatelessWidget {
  const _CityMarker({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
