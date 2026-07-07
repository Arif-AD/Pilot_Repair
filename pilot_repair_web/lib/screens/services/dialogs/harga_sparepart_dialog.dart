import 'package:flutter/material.dart';
import '../../../models/service.dart';
import '../../../services/service_api.dart';

class HargaSparepartDialog {
  static Future<void> showAddDialog(
    BuildContext context,
    List<Merk> merkList,
    List<Seri> seriList,
    List<JenisSparepart> jenisList,
    List<Layanan> layananList, {
    required VoidCallback onSuccess,
  }) async {
    Merk? selectedMerk;
    Seri? selectedSeri;
    Layanan? selectedLayanan;
    JenisSparepart? selectedJenis;
    final hargaController = TextEditingController();
    bool isLoading = false;

    List<Seri> getSeriByMerk(int? merkId) {
      if (merkId == null) return [];
      return seriList.where((s) => s.idMerk == merkId).toList();
    }
    List<JenisSparepart> getJenisByLayanan(int? layananId) {
      if (layananId == null) return [];
      return jenisList.where((j) => j.idLayanan == layananId).toList();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Harga Sparepart'),
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
                        setState(() {
                          selectedMerk = value;
                          selectedSeri = null;
                        });
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Seri>(
                value: selectedSeri,
                decoration: const InputDecoration(
                  labelText: 'Seri',
                  hintText: 'Pilih seri',
                ),
                items: getSeriByMerk(selectedMerk?.id).map((seri) {
                  return DropdownMenuItem(
                    value: seri,
                    child: Text(seri.namaSeri),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) => setState(() => selectedSeri = value),
              ),
              const SizedBox(height: 16),
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
                  setState(() {
                    selectedLayanan = value;
                    selectedJenis = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<JenisSparepart>(
                value: selectedJenis,
                decoration: const InputDecoration(
                  labelText: 'Jenis Sparepart',
                  hintText: 'Pilih jenis sparepart',
                ),
                items: getJenisByLayanan(selectedLayanan?.id).map((jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(jenis.namaJenis),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) => setState(() => selectedJenis = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Masukkan harga',
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
                      if (selectedMerk == null || selectedSeri == null || selectedLayanan == null || selectedJenis == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (hargaController.text.isEmpty || int.tryParse(hargaController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harga harus diisi dan berupa angka'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await ServiceApi.createHargaSparepart(
                          HargaSparepart(
                            id: 0,
                            idMerk: selectedMerk!.id,
                            idSeri: selectedSeri!.id,
                            idLayanan: selectedLayanan!.id,
                            idJenisSparepart: selectedJenis!.id,
                            harga: int.parse(hargaController.text),
                          ),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harga sparepart berhasil ditambahkan'),
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
    HargaSparepart harga,
    List<Merk> merkList,
    List<Seri> seriList,
    List<JenisSparepart> jenisList,
    List<Layanan> layananList, {
    required VoidCallback onSuccess,
  }) async {
    Merk? selectedMerk = merkList.firstWhere((m) => m.id == harga.idMerk, orElse: () => merkList.first);
    Seri? selectedSeri = seriList.firstWhere((s) => s.id == harga.idSeri, orElse: () => seriList.first);
    Layanan? selectedLayanan = layananList.firstWhere(
      (l) => jenisList.firstWhere((j) => j.id == harga.idJenisSparepart, orElse: () => jenisList.first).idLayanan == l.id,
      orElse: () => layananList.first,
    );
    JenisSparepart? selectedJenis = jenisList.firstWhere((j) => j.id == harga.idJenisSparepart, orElse: () => jenisList.first);
    final hargaController = TextEditingController(text: harga.harga.toString());
    bool isLoading = false;

    List<Seri> getSeriByMerk(int? merkId) {
      if (merkId == null) return [];
      return seriList.where((s) => s.idMerk == merkId).toList();
    }
    List<JenisSparepart> getJenisByLayanan(int? layananId) {
      if (layananId == null) return [];
      return jenisList.where((j) => j.idLayanan == layananId).toList();
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Harga Sparepart'),
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
                        setState(() {
                          selectedMerk = value;
                          selectedSeri = null;
                        });
                      },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Seri>(
                value: selectedSeri,
                decoration: const InputDecoration(
                  labelText: 'Seri',
                  hintText: 'Pilih seri',
                ),
                items: getSeriByMerk(selectedMerk?.id).map((seri) {
                  return DropdownMenuItem(
                    value: seri,
                    child: Text(seri.namaSeri),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) => setState(() => selectedSeri = value),
              ),
              const SizedBox(height: 16),
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
                  setState(() {
                    selectedLayanan = value;
                    selectedJenis = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<JenisSparepart>(
                value: selectedJenis,
                decoration: const InputDecoration(
                  labelText: 'Jenis Sparepart',
                  hintText: 'Pilih jenis sparepart',
                ),
                items: getJenisByLayanan(selectedLayanan?.id).map((jenis) {
                  return DropdownMenuItem(
                    value: jenis,
                    child: Text(jenis.namaJenis),
                  );
                }).toList(),
                onChanged: isLoading ? null : (value) => setState(() => selectedJenis = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Masukkan harga',
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
                      if (selectedMerk == null || selectedSeri == null || selectedLayanan == null || selectedJenis == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field harus dipilih'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      if (hargaController.text.isEmpty || int.tryParse(hargaController.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harga harus diisi dan berupa angka'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        await ServiceApi.updateHargaSparepart(
                          HargaSparepart(
                            id: harga.id,
                            idMerk: selectedMerk!.id,
                            idSeri: selectedSeri!.id,
                            idLayanan: selectedLayanan!.id,
                            idJenisSparepart: selectedJenis!.id,
                            harga: int.parse(hargaController.text),
                          ),
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harga sparepart berhasil diupdate'),
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
    HargaSparepart harga, {
    required VoidCallback onSuccess,
  }) async {
    bool isLoading = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Hapus Harga Sparepart'),
          content: const Text('Apakah Anda yakin ingin menghapus harga sparepart ini?'),
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
                        await ServiceApi.deleteHargaSparepart(harga.id);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          onSuccess();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Harga sparepart berhasil dihapus'),
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