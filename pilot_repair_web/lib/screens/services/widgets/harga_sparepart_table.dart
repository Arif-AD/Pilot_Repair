import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../dialogs/harga_sparepart_dialog.dart';

class HargaSparepartTable extends StatefulWidget {
  final List<HargaSparepart> hargaList;
  final List<Merk> merkList;
  final List<Seri> seriList;
  final List<JenisSparepart> jenisList;
  final List<Layanan> layananList;
  final VoidCallback onRefresh;

  const HargaSparepartTable({
    super.key,
    required this.hargaList,
    required this.merkList,
    required this.seriList,
    required this.jenisList,
    required this.layananList,
    required this.onRefresh,
  });

  @override
  State<HargaSparepartTable> createState() => _HargaSparepartTableState();
}

class _HargaSparepartTableState extends State<HargaSparepartTable> {
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
    final filteredHarga = _selectedLayanan == null
        ? <HargaSparepart>[]
        : widget.hargaList.where((h) {
            final jenis = widget.jenisList.firstWhere(
              (j) => j.id == h.idJenisSparepart,
              orElse: () => JenisSparepart(
                id: h.idJenisSparepart,
                idLayanan: 0,
                namaLayanan: '-',
                namaJenis: '-',
              ),
            );
            return jenis.idLayanan == _selectedLayanan!.id;
          }).toList();
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
        _buildContent(context, filteredHarga),
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
                'Daftar Harga Sparepart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola harga sparepart berdasarkan merk, seri, layanan, dan jenis',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: () {
              HargaSparepartDialog.showAddDialog(
                context,
                widget.merkList,
                widget.seriList,
                widget.jenisList,
                widget.layananList,
                onSuccess: widget.onRefresh,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Harga'),
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

  Widget _buildContent(BuildContext context, List<HargaSparepart> hargaList) {
    if (hargaList.isEmpty) {
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
                Icons.price_change_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Belum ada harga sparepart',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan harga sparepart pertama Anda',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  HargaSparepartDialog.showAddDialog(
                    context,
                    widget.merkList,
                    widget.seriList,
                    widget.jenisList,
                    widget.layananList,
                    onSuccess: widget.onRefresh,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Harga'),
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
          DataColumn(label: Text('Merk')),
          DataColumn(label: Text('Seri')),
          DataColumn(label: Text('Layanan')),
          DataColumn(label: Text('Jenis Sparepart')),
          DataColumn(label: Text('Harga')),
          DataColumn(label: Text('Aksi')),
        ],
        rows: hargaList.map((harga) {
          final merk = widget.merkList.firstWhere((m) => m.id == harga.idMerk, orElse: () => Merk(id: harga.idMerk, namaMerk: '-'));
          final seri = widget.seriList.firstWhere((s) => s.id == harga.idSeri, orElse: () => Seri(id: harga.idSeri, idMerk: harga.idMerk, namaSeri: '-'));
          final jenis = widget.jenisList.firstWhere(
            (j) => j.id == harga.idJenisSparepart,
            orElse: () => JenisSparepart(
              id: harga.idJenisSparepart,
              idLayanan: 0,
              namaLayanan: '-',
              namaJenis: '-',
            ),
          );
          final layanan = widget.layananList.firstWhere((l) => l.id == jenis.idLayanan, orElse: () => Layanan(id: 0, namaLayanan: '-'));
          return DataRow(
            cells: [
              DataCell(Text(merk.namaMerk)),
              DataCell(Text(seri.namaSeri)),
              DataCell(Text(layanan.namaLayanan)),
              DataCell(Text(jenis.namaJenis)),
              DataCell(Text(harga.harga.toString())),
              DataCell(Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () {
                      HargaSparepartDialog.showEditDialog(
                        context,
                        harga,
                        widget.merkList,
                        widget.seriList,
                        widget.jenisList,
                        widget.layananList,
                        onSuccess: widget.onRefresh,
                      );
                    },
                    tooltip: 'Edit',
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () {
                      HargaSparepartDialog.showDeleteDialog(
                        context,
                        harga,
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