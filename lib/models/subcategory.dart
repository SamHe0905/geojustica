import 'package:flutter/material.dart';
import 'institution.dart';

class Subcategory {
  final String id;
  final String label;
  final IconData icon;
  final List<String>? requiredDocs;
  final String? quickTip;

  const Subcategory({
    required this.id,
    required this.label,
    required this.icon,
    this.requiredDocs,
    this.quickTip,
  });
}

class SubcategoryRegistry {
  static List<Subcategory> get(InstitutionCategory cat) {
    switch (cat) {
      case InstitutionCategory.familia:
        return const [
          Subcategory(
            id: 'pensao',
            label: 'Pensão alimentícia',
            icon: Icons.attach_money_rounded,
            requiredDocs: [
              'Documento de identidade (RG ou CNH)',
              'CPF',
              'Comprovante de residência',
              'Certidão de nascimento do(a) filho(a)',
              'Comprovante de renda (se tiver)',
            ],
            quickTip:
                'A pensão é direito do(a) filho(a). Você pode pedir mesmo sem advogado.',
          ),
          Subcategory(
            id: 'divorcio',
            label: 'Divórcio ou separação',
            icon: Icons.heart_broken_rounded,
            requiredDocs: [
              'Documento de identidade',
              'CPF',
              'Certidão de casamento',
              'Documentos dos filhos (se houver)',
              'Comprovante de residência',
            ],
            quickTip:
                'Em divórcio consensual sem filhos menores, dá pra fazer em cartório.',
          ),
          Subcategory(
            id: 'guarda',
            label: 'Guarda dos filhos',
            icon: Icons.child_care_rounded,
            requiredDocs: [
              'Documento de identidade',
              'CPF',
              'Certidão de nascimento dos filhos',
              'Comprovante de residência',
            ],
          ),
          Subcategory(
            id: 'paternidade',
            label: 'Reconhecimento de paternidade',
            icon: Icons.family_restroom_rounded,
            requiredDocs: [
              'Documento de identidade',
              'CPF',
              'Certidão de nascimento da criança',
            ],
          ),
          Subcategory(
            id: 'inventario',
            label: 'Inventário ou herança',
            icon: Icons.account_balance_rounded,
            requiredDocs: [
              'Documento de identidade',
              'CPF',
              'Certidão de óbito',
              'Documentos dos bens (escrituras, veículos)',
            ],
          ),
          Subcategory(id: 'outro_familia', label: 'Outra questão de família', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.trabalho:
        return const [
          Subcategory(
            id: 'demissao',
            label: 'Fui demitido (rescisão)',
            icon: Icons.exit_to_app_rounded,
            requiredDocs: [
              'Carteira de trabalho',
              'Documento de identidade e CPF',
              'Comprovante da rescisão (se tiver)',
              'Holerites dos últimos meses',
            ],
            quickTip:
                'Você tem direito a aviso prévio, férias, 13º proporcional, FGTS e multa de 40%.',
          ),
          Subcategory(
            id: 'salario',
            label: 'Salário não pago / atrasado',
            icon: Icons.money_off_rounded,
            requiredDocs: [
              'Carteira de trabalho',
              'Documento de identidade',
              'Holerites e comprovantes',
            ],
          ),
          Subcategory(
            id: 'acidente',
            label: 'Acidente de trabalho',
            icon: Icons.medical_services_rounded,
            requiredDocs: [
              'Carteira de trabalho',
              'Documento de identidade',
              'CAT - Comunicação de Acidente de Trabalho',
              'Atestados médicos',
            ],
          ),
          Subcategory(
            id: 'horas_extras',
            label: 'Horas extras não pagas',
            icon: Icons.schedule_rounded,
            requiredDocs: [
              'Carteira de trabalho',
              'Holerites',
              'Cartão de ponto (se tiver)',
            ],
          ),
          Subcategory(
            id: 'fgts',
            label: 'FGTS ou direitos trabalhistas',
            icon: Icons.account_balance_wallet_rounded,
          ),
          Subcategory(id: 'outro_trabalho', label: 'Outra questão trabalhista', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.aposentadoria:
        return const [
          Subcategory(
            id: 'aposentadoria_geral',
            label: 'Aposentadoria por idade ou tempo',
            icon: Icons.elderly_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'Carteira de trabalho',
              'Comprovantes de contribuição',
              'CNIS (extrato do INSS)',
            ],
          ),
          Subcategory(
            id: 'auxilio_doenca',
            label: 'Auxílio-doença',
            icon: Icons.healing_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'Carteira de trabalho',
              'Atestado e laudos médicos',
              'Exames recentes',
            ],
          ),
          Subcategory(
            id: 'bpc',
            label: 'BPC/LOAS (deficiência ou idoso pobre)',
            icon: Icons.accessibility_new_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'CadÚnico atualizado',
              'Laudos médicos (se deficiência)',
              'Comprovante de residência',
            ],
            quickTip:
                'Renda familiar per capita precisa ser de até 1/4 do salário mínimo.',
          ),
          Subcategory(
            id: 'pensao_morte',
            label: 'Pensão por morte',
            icon: Icons.history_edu_rounded,
            requiredDocs: [
              'Documento de identidade do dependente',
              'Certidão de óbito',
              'Documento que prove relação (certidão casamento, nascimento)',
            ],
          ),
          Subcategory(
            id: 'maternidade',
            label: 'Salário-maternidade',
            icon: Icons.pregnant_woman_rounded,
          ),
          Subcategory(id: 'outro_aposentadoria', label: 'Outro benefício', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.consumidor:
        return const [
          Subcategory(
            id: 'cobranca',
            label: 'Cobrança indevida',
            icon: Icons.credit_card_off_rounded,
            requiredDocs: [
              'Documento de identidade',
              'CPF',
              'Boleto ou fatura da cobrança',
              'Comprovante de pagamento (se já pagou)',
            ],
          ),
          Subcategory(
            id: 'defeito',
            label: 'Produto com defeito',
            icon: Icons.broken_image_rounded,
            requiredDocs: [
              'Nota fiscal',
              'Documento de identidade',
              'Comprovante de tentativa de troca/conserto',
            ],
            quickTip: 'Garantia legal mínima: 30 dias para não duráveis, 90 dias para duráveis.',
          ),
          Subcategory(
            id: 'plano_saude',
            label: 'Plano de saúde negou cobertura',
            icon: Icons.local_hospital_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'Carteirinha do plano',
              'Negativa por escrito (se possível)',
              'Pedido médico e exames',
            ],
          ),
          Subcategory(
            id: 'banco',
            label: 'Problema com banco ou financeira',
            icon: Icons.account_balance_rounded,
          ),
          Subcategory(
            id: 'telecom',
            label: 'Telefone, internet ou TV',
            icon: Icons.wifi_rounded,
          ),
          Subcategory(id: 'outro_consumidor', label: 'Outro problema de consumo', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.moradia:
        return const [
          Subcategory(
            id: 'inquilino',
            label: 'Sou inquilino (problemas com locação)',
            icon: Icons.key_rounded,
            requiredDocs: [
              'Contrato de aluguel',
              'Documento de identidade',
              'Comprovantes de pagamento de aluguel',
            ],
          ),
          Subcategory(
            id: 'despejo',
            label: 'Estou sendo despejado',
            icon: Icons.warning_rounded,
            requiredDocs: [
              'Documento de identidade',
              'Notificação ou citação recebida',
              'Contrato (se houver)',
            ],
            quickTip:
                'Você tem direito a se defender. Procure ajuda imediatamente!',
          ),
          Subcategory(
            id: 'regularizar',
            label: 'Regularizar meu imóvel',
            icon: Icons.assignment_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'Documentos do imóvel (qualquer um)',
              'Comprovantes de posse/pagamento',
            ],
          ),
          Subcategory(
            id: 'mcmv',
            label: 'Casa própria (Minha Casa Minha Vida)',
            icon: Icons.home_work_rounded,
          ),
          Subcategory(id: 'outro_moradia', label: 'Outra questão de moradia', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.documentos:
        return const [
          Subcategory(
            id: 'rg_cpf',
            label: 'RG ou CPF',
            icon: Icons.badge_rounded,
            requiredDocs: [
              'Certidão de nascimento ou casamento',
              'Comprovante de residência',
              'Foto (alguns casos)',
            ],
          ),
          Subcategory(
            id: 'certidao_nascimento',
            label: 'Certidão de nascimento ou casamento',
            icon: Icons.description_rounded,
          ),
          Subcategory(
            id: 'certidao_obito',
            label: 'Certidão de óbito',
            icon: Icons.history_edu_rounded,
          ),
          Subcategory(
            id: 'titulo_eleitor',
            label: 'Título de eleitor',
            icon: Icons.how_to_vote_rounded,
          ),
          Subcategory(
            id: 'passaporte',
            label: 'Passaporte',
            icon: Icons.flight_takeoff_rounded,
          ),
          Subcategory(id: 'outro_doc', label: 'Outro documento', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.direitosMulher:
        return const [
          Subcategory(
            id: 'discriminacao_trabalho',
            label: 'Discriminação no trabalho',
            icon: Icons.work_off_rounded,
          ),
          Subcategory(
            id: 'gravidez',
            label: 'Direitos na gravidez',
            icon: Icons.pregnant_woman_rounded,
            quickTip: 'Gestante tem estabilidade no emprego do início da gestação até 5 meses após o parto.',
          ),
          Subcategory(
            id: 'maternidade_d',
            label: 'Licença-maternidade',
            icon: Icons.child_care_rounded,
          ),
          Subcategory(
            id: 'violencia',
            label: 'Sofri violência',
            icon: Icons.shield_rounded,
            quickTip: 'Você pode pedir medida protetiva sem precisar de advogado.',
          ),
          Subcategory(id: 'outro_mulher', label: 'Outra questão', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.saude:
        return const [
          Subcategory(
            id: 'medicamento',
            label: 'Medicamento de alto custo',
            icon: Icons.medication_rounded,
            requiredDocs: [
              'Documento de identidade e CPF',
              'Cartão SUS',
              'Receita médica',
              'Laudo médico justificando',
              'Negativa do posto de saúde',
            ],
          ),
          Subcategory(
            id: 'internacao',
            label: 'Internação ou leito',
            icon: Icons.bed_rounded,
            requiredDocs: [
              'Documento de identidade',
              'Cartão SUS',
              'Pedido médico',
              'Comprovante de busca por leito',
            ],
          ),
          Subcategory(
            id: 'cirurgia',
            label: 'Cirurgia',
            icon: Icons.medical_services_rounded,
            requiredDocs: [
              'Documento de identidade',
              'Cartão SUS',
              'Pedido médico e laudos',
              'Comprovante de espera',
            ],
          ),
          Subcategory(
            id: 'tratamento',
            label: 'Tratamento negado pelo SUS',
            icon: Icons.local_hospital_rounded,
          ),
          Subcategory(
            id: 'consulta',
            label: 'Consulta com especialista',
            icon: Icons.health_and_safety_rounded,
          ),
          Subcategory(id: 'outro_saude', label: 'Outra questão de saúde', icon: Icons.help_rounded),
        ];

      case InstitutionCategory.denuncias:
        return const [
          Subcategory(
            id: 'servico_publico',
            label: 'Serviço público ruim',
            icon: Icons.public_rounded,
            quickTip: 'Ouvidorias funcionam mesmo sem identificação completa.',
          ),
          Subcategory(
            id: 'corrupcao',
            label: 'Corrupção',
            icon: Icons.gavel_rounded,
          ),
          Subcategory(
            id: 'ambiental',
            label: 'Crime ambiental',
            icon: Icons.forest_rounded,
          ),
          Subcategory(
            id: 'oab',
            label: 'Advogado (denúncia à OAB)',
            icon: Icons.balance_rounded,
          ),
          Subcategory(
            id: 'maus_tratos',
            label: 'Maus tratos ou abuso',
            icon: Icons.report_rounded,
          ),
          Subcategory(
            id: 'anonima',
            label: 'Quero fazer denúncia anônima',
            icon: Icons.visibility_off_rounded,
          ),
        ];

      case InstitutionCategory.violenciaDomestica:
        // Violência tem tela de segurança, não sub-categorias
        return const [];

      case InstitutionCategory.outros:
        return const [];
    }
  }
}
