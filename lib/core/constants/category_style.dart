import 'package:flutter/widgets.dart';
import '../../models/institution.dart';
import 'app_colors.dart';

/// Fonte única de ícone e cor por categoria.
///
/// A mesma cor é usada na grade da home, nos cards de resultado e nos pinos do
/// mapa (a cor É a legenda). `iconName` aponta para um SVG em `assets/icons/`.
extension CategoryStyle on InstitutionCategory {
  String get iconName {
    switch (this) {
      case InstitutionCategory.familia:
        return 'familia';
      case InstitutionCategory.trabalho:
        return 'trabalho';
      case InstitutionCategory.violenciaDomestica:
        return 'violencia';
      case InstitutionCategory.consumidor:
        return 'consumidor';
      case InstitutionCategory.moradia:
        return 'moradia';
      case InstitutionCategory.documentos:
        return 'documentos';
      case InstitutionCategory.direitosMulher:
        return 'mulher';
      case InstitutionCategory.aposentadoria:
        return 'aposentadoria';
      case InstitutionCategory.saude:
        return 'saude';
      case InstitutionCategory.denuncias:
        return 'denuncias';
      case InstitutionCategory.outros:
        return 'outros';
    }
  }

  Color get color {
    switch (this) {
      case InstitutionCategory.familia:
        return AppColors.categoryFamilia;
      case InstitutionCategory.trabalho:
        return AppColors.categoryTrabalho;
      case InstitutionCategory.violenciaDomestica:
        return AppColors.categoryViolencia;
      case InstitutionCategory.consumidor:
        return AppColors.categoryConsumidor;
      case InstitutionCategory.moradia:
        return AppColors.categoryMoradia;
      case InstitutionCategory.documentos:
        return AppColors.categoryDocumentos;
      case InstitutionCategory.direitosMulher:
        return AppColors.categoryMulher;
      case InstitutionCategory.aposentadoria:
        return AppColors.categoryAposentadoria;
      case InstitutionCategory.saude:
        return AppColors.categorySaude;
      case InstitutionCategory.denuncias:
        return AppColors.categoryDenuncias;
      case InstitutionCategory.outros:
        return AppColors.categoryOutros;
    }
  }
}
