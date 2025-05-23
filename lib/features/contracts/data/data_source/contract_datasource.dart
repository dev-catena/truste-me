import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../core/api_provider.dart';
import '../../../common/domain/entities/person.dart';
import '../../domain/entities/clause.dart';
import '../../domain/entities/contract.dart';

class ContractDataSource {
  final _apiProvider = ApiProvider();

  Future<Contract> getContractFullInfo(Contract cont) async {
    final rawData = await _apiProvider.get('contrato/buscar-completo/${cont.id}');

    final contract = ContractModel.fromJson(rawData).toEntity();

    return contract;
  }

  Future<List<Contract>> getContractsForUser(final Person user) async {
    final rawData = await _apiProvider.get('usuario/${user.id}/contratos');
    final List<Contract> convertedData = [];

    for (final ele in rawData['contratos_como_contratante']) {
      convertedData.add(ContractModel.fromJson(ele).toEntity());
    }

    for (final ele in rawData['contratos_como_participante']) {
      convertedData.add(ContractModel.fromJson(ele).toEntity());
    }

    debugPrint('$runtimeType - convertedData length ${convertedData.length}');
    return convertedData;
  }

  Future<List<Clause>> getClausesForContractType(ContractType type) async {
    final rawData = await _apiProvider.get('contrato-tipos/${type.code}/clausulas');

    final List<Clause> convertedData = [];
    for (final ele in rawData['clausulas']) {
      convertedData.add(ClauseModel.fromJson(ele).toEntity());
    }
    return convertedData;
  }

  Future<Contract> createContract(ContractType type, List<Person> participants, List<Clause> clauses) async {
    final personsId = participants.map((p) => p.id).toList();
    final clausesId = clauses.map((c) => c.id).toList();

    final content = {
      'contrato_tipo_id': type.code,
      'status': 'Pendente',
      'participantes': personsId,
      'clausulas': clausesId,
    };

    final response = await _apiProvider.post('contrato/gravar', jsonEncode(content));

    final newContract = ContractModel.fromJson(response).toEntity();

    return newContract;
  }
}

class _MockData {
  final List<Map<String, dynamic>> contracts = [
    {
      'id': 1,
      'numeroContrato': '00003/2025',
      'status': 'Pendente',
      'tipo': 'Sexual',
      'parteInteressada': {
        'id': 1,
        'nome': 'Maria das Graças',
        'cpf': '123.456.789-00',
        'idade': 24,
        'pais': 'Brasil',
        'estado': 'São Paulo',
        'profissao': 'Analista de Marketing',
        'created_at': '2023-12-22',
        'codigo': 'maria#213545',
      },
    },
    {
      'id': 2,
      'numeroContrato': '00002/2025',
      'status': 'Ativo',
      'tipo': 'Compra e venda',
      'parteInteressada': {
        'id': 4,
        'nome': 'José Guimarães Barbosa',
        'cpf': '987.654.321-00',
        'idade': 29,
        'pais': 'Brasil',
        'estado': 'São Paulo',
        'profissao': 'Gerente de Almoxarifado',
        'created_at': '2024-02-10',
        'codigo': 'jose#991023',
      },
      'inicio_vigencia': '2024-11-02',
      'fim_vigencia': '2025-05-02',
    },
  ];

  final List<Map<String, dynamic>> clauses = [
    {
      'id': 2,
      'nome': 'NÃO EXCLUSIVIDADE',
      'descricao':
          'As PARTES se comprometem a manter a relação NÃO exclusiva, PODENDO manteR relacionamentos íntimos com outras pessoas durante a vigência do contrato.A REGISTRADA ANUÊNCIA E CONCORDÂNCIA, descaracteriza todas as possibilidades futuras de desdobramentos jurídicos de outros viéses jurídicos e jurisprudências no tocante a fidelidade, que através desse contrato NÃO é interesse das partes.',
    },
    {
      'id': 3,
      'nome': 'COMUNICAÇÃO',
      'descricao':
          'As PARTES se comprometem a manter uma comunicação aberta e honesta, discutindo todas as questões e desentendimentos que possam surgir durante a relação, estando fundamentadas e alicerçadas exclusivamente nesse contrato que antecede ao fato, ato e conjunção carnal entre as partes. Todas as permissões concedidas previamente no contrato geram materialidade sobre as permissões previamente concedidas e acordadas.',
    },
    {
      'id': 4,
      'nome': 'RESPEITO',
      'descricao':
          'As PARTES se comprometem a respeitar a privacidade e a individualidade de cada uma, não interferindo na vida pessoal e profissional da outra parte, não divulgando sobre o contrato sigiloso dessa plataforma, não permitindo prints ou fotos da dinâmica do aplicativo e de dados das partes dentro da norma LGPD, incorrendo em vulnerabilidade jurídica caso quebre essa cláusula.',
    },
    {
      'id': 5,
      'nome': 'RESPONSABILIDADE',
      'descricao':
          'As PARTES se comprometem a assumir responsabilidade pelas próprias ações, não transferindo responsabilidades ou culpas para a outra parte. O uso de substâncias exógenas, de abuso, alopáticos é de responsabilidade do usuário não atenuando a responsabilidade civil e criminal sob seus atos. O app e sua estrutura, assim como a parte contrária não se responsabiliza pelo quadro clínico químico, de transtornos ou patologias de nenhuma das partes. Caso essa condição seja vulnerabilidade tipificada, não utilize a plataforma nem faça esse contrato. Decline da possibilidade de se relacionar até que restabeleça suas condições mínimo operacionais para o ato.'
    },
    {
      'id': 6,
      'nome': 'DURAÇÃO',
      'descricao':
          'O presente contrato terá vigência entre o período já estabelecido, podendo ser renovado por acordo mútuo das PARTES.',
    },
    {
      'id': 7,
      'nome': 'RESCISÃO',
      'descricao':
          'O presente contrato não é rescindido enquanto materialidade por qualquer das PARTES em nenhuma hipótese, o que não impede qualquer das partes de desistir do ato enquanto liberdade individual, mediante aviso dessa intercorrência no próprio app que fará o registro de interrupção do ato e em que altura e motivo o mesmo aconteceu, para que complete a materialidade total do ato contratual.',
    },
    {
      'id': 8,
      'nome': 'PATRIMÔNIO',
      'descricao':
          'As PARTES declaram que não haverá comunicação de patrimônio entre elas, cada uma mantendo a propriedade exclusiva de seus bens. No contrato é exigida a divisão das despesas em 50%, sejam contas de bares, restaurantes, motéis, e todo consumo casual, em conformidade com a atual equidade evolutivas da sociedade. Se por fora do contrato, as partes divergirem dessa conduta e fizerem acerto financeiro entre si, o app não se responsabiliza por esses atos e nem entrega materialidade contrária a essa cláusula.',
    },
  ];
}
