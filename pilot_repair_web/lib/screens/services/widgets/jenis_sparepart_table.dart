import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../dialogs/jenis_sparepart_dialog.dart';

class JenisSparepartTable extends StatefulWidget {
  final List<JenisSparepart> jenisList;
  final List<Layanan> layananList;
  final VoidCallback onRefresh;

  const JenisSparepartTable({
    super.key,
    required this.jenisList,
    required this.layananList,
    required this.onRefresh,
  });

  @override
  State<JenisSparepartTable> createState() => _JenisSparepartTableState();
}

class _JenisSparepartTableState extends State<JenisSparepartTable> {
  Layanan? _selectedLayanan;

  @override
  void initState() {
    super.initState();
    if (widget.layananList.isNotEmpty) {
      _selectedLayanan = widget.layananList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredJenis = _selectedLayanan == null
        ? <JenisSparepart>[]
        : widget.jenisList.where((j) => j.idLayanan == _selectedLayanan!.id).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Filter Layanan: '),
            const SizedBox(width: 8),
            DropdownButton<Layanan>(
              value: _selectedLayanan,
              items: widget.layananList
                  .map((l) => DropdownMenuItem(value: l, child: Text(l.namaLayanan)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedLayanan = val),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildContent(context, filteredJenis),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daftar Jenis Sparepart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola jenis sparepart berdasarkan layanan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: () {
              JenisSparepartDialog.showAddDialog(
                context,
                layananList: widget.layananList,
                onSuccess: widget.onRefresh,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Jenis'),
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

  Widget _buildContent(BuildContext context, List<JenisSparepart> jenisList) {
    if (jenisList.isEmpty) {
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
                Icons.extension_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada jenis sparepart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan jenis sparepart pertama Anda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  JenisSparepartDialog.showAddDialog(
                    context,
                    layananList: widget.layananList,
                    onSuccess: widget.onRefresh,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Jenis'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
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
          DataColumn(label: Text('Layanan')),
          DataColumn(label: Text('Nama Jenis')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: jenisList.map((jenis) {
          return DataRow(
            cells: [
              DataCell(Text(jenis.namaLayanan)),
              DataCell(Text(jenis.namaJenis)),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      JenisSparepartDialog.showEditDialog(
                        context,
                        jenis,
                        layananList: widget.layananList,
                        onSuccess: widget.onRefresh,
                      );
                    },
                    tooltip: 'Edit',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      JenisSparepartDialog.showDeleteDialog(
                        context,
                        jenis,
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
} 