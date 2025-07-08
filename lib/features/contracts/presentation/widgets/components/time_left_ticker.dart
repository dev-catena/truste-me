import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../core/enums/contract_status.dart';
import '../../../../../core/utils/custom_colors.dart';
import '../../../domain/entities/contract.dart';

// TODO: Refatorar esse widget para suportar tipo dinâmico OU (melhor) controlar apenas o tempo restante, sem importar qual tipo de dado é passado
class TimeLeftTicker extends StatefulWidget {
  const TimeLeftTicker({
    super.key,
    required this.contract,
    required this.textStyle,
    required this.onExpire,
  });

  final Contract contract;
  final TextStyle textStyle;
  final void Function(Contract contract) onExpire;

  @override
  State<TimeLeftTicker> createState() => _TimeLeftTickerState();
}

class _TimeLeftTickerState extends State<TimeLeftTicker> {
  late Timer _timer;
  late Duration _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateTime());
  }

  void _updateTime() {
    _timeLeft = widget.contract.endDt.difference(DateTime.now());

    if (_timeLeft.isNegative) {
      widget.onExpire(widget.contract);
      _timer.cancel();
      return;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_timeLeft.isNegative) return const SizedBox.shrink();

    String display;
    if (widget.contract.status == ContractStatus.active) {
      display = _timeLeft.inHours <= 1 ? '${_timeLeft.inMinutes}m' : '${_timeLeft.inHours}h';
    } else if (widget.contract.status == ContractStatus.pending) {
      display = '${_timeLeft.inMinutes}m';
    } else {
      display = '';
    }

    Color? color;
    if (widget.contract.status == ContractStatus.active) {
      color = _timeLeft.inHours <= widget.contract.duration / 2 ? CustomColor.vividRed : CustomColor.activeColor;
    } else if (widget.contract.status == ContractStatus.pending) {
      color = _timeLeft.inMinutes < 30 ? CustomColor.vividRed : CustomColor.activeColor;
    }

    return Text(display, style: widget.textStyle.copyWith(color: color));
  }
}
