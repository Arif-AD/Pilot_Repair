import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';

class KerusakanDialog {
  static Future<void> showAddDialog(
    BuildContext context,
    List<Layanan> layananList, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController();
    Layanan? selectedLayanan;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Kerusakan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Layanan>(
                value: selectedLayanan,
                decoration: const InputDecoration(
                  labelText: 'Layanan',
                  hintText: 'Pilih layanan',
                ),
                items: layananList.map((layanan) {
                  return DropdownMenuItem(
                    value: layanan,
                    child: Text(layanan.namaLayanan),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) {
                  setState(() => selectedLayanan = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Kerusakan',
                  hintText: 'Masukkan nama kerusakan',
                ),
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedLayanan == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Layanan harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama kerusakan tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await ServiceApi.createKerusakan(
                          selectedLayanan!.id,
                          controller.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kerusakan berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: \\${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showEditDialog(
    BuildContext context,
    Kerusakan kerusakan,
    List<Layanan> layananList, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController(text: kerusakan.namaKerusakan);
    Layanan? selectedLayanan = layananList.firstWhere((l) => l.id == kerusakan.idLayanan, orElse: () => layananList.first);
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Kerusakan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Layanan>(
                value: selectedLayanan,
                decoration: const InputDecoration(
                  labelText: 'Layanan',
                  hintText: 'Pilih layanan',
                ),
                items: layananList.map((layanan) {
                  return DropdownMenuItem(
                    value: layanan,
                    child: Text(layanan.namaLayanan),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) {
                  setState(() => selectedLayanan = value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Kerusakan',
                  hintText: 'Masukkan nama kerusakan',
                ),
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedLayanan == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Layanan harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama kerusakan tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await ServiceApi.updateKerusakan(
                          kerusakan.id,
                          selectedLayanan!.id,
                          controller.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kerusakan berhasil diupdate'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: \\${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> showDeleteDialog(
    BuildContext context,
    Kerusakan kerusakan, {
    required VoidCallback onSuccess,
  }) async {
    bool isLoading = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus Kerusakan'),
          content: Text('Apakah Anda yakin ingin menghapus kerusakan "${kerusakan.namaKerusakan}"?'),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        await ServiceApi.deleteKerusakan(kerusakan.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kerusakan berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: \\${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } finally {
                        if (context.mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Hapus'),
            ),
          ],
        ),
      ),
    );
  }
} 