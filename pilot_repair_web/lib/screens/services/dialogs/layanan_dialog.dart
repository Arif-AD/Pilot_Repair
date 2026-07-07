import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';
import 'dart:html' as html;

class LayananDialog {
  static Future<void> showAddDialog(
    BuildContext context, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController();
    html.File? selectedIcon;
    String? selectedIconName;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Layanan',
                  hintText: 'Masukkan nama layanan',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(selectedIconName ?? 'Pilih Icon Layanan'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final uploadInput = html.FileUploadInputElement();
                            uploadInput.accept = 'image/*';
                            uploadInput.click();
                            uploadInput.onChange.listen((event) {
                              final files = uploadInput.files;
                              if (files != null && files.isNotEmpty) {
                                setState(() {
                                  selectedIcon = files.first;
                                  selectedIconName = files.first.name;
                                });
                              }
                            });
                          },
                  ),
                ],
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
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama layanan tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (selectedIcon == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Icon layanan harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        // Upload icon
                        final iconFileName = await ServiceApi.uploadIconWeb(selectedIcon!, controller.text);
                        await ServiceApi.createLayanan(controller.text, iconFileName);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Layanan berhasil ditambahkan'),
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
    Layanan layanan, {
    required VoidCallback onSuccess,
  }) async {
    final controller = TextEditingController(text: layanan.namaLayanan);
    html.File? selectedIcon;
    String? selectedIconName;
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Nama Layanan',
                  hintText: 'Masukkan nama layanan',
                ),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(selectedIconName ?? layanan.iconLayanan ?? 'Pilih Icon Layanan'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final uploadInput = html.FileUploadInputElement();
                            uploadInput.accept = 'image/*';
                            uploadInput.click();
                            uploadInput.onChange.listen((event) {
                              final files = uploadInput.files;
                              if (files != null && files.isNotEmpty) {
                                setState(() {
                                  selectedIcon = files.first;
                                  selectedIconName = files.first.name;
                                });
                              }
                            });
                          },
                  ),
                  if (layanan.iconLayanan != null && layanan.iconLayanan!.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      tooltip: 'Hapus Icon',
                      onPressed: isLoading
                          ? null
                          : () async {
                              setState(() => isLoading = true);
                              try {
                                await ServiceApi.deleteIcon(layanan.iconLayanan!);
                                await ServiceApi.updateLayanan(layanan.id, controller.text, null);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  onSuccess();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Icon berhasil dihapus'),
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
                    ),
                ],
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
                      if (controller.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama layanan tidak boleh kosong'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        String? iconFileName = layanan.iconLayanan;
                        if (selectedIcon != null) {
                          iconFileName = await ServiceApi.uploadIconWeb(selectedIcon!, controller.text);
                        }
                        await ServiceApi.updateLayanan(layanan.id, controller.text, iconFileName);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Layanan berhasil diupdate'),
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
    Layanan layanan, {
    required VoidCallback onSuccess,
  }) async {
    bool isLoading = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus Layanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Apakah Anda yakin ingin menghapus layanan "${layanan.namaLayanan}"?'),
              const SizedBox(height: 8),
              const Text(
                'Perhatian: Menghapus layanan akan menghapus semua kerusakan yang terkait dengan layanan ini.',
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
                        await ServiceApi.deleteLayanan(layanan.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Layanan berhasil dihapus'),
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