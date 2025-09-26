part of '../../domain/entities/user_info_data.dart';

class _PersonalInfoForm extends StatefulWidget {
  final UserInfoData? currentData;
  final void Function(UserInfoData userData, bool emailAlreadyExists, bool cpfAlreadyExists) onPersonalDataSet;

  const _PersonalInfoForm({required this.currentData, required this.onPersonalDataSet});

  @override
  State<_PersonalInfoForm> createState() => _PersonalInfoFormState();
}

class _PersonalInfoFormState extends State<_PersonalInfoForm> {
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _emailController = TextEditingController();

  late UserInfoData personalData;

  DateTime? datePicked;

  bool _validatingEmail = false;
  bool _validatingCpf = false;
  bool _emailExists = false;
  bool _cpfExists = false;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _cpfFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  bool wasNameTouched = false;
  bool wasCPFTouched = false;
  bool wasEmailTouched = false;
  bool wasBirthdayTouched = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    if (widget.currentData == null) {
      personalData = UserInfoData.empty();
    } else {
      personalData = widget.currentData!;
      _nameController.text = personalData.name;
      _cpfController.text = personalData.cpf;
      _emailController.text = personalData.email;
    }

    if (personalData.birthDate.isLegalAge()) {
      datePicked = personalData.birthDate;
      wasBirthdayTouched = true;
    } else {
      datePicked = null;
    }

    _nameController.addListener(_onChanged);
    _cpfController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _cpfFocus.dispose();
    _emailFocus.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  bool get isEmailValid {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(_emailController.text.trim());
  }

  bool get isCpfValid => CPFValidator.isValid(_cpfController.text);

  void _onChanged() {
    _validateAndNotify();
  }

  void _onEmailChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (isEmailValid) {
    // if (personalData.isEmailValid) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        checkIfEmailExists(_emailController.text.trim());
      });
    }
    _validateAndNotify();
  }

  void _onCpfChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (isCpfValid) {
    // if (personalData.isCpfValid) {
      _debounce = Timer(const Duration(milliseconds: 500), () {
        checkIfCpfExists(_cpfController.text.trim());
      });
    }
    _validateAndNotify();
  }

  void checkIfEmailExists(String email) async {
    setState(() {
      _validatingEmail = true;
      _emailExists = false;
    });
    final resp = await ApiProvider(personalData.id > 0).post('cadastro/verificar-dados', jsonEncode({'email': email}));
    setState(() {
      _validatingEmail = false;
      _emailExists = resp['email_exists'] == true;
    });
    if (_emailExists) {
      if (mounted) context.showSnack('Já existe um login com este email!');
    }
    _validateAndNotify();
  }

  void checkIfCpfExists(String cpf) async {
    setState(() {
      _validatingCpf = true;
      _cpfExists = false;
    });
    final resp = await ApiProvider(personalData.id > 0).post('cadastro/verificar-dados', jsonEncode({'CPF': cpf}));
    setState(() {
      _validatingCpf = false;
      _cpfExists = resp['cpf_exists'] == true;
    });
    if (_cpfExists) {
      if (mounted) context.showSnack('Já existe um cadastro com este CPF!');
    }
    _validateAndNotify();
  }

  void _validateAndNotify() {
    personalData = personalData.copyWith(
      name: _nameController.text.trim(),
      cpf: _cpfController.text.trim(),
      email: _emailController.text.trim(),
      birthDate: datePicked,
    );

    widget.onPersonalDataSet(personalData, _emailExists, _cpfExists);
  }

  InputDecoration getDecoration({String? label, bool isValid = false}) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black26 : Colors.red,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? Colors.black26 : Colors.red,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isValid ? CustomColor.activeColor : Colors.red,
          width: 2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    return FocusScope(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
              child: Text('Dados Básicos', style: titleLarge, textAlign: personalData.id > 0 ? TextAlign.left : TextAlign.center,),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            onTapOutside: (_) => _nameFocus.unfocus(),
            onChanged: (value){
              if(!wasNameTouched) {
                setState(() => wasNameTouched = true);
              }
            },
            onSubmitted: (_) => FocusScope.of(context).requestFocus(_cpfFocus),
            decoration: getDecoration(label: 'Nome completo', isValid: !wasNameTouched || (_nameController.text.trim().isNotEmpty && _nameController.text.trim().contains(' '))),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: personalData.id <= 0,
                  controller: _cpfController,
                  focusNode: _cpfFocus,
                  onTapOutside: (_) => _cpfFocus.unfocus(),
                  onSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
                  maxLength: 14,
                  onChanged: (value){
                    if(!wasCPFTouched) {
                      setState(() => wasCPFTouched = true);
                    }

                    _onCpfChanged(value);
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CpfInputFormatter(),
                  ],
                  decoration: getDecoration(label: 'CPF', isValid: !wasCPFTouched || (isCpfValid && !_cpfExists)),
                ),
              ),
              if (_validatingCpf)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  //enabled: personalData.id <= 0,
                  controller: _emailController,
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  onTapOutside: (_) => _emailFocus.unfocus(),
                  onSubmitted: (_) => _emailFocus.unfocus(),
                  onChanged: (value){
                    if(!wasEmailTouched) {
                      setState(() => wasEmailTouched = true);
                    }

                    _onEmailChanged(value);
                  },
                  decoration: getDecoration(label: 'Email', isValid: !wasEmailTouched || (personalData.isEmailValid && !_emailExists)),
                ),
              ),
              if (_validatingEmail)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          CustomSelectableTile(
            title: datePicked != null
                ? '${datePicked!.day.toString().padLeft(2, '0')}/${datePicked!.month.toString().padLeft(2, '0')}/${datePicked!.year}'
                : 'Data de nascimento',
            width: double.infinity,
            borderColor: (!wasBirthdayTouched || datePicked != null) ? CustomColor.activeColor : CustomColor.vividRed,
            leadingWidget: const Icon(Icons.calendar_month_outlined),
            onTap: () {
              if(!wasBirthdayTouched) {
                setState(() {
                  wasBirthdayTouched = true;
                });
              }
              showDatePicker(
                errorFormatText: "Formato incorreto. Formato: dd/mm/aaaa",
                initialEntryMode: DatePickerEntryMode.calendar,
                keyboardType: TextInputType.datetime,
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
              ).then((value) {
                if (value != null) {
                  setState(() {
                    datePicked = value;
                  });
                  _validateAndNotify();
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
