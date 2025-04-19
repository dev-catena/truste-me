import 'package:flutter/material.dart';

import 'custom_selectable_tile.dart';

class StartEndDatepicker extends StatefulWidget {
  const StartEndDatepicker({
    super.key,
    required this.onDatePicked,
  });

  final void Function(DateTime initialDate, DateTime endDate) onDatePicked;

  @override
  State<StartEndDatepicker> createState() => _StartEndDatepickerState();
}

class _StartEndDatepickerState extends State<StartEndDatepicker> {
  DateTime? initialDate;
  DateTime? endDate;

  String? formatDate(DateTime? date) {
    if (date == null) return null;
    String formatedDate = '${date.day.toString().padLeft(2, '0')}/';
    formatedDate += '${date.month.toString().padLeft(2, '0')}/';
    formatedDate += '${date.year}';

    return formatedDate;
  }

  void runCallBack() {
    if (initialDate != null && endDate != null) {
      widget.onDatePicked(initialDate!, endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        CustomSelectableTile(
          title: formatDate(initialDate) ?? 'Data Inicial',
          onTap: () {
            showDatePicker(
              context: context,
              firstDate: initialDate ?? DateTime.now().subtract(const Duration(days: 90)),
              lastDate: endDate ?? DateTime.now().add(const Duration(days: 90)),
            ).then((value) {
              initialDate = value;
              setState(() {});
              runCallBack();
            });
          },
          width: 140,
          flexIndex: 1,
          flexFactor: 0,
          isActive: initialDate != null,
          leadingWidget: Icon(Icons.calendar_month_outlined, color: initialDate != null ? Colors.black : null),
        ),
        CustomSelectableTile(
          title: formatDate(endDate) ?? 'Data final',
          onTap: () {
            if (initialDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma data de início')));
              return;
            }
            showDatePicker(
              context: context,
              firstDate: initialDate ?? DateTime.now().subtract(const Duration(days: 90)),
              lastDate: endDate ?? DateTime.now().add(const Duration(days: 90)),
            ).then((value) {
              endDate = value;
              setState(() {});
              runCallBack();
            });
          },
          isActive: endDate != null,
          width: 140,
          flexIndex: 1,
          flexFactor: 0,
          leadingWidget: Icon(Icons.calendar_month_outlined, color: endDate != null ? Colors.black : null),
        ),
      ],
    );
  }
}
