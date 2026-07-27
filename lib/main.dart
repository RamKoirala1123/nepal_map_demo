import 'package:flutter/material.dart';
import 'package:nepal_map/nepal_map.dart';
import 'package:url_launcher/url_launcher_string.dart';

void main() => runApp(const NepalMapExampleApp());

class NepalMapExampleApp extends StatefulWidget {
  const NepalMapExampleApp({super.key});

  @override
  State<NepalMapExampleApp> createState() => _NepalMapExampleAppState();
}

class _NepalMapExampleAppState extends State<NepalMapExampleApp> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'nepal_map Demo',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: FullDemoPage(
        isDark: _isDark,
        onToggleTheme: () {
          setState(() {
            _isDark = !_isDark;
          });
        },
      ),
    );
  }
}

class FullDemoPage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const FullDemoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<FullDemoPage> createState() => _FullDemoPageState();
}

class _FullDemoPageState extends State<FullDemoPage> {
  late final NepalMapController _controller;
  String _lastEvent = 'Tap a district to begin';
  String? _hovered;

  // Feature state
  bool _showLayers = false;
  bool _showHeatmap = false;
  bool _showMarkers = false;

  // Theme presets
  int _themeIndex = 0;
  final List<String> _themeLabels = [
    'Soft Blue (Default)',
    'Province Rainbow',
    'Sunset Gold',
    'Dark Mode Accent',
  ];

  // Loaded districts
  List<NepalDistrict> _allDistricts = [];
  bool _loadingDistricts = true;

