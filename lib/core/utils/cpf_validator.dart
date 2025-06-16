class CpfValidator {
  static bool validarCPF(String cpf) {
    // Remove caracteres não numéricos
    cpf = cpf.replaceAll(RegExp(r'\D'), '');

    // Verifica se o CPF tem 11 dígitos
    if (cpf.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1*$').hasMatch(cpf)) return false;

    // Calcula e verifica os dígitos verificadores
    var sum1 = 0, sum2 = 0;
    for (var i = 0; i < 9; i++) {
      sum1 += int.parse(cpf[i]) * (10 - i);
      sum2 += int.parse(cpf[i]) * (11 - i);
    }
    sum2 += int.parse(cpf[9]) * 2;

    final digit1 = (sum1 * 10 % 11) % 10;
    final digit2 = (sum2 * 10 % 11) % 10;

    return digit1 == int.parse(cpf[9]) && digit2 == int.parse(cpf[10]);
  }
}