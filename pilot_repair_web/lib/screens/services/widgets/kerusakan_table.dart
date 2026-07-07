import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';
import '../dialogs/kerusakan_dialog.dart';

class KerusakanTable extends StatefulWidget {
  final List<Kerusakan> kerusakanList;
  final List<Layanan> layananList;
  final VoidCallback onRefresh;

  const KerusakanTable({
    super.key,
    required this.kerusakanList,
    required this.layananList,
    required this.onRefresh,
  });

  @override
  State<KerusakanTable> createState() => _KerusakanTableState();
}

class _KerusakanTableState extends State<KerusakanTable> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 24),
        _buildContent(),
      ],
    );
  }

  Widget _buildHeader() {
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
                'Daftar Kerusakan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola kerusakan berdasarkan layanan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          FilledButton.icon(
            onPressed: () {
              KerusakanDialog.showAddDialog(
                context,
                widget.layananList,
                onSuccess: widget.onRefresh,
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
      ),
    );
  }

  Widget _buildContent() {
    if (widget.kerusakanList.isEmpty) {
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
                'Belum ada kerusakan',
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
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  KerusakanDialog.showAddDialog(
                    context,
                    widget.layananList,
                    onSuccess: widget.onRefresh,
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Kerusakan'),
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
          DataColumn(
            label: Text('ID'),
          ),
          DataColumn(
            label: Text('Nama Kerusakan'),
          ),
          DataColumn(
            label: Text('Layanan'),
          ),
          DataColumn(
            label: Text('Aksi'),
          ),
        ],
        rows: widget.kerusakanList.map((kerusakan) {
          final layanan = widget.layananList.firstWhere(
            (l) => l.id == kerusakan.idLayanan,
            orElse: () => Layanan(id: kerusakan.idLayanan, namaLayanan: '-'),
          );
          return DataRow(
            cells: [
              DataCell(Text(kerusakan.id.toString())),
              DataCell(Text(kerusakan.namaKerusakan)),
              DataCell(Text(layanan.namaLayanan)),
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
                        onSuccess: widget.onRefresh,
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