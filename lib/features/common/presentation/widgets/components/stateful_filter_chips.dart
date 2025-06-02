import 'package:flutter/material.dart';

class StatefulFilterChips extends StatefulWidget {
  const StatefulFilterChips({
    super.key,
    required this.filtersLabel,
    required this.initialFilter,
    required this.onSelected,
  });

  final List<String> filtersLabel;
  final String initialFilter;
  final ValueChanged<String> onSelected;

  @override
  State<StatefulFilterChips> createState() => _StatefulFilterChipsState();
}

class _StatefulFilterChipsState extends State<StatefulFilterChips> {
  late String activeFilter;

  void changeInternally(String filterSelected) {
    if (filterSelected == 'Todos') {
      activeFilter = 'Todos';
    } else if (filterSelected == activeFilter) {
      activeFilter = 'Todos';
    } else {
      activeFilter = filterSelected;
    }
    setState(() {});
  }

  @override
  void initState() {
    activeFilter = widget.initialFilter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: widget.filtersLabel.length,
      scrollDirection: Axis.horizontal,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final label = widget.filtersLabel[index];

        return FilterChip(
          label: Text(
            label,
            style: TextStyle(
              color: activeFilter == label ? Colors.white : null,
            ),
          ),
          onSelected: (_) {
            if (activeFilter == label) {
              widget.onSelected(widget.initialFilter);
            } else {
              widget.onSelected(label);
            }
            changeInternally(label);
          },
          selected: activeFilter == label,
        );
      },
    );
  }
}
