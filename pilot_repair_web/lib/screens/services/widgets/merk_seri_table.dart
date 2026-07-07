import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';
import '../dialogs/merk_dialog.dart';
import '../dialogs/seri_dialog.dart';

class MerkSeriTable extends StatefulWidget {
  final List<Merk> merkList;
  final List<Seri> seriList;
  final VoidCallback onRefresh;

  const MerkSeriTable({
    super.key,
    required this.merkList,
    required this.seriList,
    required this.onRefresh,
  });

  @override
  State<MerkSeriTable> createState() => _MerkSeriTableState();
}

class _MerkSeriTableState extends State<MerkSeriTable> {
  int? _selectedMerkId;
  List<Seri> _filteredSeriList = [];
  bool _isLoading = false;
  String? _error;
  bool _showAllMerk = false;

  @override
  void initState() {
    super.initState();
    if (widget.merkList.isNotEmpty) {
      _selectedMerkId = widget.merkList.first.id;
      _filterSeri();
    }
  }

  void _filterSeri() {
    if (_selectedMerkId == null) {
      _filteredSeriList = [];
    } else {
      _filteredSeriList = widget.seriList
          .where((seri) => seri.idMerk == _selectedMerkId)
          .toList();
    }
  }

  Future<void> _loadSeri() async {
    if (_selectedMerkId == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final seriList = await ServiceApi.getSeri(_selectedMerkId!);
      setState(() {
        _filteredSeriList = seriList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Urutkan merk berdasarkan id ascending
    List<Merk> sortedMerkList = List.from(widget.merkList)..sort((a, b) => a.id.compareTo(b.id));
    List<Merk> merkToShow = sortedMerkList;
    if (!_showAllMerk && sortedMerkList.length > 3) {
      merkToShow = sortedMerkList.take(3).toList();
    }
    // Urutkan seri berdasarkan id ascending
    List<Seri> sortedSeriList = List.from(widget.seriList)..sort((a, b) => a.id.compareTo(b.id));
    _filteredSeriList = sortedSeriList.where((seri) => seri.idMerk == _selectedMerkId).toList();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daftar Merk',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.all(
                      Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                    ),
                    dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Theme.of(context).colorScheme.primary.withOpacity(0.1);
                      }
                      return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1);
                    }),
                    columns: [
                      DataColumn(
                        label: Text(
                          'ID',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Nama Merk',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Aksi',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                    rows: merkToShow.map((merk) {
                      return DataRow(
                        cells: [
                          DataCell(Text(merk.id.toString(), style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          DataCell(Text(merk.namaMerk, style: TextStyle(color: Theme.of(context).colorScheme.onSurface))),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: 'Edit',
                                onPressed: () {
                                  MerkDialog.showEditDialog(
                                    context,
                                    merk,
                                    onSuccess: widget.onRefresh,
                                  );
                                },
                                style: IconButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20),
                                tooltip: 'Hapus',
                                onPressed: () {
                                  MerkDialog.showDeleteDialog(
                                    context,
                                    merk,
                                    onSuccess: widget.onRefresh,
                                  );
                                },
                                style: IconButton.styleFrom(
                                  foregroundColor: Theme.of(context).colorScheme.error,
                                  backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
                if (widget.merkList.length > 3)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showAllMerk = !_showAllMerk;
                      });
                    },
                    child: Text(_showAllMerk ? 'Sembunyikan' : 'Tampilkan Semua'),
                  ),
              ],
            ),
          ),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonFormField<int>(
                value: _selectedMerkId,
                decoration: InputDecoration(
                  labelText: 'Pilih Merk',
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  prefixIcon: Icon(
                    Icons.category_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                items: widget.merkList.map((merk) {
                  return DropdownMenuItem(
                    value: merk.id,
                    child: Text(
                      merk.namaMerk,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMerkId = value;
                    _filterSeri();
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 24),
          FilledButton.icon(
            onPressed: () {
              MerkDialog.showAddDialog(
                context,
                onSuccess: widget.onRefresh,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Merk'),
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
      ),
    );
  }

  Widget _buildContent() {
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
        child: Padding(
          padding: const EdgeInsets.all(32),
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
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadSeri,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daftar Seri',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              FilledButton.icon(
                onPressed: _selectedMerkId == null
                    ? null
                    : () {
                        SeriDialog.showAddDialog(
                          context,
                          widget.merkList,
                          onSuccess: _loadSeri,
                        );
                      },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Seri'),
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
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(
                Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              ),
              dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Theme.of(context).colorScheme.primary.withOpacity(0.1);
                  }
                  return Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1);
                },
              ),
              columns: [
                DataColumn(
                  label: Text(
                    'ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Nama Seri',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Aksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              rows: _filteredSeriList.map((seri) {
                return DataRow(
                  cells: [
                    DataCell(Text(
                      seri.id.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                    DataCell(Text(
                      seri.namaSeri,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    )),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              SeriDialog.showEditDialog(
                                context,
                                seri,
                                widget.merkList,
                                onSuccess: _loadSeri,
                              );
                            },
                            tooltip: 'Edit',
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20),
                            onPressed: () {
                              SeriDialog.showDeleteDialog(
                                context,
                                seri,
                                onSuccess: _loadSeri,
                              );
                            },
                            tooltip: 'Hapus',
                            style: IconButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.error,
                              backgroundColor: Theme.of(context).colorScheme.errorContainer.withOpacity(0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
} 