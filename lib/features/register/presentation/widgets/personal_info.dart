part of '../register_screen.dart';

class _PersonalInfo extends StatefulWidget {
  final String? currentName;
  final String? currentCpf;
  final String? currentEmail;
  final DateTime? currentBirthDate;
  final ValueChanged<String> onNameSet;
  final ValueChanged<String> onCpfSet;
  final ValueChanged<String> onEmailSet;
  final ValueChanged<DateTime?> onBirthDateChanged;

  const _PersonalInfo({
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
  State<_PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<_PersonalInfo> {
  late final _nameController = TextEditingController(text: widget.currentEmail);
  late final _cpfController = TextEditingController(text: widget.currentCpf);
  late final _emailController = TextEditingController(text: widget.currentEmail);
  bool _isNameEmpty = true;
  bool _isCpfEmpty = true;
  bool _isEmailEmpty = true;
  DateTime? datePicked;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isNameEmpty = _nameController.text.trim().isEmpty;
      });
    });

    _cpfController.addListener(() {
      setState(() {
        _isCpfEmpty = _cpfController.text.trim().isEmpty;
      });
    });

    _emailController.addListener(() {
      setState(() {
        _isEmailEmpty = _emailController.text.trim().isEmpty;
      });
    });
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

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Dados Básicos', style: titleLarge),
        const SizedBox(height: 16),
        TextField(
          onChanged: widget.onNameSet,
          controller: _nameController,
          decoration: getDecoration('Nome completo', _isNameEmpty),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: widget.onCpfSet,
          controller: _cpfController,
          maxLength: 14,
          decoration: getDecoration('CPF', _isCpfEmpty),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CpfInputFormatter(),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          onChanged: widget.onEmailSet,
          decoration: getDecoration('Email', _isEmailEmpty),
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
            ).then((value) {
              datePicked = value;
              widget.onBirthDateChanged(value);
              setState(() {});
            });
          },
        ),
      ],
    );
  }
}
