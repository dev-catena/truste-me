import 'package:flutter/material.dart';

import 'package:trustme/core/utils/custom_colors.dart';
import 'package:trustme/features/common/presentation/widgets/components/custom_selectable_tile.dart';
import 'package:trustme/features/common/presentation/widgets/dialogs/single_select_dialog.dart';

enum IncomeRange {
  classA('Classe A', 'Maior que R\$30 mil'),
  classB('Classe B', 'Entre R\$12.1 mil e R\$30 mil'),
  classC('Classe C', 'Entre R\$3.6 mil e R\$12.1 mil'),
  classDE('Classe D/E', 'Até R\$3.600');

  final String description;
  final String range;

  const IncomeRange(this.description, this.range);
}

class ComplementaryInfoForm extends StatefulWidget {
  final bool isEdition;
  final String? userProfession;
  final IncomeRange? userIncome;
  final ValueChanged<String> onProfessionSet;
  final ValueChanged<IncomeRange> onIncomeSet;

  const ComplementaryInfoForm({super.key,
    this.isEdition = false,
    this.userProfession, this.userIncome,
    required this.onProfessionSet,
    required this.onIncomeSet,
  });

  @override
  State<ComplementaryInfoForm> createState() => _ComplementaryInfoFormState();
}

class _ComplementaryInfoFormState extends State<ComplementaryInfoForm> {
  final professionController = TextEditingController();
  IncomeRange? incomeSelected;

  final _professionFocusNode = FocusNode();
  bool wasTouched = false;

  @override
  void initState() {
    _loadData();
    super.initState();

    _professionFocusNode.addListener(() {
      if (!_professionFocusNode.hasFocus) {
        setState(() => wasTouched = true);
      }
    });
  }

  void _loadData() {
    professionController.text = widget.userProfession ?? '';
    incomeSelected = widget.userIncome;
  }

  @override
  void dispose() {
    professionController.dispose();
    _professionFocusNode.dispose();
    super.dispose();
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

    // padding: const EdgeInsets.all(20),
    //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: double.infinity,
            child: Text('Dados complementares', style: titleLarge, textAlign: widget.isEdition ? TextAlign.left : TextAlign.center,),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: professionController,
          focusNode: _professionFocusNode,
          onTapOutside: (_) {
            _professionFocusNode.unfocus();
            //FocusScope.of(context).unfocus();
          },
          onChanged: (value){
            if(!wasTouched) {
              setState(() => wasTouched = true);
            }

            widget.onProfessionSet(value);
          },
          textCapitalization: TextCapitalization.words,
          decoration: getDecoration(
            label: 'Profissão',
            isValid: !wasTouched || professionController.text.isNotEmpty,
          ),
        ),
        const SizedBox(height: 16),
        CustomSelectableTile(
          title: incomeSelected?.description ?? 'Renda',
          isActive: incomeSelected != null,
          width: double.infinity,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SingleSelectDialog<IncomeRange>(
                  title: 'Faixa de renda',
                  options: IncomeRange.values,
                  showSearchBar: false,
                  getName: (option) => '${option.description} - ${option.range}',
                  onChoose: (value) {
                    incomeSelected = value;
                    widget.onIncomeSet(value);
                    setState(() {});
                  },
                  optionSelected: incomeSelected,
                );
              },
            );
          },
        )
      ],
    );
  }
}
