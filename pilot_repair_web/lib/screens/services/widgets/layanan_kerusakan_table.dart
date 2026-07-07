import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';
import '../dialogs/layanan_dialog.dart';
import '../dialogs/kerusakan_dialog.dart';

class LayananKerusakanTable extends StatefulWidget {
  final List<Layanan> layananList;
  final List<Kerusakan> kerusakanList;
  final VoidCallback onRefresh;

  const LayananKerusakanTable({
    super.key,
    required this.layananList,
    required this.kerusakanList,
    required this.onRefresh,
  });

  @override
  State<LayananKerusakanTable> createState() => _LayananKerusakanTableState();
}

class _LayananKerusakanTableState extends State<LayananKerusakanTable> {
  int? _selectedLayananId;
  List<Kerusakan> _filteredKerusakanList = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.layananList.isNotEmpty) {
      _selectedLayananId = widget.layananList.first.id;
      _loadKerusakan();
    }
  }

  @override
  void didUpdateWidget(covariant LayananKerusakanTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.layananList.isNotEmpty &&
        (oldWidget.layananList != widget.layananList)) {
      if (_selectedLayananId == null ||
          !widget.layananList.any((l) => l.id == _selectedLayananId)) {
        _selectedLayananId = widget.layananList.first.id;
      }
      _loadKerusakan();
    }
    if (oldWidget.kerusakanList != widget.kerusakanList) {
      _loadKerusakan();
    }
  }

  void _filterKerusakan() {
    if (_selectedLayananId == null) {
      _filteredKerusakanList = [];
    }
    setState(() {});
  }

  Future<void> _loadKerusakan() async {
    if (_selectedLayananId == null) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final kerusakanList = await ServiceApi.getKerusakan(_selectedLayananId!);
      setState(() {
        _filteredKerusakanList = kerusakanList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _refreshKerusakan() {
    _loadKerusakan();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLayananHeader(),
        const SizedBox(height: 16),
        _buildLayananTable(),
        const SizedBox(height: 32),
        _buildKerusakanHeader(),
        const SizedBox(height: 16),
        _buildKerusakanTable(),
      ],
    );
  }

  Widget _buildLayananHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _selectedLayananId,
            decoration: InputDecoration(
              labelText: 'Pilih Layanan',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              prefixIcon: Icon(
                Icons.build,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            items: widget.layananList.map((layanan) {
              return DropdownMenuItem(
                value: layanan.id,
                child: Text(layanan.namaLayanan),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedLayananId = value;
              });
              _loadKerusakan();
            },
          ),
        ),
        const SizedBox(width: 24),
        FilledButton.icon(
          onPressed: () {
            LayananDialog.showAddDialog(
              context,
              onSuccess: widget.onRefresh,
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Layanan'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildLayananTable() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: DataTable(
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        dataTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        columns: [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nama Layanan')),
          DataColumn(label: Text('Icon')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: widget.layananList.map((layanan) {
          return DataRow(
            selected: _selectedLayananId == layanan.id,
            cells: [
              DataCell(Text(layanan.id.toString())),
              DataCell(Text(layanan.namaLayanan)),
              DataCell(layanan.iconLayanan != null && layanan.iconLayanan!.isNotEmpty
                  ? Image.network('http://localhost:8080/assets/database/${layanan.iconLayanan}', width: 32, height: 32)
                  : const Text('-')),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      LayananDialog.showEditDialog(
                        context,
                        layanan,
                        onSuccess: widget.onRefresh,
                      );
                    },
                    tooltip: 'Edit',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      LayananDialog.showDeleteDialog(
                        context,
                        layanan,
                        onSuccess: widget.onRefresh,
                      );
                    },
                    tooltip: 'Hapus',
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKerusakanHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Kerusakan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        FilledButton.icon(
          onPressed: _selectedLayananId == null
              ? null
              : () {
                  KerusakanDialog.showAddDialog(
                    context,
                    widget.layananList,
                    onSuccess: () {
                      widget.onRefresh();
                      _refreshKerusakan();
                    },
                  );
                },
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kerusakan'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildKerusakanTable() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
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
            ],
          ),
        ),
      );
    }
    if (_filteredKerusakanList.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada kerusakan untuk layanan ini',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan kerusakan pertama Anda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: DataTable(
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        dataTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        columns: [
          DataColumn(label: Text('ID')),
          DataColumn(label: Text('Nama Kerusakan')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: _filteredKerusakanList.map((kerusakan) {
          return DataRow(
            cells: [
              DataCell(Text(kerusakan.id.toString())),
              DataCell(Text(kerusakan.namaKerusakan)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      KerusakanDialog.showEditDialog(
                        context,
                        kerusakan,
                        widget.layananList,
                        onSuccess: () {
                          widget.onRefresh();
                          _refreshKerusakan();
                        },
                      );
                    },
                    tooltip: 'Edit',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      KerusakanDialog.showDeleteDialog(
                        context,
                        kerusakan,
                        onSuccess: () {
                          widget.onRefresh();
                          _refreshKerusakan();
                        },
                      );
                    },
                    tooltip: 'Hapus',
                  ),
                ],
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
} 