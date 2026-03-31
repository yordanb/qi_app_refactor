class SSFilterParams {
  final String kategori; // staff / mech
  final String subKategori; // plt2 / pch / zero / <5 / etc
  final String? opsiTambahan; // null / pch / lighting / etc

  const SSFilterParams({
    required this.kategori,
    required this.subKategori,
    this.opsiTambahan,
  });

  SSFilterParams copyWith({
    String? kategori,
    String? subKategori,
    String? opsiTambahan,
  }) {
    return SSFilterParams(
      kategori: kategori ?? this.kategori,
      subKategori: subKategori ?? this.subKategori,
      opsiTambahan: opsiTambahan ?? this.opsiTambahan,
    );
  }
}