  // Search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  // Selected district info database
  final Map<String, Map<String, String>> _districtDetails = {
    'kathmandu': {
      'attraction': 'Swayambhunath, Durbar Square',
      'altitude': '1,400 m',
      'type': 'Capital City',
      'fact': 'City of Temples, home to 7 UNESCO World Heritage sites.',
    },
    'kaski': {
      'attraction': 'Phewa Lake, Annapurna Circuit',
      'altitude': '822 m',
      'type': 'Tourism Hub',
      'fact': 'Gateway to the Annapurna region trekking routes.',
    },
    'mustang': {
      'attraction': 'Muktinath Temple, Lo Manthang',
      'altitude': '3,800 m',
      'type': 'Trans-Himalayan Region',
      'fact': 'Unique cold desert landscape behind the Himalayas.',
    },
    'solukhumbu': {
      'attraction': 'Mount Everest, Lukla Airport',
      'altitude': '2,860 m',
      'type': 'Himalayan High Peak',
      'fact': 'Contains Mount Everest, the highest peak on Earth.',
    },
    'chitwan': {
      'attraction': 'Chitwan National Park',
      'altitude': '150 m',
      'type': 'Wildlife Conservation',
      'fact': 'Famous for One-horned Rhinoceros and Royal Bengal Tigers.',
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = NepalMapController(mode: NepalSelectionMode.singleDistrict);
    _controller.addListener(_rebuild);
    _loadDistricts();
  }

  void _rebuild() => setState(() {});

  Future<void> _loadDistricts() async {
    try {
      final districts = await NepalGeoLoader.load();
      setState(() {
        _allDistricts = districts;
        _loadingDistricts = false;
      });
    } catch (e) {
      setState(() {
        _loadingDistricts = false;
      });
      debugPrint('Error loading districts: $e');
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_rebuild);
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _launchPubUrl() async {
    const url = 'https://pub.dev/packages/nepal_map';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchGithubUrl() async {
    const url = 'https://github.com/RamKoirala1123/nepal_map_flutter';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  void _setMode(NepalSelectionMode mode) {
    setState(() {
      _controller.setMode(mode);
      _lastEvent = 'Mode: ${_labelFor(mode)}';
    });
  }

  String _labelFor(NepalSelectionMode mode) {
    switch (mode) {
      case NepalSelectionMode.singleDistrict:
        return 'Single District';
      case NepalSelectionMode.multiDistrict:
        return 'Multi District';
      case NepalSelectionMode.singleProvince:
        return 'Single Province';
      case NepalSelectionMode.multiProvince:
        return 'Multi Province';
      case NepalSelectionMode.none:
        return 'View Only';
    }
  }

  void _toggleCoverageLayers() {
    setState(() {
      _showLayers = !_showLayers;
      if (_showLayers) {
        _controller.addCoverageLayer(const CoverageLayer(
          id: 'bank_branches',
          name: 'Bank Branches',
          districtIds: [
            'kathmandu',
            'lalitpur',
            'bhaktapur',
            'chitwan',
            'biratnagar',
            'pokhara'
          ],
          color: Color(0xFF0284C7),
          opacity: 0.35,
        ));
        _controller.addCoverageLayer(const CoverageLayer(
          id: 'delivery_zones',
          name: 'Delivery Zones',
          districtIds: [
            'kathmandu',
            'lalitpur',
            'bhaktapur',
            'dhading',
            'nuwakot'
          ],
          color: Colors.orange,
          opacity: 0.3,
        ));
      } else {
        _controller.clearCoverageLayers();
      }
    });
  }

  void _toggleHeatmap() {
    setState(() {
      _showHeatmap = !_showHeatmap;
      if (_showHeatmap) {
        final data = {
          'kathmandu': 170.0,
          'lalitpur': 30.0,
          'bhaktapur': 25.0,
          'pokhara': 12.0,
          'chitwan': 14.0,
          'morang': 9.0,
          'rupandehi': 10.0,
        };
        _controller.setHeatmap(HeatmapConfig(
          dataMap: data,
          label: 'Population Density',
          minValue: 0,
          maxValue: 200,
          colors: [
            const Color(0xFFF0F9FF),
            const Color(0xFFBAE6FD),
            const Color(0xFF38BDF8),
            const Color(0xFF0284C7),
          ],
        ));
      } else {
        _controller.clearHeatmap();
      }
    });
  }

  void _toggleMarkers() {
    setState(() {
      _showMarkers = !_showMarkers;
      if (_showMarkers) {
        _controller.addMarkers([
          const MapMarker(
            id: 'ktm',
            districtId: 'kathmandu',
            size: 24,
            child: _CityMarker(label: 'KTM', color: Colors.blue),
          ),
          const MapMarker(
            id: 'pkr',
            districtId: 'kaski',
            size: 24,
            child: _CityMarker(label: 'PKR', color: Colors.indigo),
          ),
        ]);
      } else {
        _controller.clearMarkers();
      }
    });
  }

  void _cycleTheme() {
    setState(() {
      _themeIndex = (_themeIndex + 1) % _themeLabels.length;
    });
  }

  NepalMapTheme? _getTheme() {
    switch (_themeIndex) {
      case 0:
        return NepalMapTheme(
          colors: NepalMapColors(
            baseColor: widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            selectedColor: const Color(0xFFBAE6FD),
            hoverColor: const Color(0xFFE0F2FE),
            borderColor: widget.isDark
                ? const Color(0xFF334155)
                : const Color(0xFFCBD5E1),
            borderWidth: 1.0,
          ),
          tooltipStyle: TooltipStyle(
            backgroundColor:
                widget.isDark ? const Color(0xFF1E293B) : Colors.white,
            textColor: widget.isDark ? Colors.white : Colors.black87,
            borderRadius: 6,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          ),
        );
      case 1:
        return NepalMapTheme(
          colors: NepalMapColors(
            provinceColors: NepalMapThemePresets.provinceRainbow,
            selectedColor: const Color(0xFFBAE6FD),
            hoverColor: const Color(0xFFE0F2FE),
            borderColor: Colors.white,
            borderWidth: 1.0,
          ),
        );
      case 2:
        return NepalMapTheme(
          colors: NepalMapColors(
            baseColor: widget.isDark
                ? const Color(0xFF451A03)
                : const Color(0xFFFFF7ED),
            selectedColor: const Color(0xFFFED7AA),
            hoverColor: const Color(0xFFFFEDD5),
            borderColor: const Color(0xFFF97316),
            borderWidth: 1.0,
          ),
        );
      case 3:
        return NepalMapTheme(
          colors: NepalMapColors(
            baseColor: const Color(0xFF0F172A),
            selectedColor: const Color(0xFF1E3A8A),
            hoverColor: const Color(0xFF1E40AF),
            borderColor: const Color(0xFF3B82F6),
            borderWidth: 1.0,
          ),
        );
      default:
        return null;
    }
  }

  List<NepalDistrict> get _filteredDistricts {
    if (_searchQuery.isEmpty) return [];
    return _allDistricts
        .where((d) => d.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _selectDistrictFromSearch(NepalDistrict district) {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _searchFocusNode.unfocus();
      if (_controller.mode.isProvinceMode) {
        _controller.selectProvince(district.provinceNumber);
      } else {
        _controller.selectDistrict(district.id);
      }
      _lastEvent = 'Selected ${district.name}';
    });
  }

  Widget _buildFloatingDetailsCard(bool isDark) {
    final mode = _controller.mode;

    if (mode.isDistrictMode && _controller.selectedDistricts.isNotEmpty) {
      final selectedId = _controller.selectedDistricts.first;
      final district = _allDistricts.firstWhere(
        (d) => d.id == selectedId,
        orElse: () => NepalDistrict(
            id: selectedId,
            name: selectedId,
            headquarter: '',
            provinceNumber: 0,
            rings: []),
      );

      final rich = _districtDetails[district.id];

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  district.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: _controller.clearSelection,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const Divider(height: 12),
          Text('Province: ${district.provinceNumber}',
              style: const TextStyle(fontSize: 12)),
          if (district.headquarter.isNotEmpty)
            Text('Headquarters: ${district.headquarter}',
                style: const TextStyle(fontSize: 12)),
          if (rich != null) ...[
            Text('Key Attraction: ${rich['attraction']}',
                style: const TextStyle(fontSize: 12)),
            Text('Elevation: ${rich['altitude']}',
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              rich['fact']!,
              style: const TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey),
            ),
          ],
        ],
      );
    } else if (mode.isProvinceMode &&
        _controller.selectedProvinces.isNotEmpty) {
      final pNum = _controller.selectedProvinces.first;
      final dists =
          _allDistricts.where((d) => d.provinceNumber == pNum).toList();

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Province $pNum',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 16),
                onPressed: _controller.clearSelection,
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const Divider(height: 12),
          Text('Total Districts: ${dists.length}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: dists.map((d) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.setMode(NepalSelectionMode.singleDistrict);
                    _controller.selectDistrict(d.id);
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    d.name,
                    style: const TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildMobileToolbar(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mode selector as a compact dropdown
          DropdownButton<NepalSelectionMode>(
            value: _controller.mode,
            underline: const SizedBox.shrink(),
            items: NepalSelectionMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child:
                    Text(_labelFor(mode), style: const TextStyle(fontSize: 11)),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) _setMode(value);
            },
          ),
          const SizedBox(width: 8),
          // Overlay toggles
          IconButton(
            icon: Icon(_showLayers ? Icons.layers : Icons.layers_outlined,
                size: 20),
            onPressed: _toggleCoverageLayers,
            tooltip: 'Layers',
            color: _showLayers ? Colors.blue : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
          IconButton(
            icon: Icon(
                _showHeatmap
                    ? Icons.local_fire_department
                    : Icons.local_fire_department_outlined,
                size: 20),
            onPressed: _toggleHeatmap,
            tooltip: 'Heatmap',
            color: _showHeatmap ? Colors.blue : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
          IconButton(
            icon: Icon(_showMarkers ? Icons.place : Icons.place_outlined,
                size: 20),
            onPressed: _toggleMarkers,
            tooltip: 'Markers',
            color: _showMarkers ? Colors.blue : null,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
          const SizedBox(width: 4),
          // Theme cycle button
          IconButton(
            icon: const Icon(Icons.palette_outlined, size: 20),
            onPressed: _cycleTheme,
            tooltip: 'Theme: ${_themeLabels[_themeIndex]}',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopToolbar(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Mode:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ...NepalSelectionMode.values.map((mode) {
              final active = _controller.mode == mode;
              return ChoiceChip(
                label:
                    Text(_labelFor(mode), style: const TextStyle(fontSize: 11)),
                selected: active,
                onSelected: (_) => _setMode(mode),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              );
            }),
            const SizedBox(width: 8),
            const Text('Overlays:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            FilterChip(
              label: const Text('Layers', style: TextStyle(fontSize: 11)),
              selected: _showLayers,
              onSelected: (_) => _toggleCoverageLayers(),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            FilterChip(
              label: const Text('Heatmap', style: TextStyle(fontSize: 11)),
              selected: _showHeatmap,
              onSelected: (_) => _toggleHeatmap(),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            FilterChip(
              label: const Text('Markers', style: TextStyle(fontSize: 11)),
              selected: _showMarkers,
              onSelected: (_) => _toggleMarkers(),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
            const SizedBox(width: 8),
            const Text('Theme:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ActionChip(
              label: Text(_themeLabels[_themeIndex],
                  style: const TextStyle(fontSize: 11)),
              onPressed: _cycleTheme,
              avatar: const Icon(Icons.palette_outlined, size: 12),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            const Text('Nepal Map - Demo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            _ShieldBadge(
              label: 'pub',
              status: 'v0.1.0',
              statusColor: const Color(0xFF007EC6),
              onTap: _launchPubUrl,
            ),
            _ShieldBadge(
              label: 'GitHub',
              status: 'ramkoirala1123/nepal_map_flutter',
              statusColor: const Color(0xFF4C1D95),
              onTap: _launchGithubUrl,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.onToggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Navigation Toolbar
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 8.0 : 16.0,
                  vertical: isMobile ? 4.0 : 8.0,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: isMobile
                    ? _buildMobileToolbar(isDark)
                    : _buildDesktopToolbar(isDark),
              ),

              // Map Area - give more flex on mobile
              Expanded(
                flex: isMobile ? 3 : 1,
                child: Container(
                  padding: EdgeInsets.all(isMobile ? 8.0 : 16.0),
                  child: Stack(
                    children: [
                      NepalMapWidget(
                        controller: _controller,
                        theme: _getTheme(),
                        onDistrictTap: (district) {
                          setState(() {
                            _lastEvent = 'Tapped: ${district.name}';
                          });
                        },
                        onProvinceTap: (pNum, _) {
                          setState(() {
                            _lastEvent = 'Province $pNum Tapped';
                          });
                        },
                        onDistrictHover: (district) {
                          setState(() {
                            _hovered = district?.name;
                          });
                        },
                      ),

                      // Floating Legend on Map (only when overlays active)
                      if (_showLayers || _showHeatmap)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            width: 180,
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 4),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LegendWidget(
                                controller: _controller,
                                title: 'Legend',
                                showLayers: _showLayers,
                                showHeatmap: _showHeatmap,
                                showSelection: false,
                                tileColor: isDark
                                    ? const Color(0xFF1E293B)
                                    : Colors.white,
                                contentPadding: const EdgeInsets.all(8),
                                textStyle: const TextStyle(fontSize: 10),
                                titleStyle: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),

                      // Zoom Controls HUD
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.grey.withOpacity(0.2)),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 4),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add, size: 18),
                                onPressed: _controller.zoomIn,
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove, size: 18),
                                onPressed: _controller.zoomOut,
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                onPressed: _controller.resetView,
                                constraints: const BoxConstraints(
                                    minWidth: 36, minHeight: 36),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Hover Status HUD (only on hover / desktop)
                      if (!isMobile && _hovered != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                            ),
                            child: Text(
                              _hovered!,
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Details Panel (shown when a district/province is selected)
              if (_controller.selectedDistricts.isNotEmpty ||
                  _controller.selectedProvinces.isNotEmpty)
                Container(
                  padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _buildFloatingDetailsCard(isDark),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: Text(
          _lastEvent,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ),
    );
  }
}

/// Custom horizontal badge mimicking shields.io badges
class _ShieldBadge extends StatelessWidget {
  final String label;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _ShieldBadge({
    required this.label,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 1),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: const Color(0xFF555555),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              color: statusColor,
              alignment: Alignment.center,
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'sans-serif',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityMarker extends StatelessWidget {
  final String label;
  final Color color;

  const _CityMarker({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
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
