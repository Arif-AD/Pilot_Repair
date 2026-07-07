import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';

class SeriDialog {
  static Future<void> showAddDialog(
    BuildContext context,
    List<Merk> merkList, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController();
    Merk? selectedMerk;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Seri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Merk>(
                value: selectedMerk,
                decoration: const InputDecoration(
                  labelText: 'Merk',
                  hintText: 'Pilih merk',
                ),
                items: merkList.map((merk) {
                  return DropdownMenuItem(
                    value: merk,
                    child: Text(merk.namaMerk),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => selectedMerk = value);
                      },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Seri',
                  hintText: 'Masukkan nama seri',
                ),
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedMerk == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Merk harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama seri tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await ServiceApi.createSeri(
                          selectedMerk!.id,
                          controller.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seri berhasil ditambahkan'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: ${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
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
    Seri seri,
    List<Merk> merkList, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController(text: seri.namaSeri);
    Merk? selectedMerk = merkList.firstWhere((m) => m.id == seri.idMerk);
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Seri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Merk>(
                value: selectedMerk,
                decoration: const InputDecoration(
                  labelText: 'Merk',
                  hintText: 'Pilih merk',
                ),
                items: merkList.map((merk) {
                  return DropdownMenuItem(
                    value: merk,
                    child: Text(merk.namaMerk),
                  );
                }).toList(),
                onChanged: isLoading
                    ? null
                    : (value) {
                        setState(() => selectedMerk = value);
                      },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Seri',
                  hintText: 'Masukkan nama seri',
                ),
                enabled: !isLoading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (selectedMerk == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Merk harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama seri tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      setState(() => isLoading = true);

                      try {
                        await ServiceApi.updateSeri(
                          seri.id,
                          selectedMerk!.id,
                          controller.text,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seri berhasil diupdate'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: ${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
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
    Seri seri, {
    required VoidCallback onSuccess,
  }) async {
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus Seri'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus seri "${seri.namaSeri}"?'),
              const SizedBox(height: 8),
              const Text(
                'Perhatian: Menghapus seri akan menghapus semua harga layanan yang terkait dengan seri ini.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading
                  ? null
                  : () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);

                      try {
                        await ServiceApi.deleteSeri(seri.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seri berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal: ${e is Exception ? e.toString().replaceAll('Exception: ', '') : e}'),
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