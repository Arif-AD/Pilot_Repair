import 'package:flutter/material.dart';
import '../../widgets/layout/admin_layout.dart';
import '../../services/service_api.dart';
import '../../models/service.dart';
import 'widgets/merk_seri_table.dart';
import 'widgets/kerusakan_table.dart';
import 'widgets/layanan_kerusakan_table.dart';
import 'widgets/jenis_sparepart_table.dart';
import 'widgets/harga_sparepart_table.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Merk> _merkList = [];
  List<Seri> _seriList = [];
  List<Layanan> _layananList = [];
  List<Kerusakan> _kerusakanList = [];
  List<JenisSparepart> _jenisSparepartList = [];
  List<HargaLayanan> _hargaLayananList = [];
  List<HargaSparepart> _hargaSparepartList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final merk = await ServiceApi.getMerk();
      final seri = await ServiceApi.getSeri(0);
      final layanan = await ServiceApi.getLayanan();
      final kerusakan = await ServiceApi.getKerusakan(0);
      final jenisSparepart = await ServiceApi.getJenisSparepart();
      final hargaLayanan = await ServiceApi.getHargaLayanan();
      final hargaSparepart = await ServiceApi.getHargaSparepart();
      if (!mounted) return;
      setState(() {
        _merkList = merk;
        _seriList = seri;
        _layananList = layanan;
        _kerusakanList = kerusakan;
        _jenisSparepartList = jenisSparepart;
        _hargaLayananList = hargaLayanan;
        _hargaSparepartList = hargaSparepart;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Coba Lagi',
            onPressed: _loadData,
            textColor: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader()
                .animate()
                .fadeIn(duration: 600.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 24),
            _buildTabBar()
                .animate()
                .fadeIn(duration: 800.ms, delay: 200.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent()
                  .animate()
                  .fadeIn(duration: 800.ms, delay: 400.ms)
                  .slideY(begin: 0.2, end: 0),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF10B981).withOpacity(0.12),
            const Color(0xFF3B82F6).withOpacity(0.12),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.build_rounded,
                  color: const Color(0xFF10B981),
                  size: 32,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manajemen Layanan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kelola data layanan, merk, seri, dan harga',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Merk & Seri'),
          Tab(text: 'Layanan & Kerusakan'),
          Tab(text: 'Jenis Sparepart'),
          Tab(text: 'Harga Sparepart'),
        ],
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_error != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.error.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadData,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          child: MerkSeriTable(
            merkList: _merkList,
            seriList: _seriList,
            onRefresh: _loadData,
          ),
        ),
        SingleChildScrollView(
          child: LayananKerusakanTable(
            layananList: _layananList,
            kerusakanList: _kerusakanList,
            onRefresh: _loadData,
          ),
        ),
        SingleChildScrollView(
          child: JenisSparepartTable(
            jenisList: _jenisSparepartList,
            layananList: _layananList,
            onRefresh: _loadData,
          ),
        ),
        SingleChildScrollView(
          child: HargaSparepartTable(
            hargaList: _hargaSparepartList,
            merkList: _merkList,
            seriList: _seriList,
            jenisList: _jenisSparepartList,
            layananList: _layananList,
            onRefresh: _loadData,
          ),
        ),
      ],
    );
  }
} 