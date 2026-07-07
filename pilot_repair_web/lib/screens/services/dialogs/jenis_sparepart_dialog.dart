import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';

class JenisSparepartDialog {
  static Future<void> showAddDialog(
    BuildContext context, {
    required List<Layanan> layananList,
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController();
    Layanan? selectedLayanan;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Tambah Jenis Sparepart'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Layanan>(
                    value: selectedLayanan,
                    items: layananList
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.namaLayanan)))
                        .toList(),
                    onChanged: isLoading ? null : (val) => setState(() => selectedLayanan = val),
                    decoration: const InputDecoration(labelText: 'Pilih Layanan'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nama Jenis',
                      hintText: 'Masukkan nama jenis sparepart',
                    ),
                    enabled: !isLoading,
                  ),
                ],
              ),
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
                        if (selectedLayanan == null || controller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field harus diisi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() => isLoading = true);
                        try {
                          await ServiceApi.createJenisSparepart(
                            idMerk: 0, // default
                            idSeri: 0, // default
                            idLayanan: selectedLayanan!.id,
                            namaJenis: controller.text,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onSuccess();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jenis sparepart berhasil ditambahkan'),
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
          );
        },
      ),
    );
  }

  static Future<void> showEditDialog(
    BuildContext context,
    JenisSparepart jenis, {
    required List<Layanan> layananList,
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController(text: jenis.namaJenis);
    Layanan? selectedLayanan = layananList.firstWhere((l) => l.id == jenis.idLayanan, orElse: () => layananList.first);
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Jenis Sparepart'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Layanan>(
                    value: selectedLayanan,
                    items: layananList
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.namaLayanan)))
                        .toList(),
                    onChanged: isLoading ? null : (val) => setState(() => selectedLayanan = val),
                    decoration: const InputDecoration(labelText: 'Pilih Layanan'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Nama Jenis',
                      hintText: 'Masukkan nama jenis sparepart',
                    ),
                    enabled: !isLoading,
                  ),
                ],
              ),
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
                        if (selectedLayanan == null || controller.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Semua field harus diisi'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        setState(() => isLoading = true);
                        try {
                          await ServiceApi.updateJenisSparepart(
                            jenis.id,
                            controller.text,
                            0, // default
                            0, // default
                            selectedLayanan!.id,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                            onSuccess();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jenis sparepart berhasil diupdate'),
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
          );
        },
      ),
    );
  }

  static Future<void> showDeleteDialog(
    BuildContext context,
    JenisSparepart jenis, {
    required VoidCallback onSuccess,
  }) async {
    bool isLoading = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus Jenis Sparepart'),
          content: Text('Apakah Anda yakin ingin menghapus jenis sparepart "${jenis.namaJenis}"?'),
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
                        await ServiceApi.deleteJenisSparepart(jenis.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Jenis sparepart berhasil dihapus'),
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
                  : const Text('Hapus'),
            ),
          ],
        ),
      ),
    );
  }
} 