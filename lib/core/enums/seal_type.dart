enum SealType {
  identity(1, 'Identidade'),
  email(10, 'Email'),
  income(3, 'Renda'),
  antecedents(4, 'Antecedentes'),
  maritalStatus(5, 'Estado cívil'),
  address(6, 'Endereço'),
  education(7, 'Escolaridade'),
  occupation(8, 'Ocupação');

  final int id;
  final String description;

  factory SealType.fromString(String value) {
    return SealType.values.firstWhere((element) => element.description == value);
  }

  const SealType(this.id, this.description);
}
