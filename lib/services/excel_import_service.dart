import 'dart:typed_data';
import 'package:excel/excel.dart';
import '../models/institution.dart';

class ExcelImportService {
  List<Institution> parseExcel(Uint8List bytes) {
    final excel = Excel.decodeBytes(bytes);
    final institutions = <Institution>[];

    final sheet = excel.tables.values.first;
    if (sheet.rows.isEmpty) return institutions;

    final headers = sheet.rows.first.map((c) => c?.value?.toString().toLowerCase().trim() ?? '').toList();

    int col(String name) => headers.indexOf(name);

    for (var i = 1; i < sheet.rows.length; i++) {
      final row = sheet.rows[i];
      if (row.every((c) => c == null || c.value == null)) continue;

      String cell(int index) {
        if (index < 0 || index >= row.length) return '';
        return row[index]?.value?.toString().trim() ?? '';
      }

      final lat = double.tryParse(cell(col('latitude'))) ?? 0.0;
      final lngStr = cell(col('longitude')).isNotEmpty ? cell(col('longitude')) : cell(col('longitudine'));
      final lng = double.tryParse(lngStr) ?? 0.0;

      final name = cell(col('nome')) != '' ? cell(col('nome')) : cell(col('name'));
      if (name.isEmpty) continue;

      institutions.add(Institution(
        id: 'excel_$i',
        name: name,
        address: cell(col('endereco')) != '' ? cell(col('endereco')) : cell(col('address')),
        neighborhood: cell(col('bairro')) != '' ? cell(col('bairro')) : cell(col('neighborhood')),
        phone: _nullIfEmpty(cell(col('telefone')) != '' ? cell(col('telefone')) : cell(col('phone'))),
        whatsapp: _nullIfEmpty(cell(col('whatsapp'))),
        category: InstitutionCategory.fromString(
          cell(col('categoria')) != '' ? cell(col('categoria')) : cell(col('category')),
        ),
        services: (cell(col('servicos')) != '' ? cell(col('servicos')) : cell(col('services')))
            .split(';')
            .where((s) => s.isNotEmpty)
            .toList(),
        schedule: _nullIfEmpty(cell(col('horario')) != '' ? cell(col('horario')) : cell(col('schedule'))),
        observations: _nullIfEmpty(cell(col('observacoes')) != '' ? cell(col('observacoes')) : cell(col('observations'))),
        sphere: Institution.parseSphere(cell(col('esfera')) != '' ? cell(col('esfera')) : cell(col('sphere'))),
        latitude: lat,
        longitude: lng,
        acceptsIndigent: _parseBool(cell(col('atende_gratuito'))),
        isActive: _parseBool(cell(col('ativo')), defaultValue: true),
      ));
    }

    return institutions;
  }

  String? _nullIfEmpty(String s) => s.isEmpty ? null : s;

  bool _parseBool(String s, {bool defaultValue = false}) {
    if (s.isEmpty) return defaultValue;
    final l = s.toLowerCase();
    return l == 'sim' || l == 'true' || l == '1' || l == 'yes';
  }
}
