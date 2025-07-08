part of '../register_screen.dart';

class _UserInfo extends StatefulWidget {
  final String? currentName;
  final String? currentCpf;
  final String? currentEmail;
  final DateTime? currentBirthDate;
  final ValueChanged<String> onNameSet;
  final ValueChanged<String> onCpfSet;
  final ValueChanged<String> onEmailSet;
  final ValueChanged<DateTime?> onBirthDateChanged;

  const _UserInfo({
    required this.currentName,
    required this.currentCpf,
    required this.currentEmail,
    required this.currentBirthDate,
    required this.onNameSet,
    required this.onCpfSet,
    required this.onBirthDateChanged,
    required this.onEmailSet,
  });

  @override
  State<_UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<_UserInfo> {
  late final _nameController = TextEditingController(text: widget.currentName);
  late final _cpfController = TextEditingController(text: widget.currentCpf);
  late final _emailController = TextEditingController(text: widget.currentEmail);
  bool _isNameEmpty = true;
  bool _isCpfEmpty = true;
  bool _isEmailEmpty = true;
  DateTime? datePicked;
  late final FocusNode _nameFocus;
  late final FocusNode _cpfFocus;
  late final FocusNode _emailFocus;
  late final VoidCallback _nameListener;
  late final VoidCallback _cpfListener;
  late final VoidCallback _emailListener;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email.trim());
  }

  bool get isCpfValid => CPFValidator.isValid(_cpfController.text);

  @override
  void initState() {
    super.initState();

    _nameListener = () {
      if (mounted) {
        setState(() {
          _isNameEmpty = _nameController.text.trim().isEmpty;
        });
      }
    };

    _cpfListener = () {
      if (mounted) {
        setState(() {
          _isCpfEmpty = _cpfController.text.trim().isEmpty;
        });
      }
    };

    _emailListener = () {
      if (mounted) {
        final email = _emailController.text.trim();
        final isValid = isValidEmail(email);

        setState(() {
          _isEmailEmpty = email.isEmpty || !isValid;
        });
      }
    };

    _nameController.addListener(_nameListener);
    _cpfController.addListener(_cpfListener);
    _emailController.addListener(_emailListener);

    _nameFocus = FocusNode();
    _cpfFocus = FocusNode();
    _emailFocus = FocusNode();
  }

  @override
  void dispose() {
    _nameController.removeListener(_nameListener);
    _cpfController.removeListener(_cpfListener);
    _emailController.removeListener(_emailListener);

    _nameController.dispose();
    _cpfController.dispose();
    _emailController.dispose();

    _nameFocus.dispose();
    _cpfFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleLarge = Theme.of(context).textTheme.titleLarge!;

    InputDecoration getDecoration(String label, bool isEmpty) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEmpty ? Colors.red : Colors.black87,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEmpty ? Colors.red : Colors.black87,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isEmpty ? Colors.red : CustomColor.activeColor,
            width: 2,
          ),
        ),
      );
    }

    return FocusScope(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dados Básicos', style: titleLarge),
          const SizedBox(height: 16),
          TextField(
            onChanged: widget.onNameSet,
            controller: _nameController,
            onTapOutside: (_) => _nameFocus.unfocus(),
            focusNode: _nameFocus,
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_cpfFocus);
            },
            decoration: getDecoration('Nome completo', _isNameEmpty),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: widget.onCpfSet,
            focusNode: _cpfFocus,
            onTapOutside: (_) => _cpfFocus.unfocus(),
            onSubmitted: (_) {
              FocusScope.of(context).requestFocus(_emailFocus);
            },
            controller: _cpfController,
            maxLength: 14,
            decoration: getDecoration('CPF', !isCpfValid),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              CpfInputFormatter(),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _emailController,
            focusNode: _emailFocus,
            onTapOutside: (_) => _emailFocus.unfocus(),
            keyboardType: TextInputType.emailAddress,
            onSubmitted: (_) => _emailFocus.unfocus(),
            onChanged: widget.onEmailSet,
            decoration: getDecoration('Email', !isValidEmail(_emailController.text)),
          ),
          const SizedBox(height: 8),
          CustomSelectableTile(
            title: datePicked != null
                ? '${datePicked!.day.toString().padLeft(2, '0')}/${datePicked!.month.toString().padLeft(2, '0')}/${datePicked!.year}'
                : 'Data de nascimento',
            width: double.infinity,
            isActive: false,
            borderColor: datePicked == null ? CustomColor.vividRed : CustomColor.activeColor,
            leadingWidget: const Icon(Icons.calendar_month_outlined),
            onTap: () {
              showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime.now().subtract(const Duration(days: 6570)),
                // onDatePickerModeChange: (_){},
                // initialEntryMode: DatePickerEntryMode.calendarOnly,
                keyboardType: TextInputType.text,
                // locale: const Locale('pt')
              ).then((value) {
                datePicked = value;
                widget.onBirthDateChanged(value);
                setState(() {});
              });
            },
          ),
        ],
      ),
    );
  }
}
