import '../../../../core/api_provider.dart';
import '../../../contracts/domain/entities/contract_type.dart';
import '../../../contracts/domain/entities/sexual_practice.dart';

class AppDataSource {
  final _apiProvider = ApiProvider();

  // Future<List<SexualPractice>> getSexualPractices() async {
  //   final rawData = _MockData().practices;
  //   final practices = rawData.map((e)=> SexualPractice.fromJson(e)).toList();
  //
  //   return practices;
  // }

  Future<List<ContractType>> getContractTypes() async {
    final rawData = await _apiProvider.get('contrato-tipos/listar');
    final List<ContractType> types = [];

    for(final ele in rawData['data']){
      types.add(ContractType.fromJson(ele));
    }

    return types;
  }
}

class _MockData {

  final List<Map<String, dynamic>> practices = [
    { 'id': 1, 'descricao': 'Sexo vaginal sem camisinha' },
    { 'id': 2, 'descricao': 'Sexo vaginal com camisinha' },
    { 'id': 3, 'descricao': 'Sexo anal sem camisinha' },
    { 'id': 4, 'descricao': 'Sexo anal com camisinha' },
    { 'id': 5, 'descricao': 'Sexo oral (contratante faz)' },
    { 'id': 6, 'descricao': 'Sexo oral (parte interessada recebe)' },
    { 'id': 7, 'descricao': 'Masturbação mútua' },
    { 'id': 8, 'descricao': 'Compartilhamento de brinquedos sexuais' },
    { 'id': 9, 'descricao': 'Sexo em grupo' },
    { 'id': 10, 'descricao': 'Sexo casual' },
    { 'id': 11, 'descricao': 'Sexo com parceiro fixo' },
    { 'id': 12, 'descricao': 'Práticas BDSM' },
    { 'id': 13, 'descricao': 'Sexo sob efeito de álcool ou drogas' },
    { 'id': 14, 'descricao': 'Fetiches e suas consequências' }
  ];

  // final Map<String, dynamic> updateStatus ={
  //   'id': 1,
  //   /// Status pode ser 1, 2 ou 3.
  //   /// 1 == pendente
  //   /// 2 == aceito
  //   /// 3 == recusado
  //   'status': 2,
  // };
  //
  // final Map<String, dynamic> registerContract ={
  //   'contrato_tipo_id': tipoId,
  //   'status': 'Pendente',
  //   'participantes': [usuariosId],
  //   'clausulas': [clausulasId],
  //   /// Por padrão todas as práticas ficam com o status de pendente, exceto para a própria pessoa que criou o contrato. Para ela, começa como aceito
  //   'praticas': [praticasId]
  // }
}