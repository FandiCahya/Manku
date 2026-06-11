class FinancialAdvice {
  final String statusKeuangan;
  final String ringkasanAnalisis;
  final List<String> saranList;

  const FinancialAdvice({
    required this.statusKeuangan,
    required this.ringkasanAnalisis,
    required this.saranList,
  });

  factory FinancialAdvice.fromJson(Map<String, dynamic> json) {
    final list = json['saran_list'] as List<dynamic>? ?? [];
    return FinancialAdvice(
      statusKeuangan: json['status_keuangan'] as String? ?? 'Belum Menganalisis',
      ringkasanAnalisis: json['ringkasan_analisis'] as String? ?? '',
      saranList: list.map((e) => e.toString()).toList(),
    );
  }
}
