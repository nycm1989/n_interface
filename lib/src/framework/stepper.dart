import 'package:flutter/material.dart';
import 'package:n_interface/n_interface.dart' show ContextExtension, NText;

/// Navegación tipo línea de tiempo (stepper) horizontal. GENÉRICA: recibe las
/// etiquetas de los pasos, el índice activo y un callback al tocar un paso — no
/// sabe de ningún dominio, así se reutiliza en cualquier flujo.
///
/// Cada paso se pinta según su estado: completado (índice < actual) y activo
/// (== actual) en color primario; pendiente (> actual) atenuado. Las líneas
/// conectoras entre pasos se colorean si el tramo ya fue alcanzado.
class NStepper extends StatelessWidget {
  const NStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.onStepTap,
  });

  final List<String>     steps;
  final int              currentIndex;
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      children: List<Widget>.generate(steps.length, (index) {
        return Expanded(
          child:
          _StepItem(
            label      : steps[index],
            active     : index == currentIndex,
            done       : index < currentIndex,
            isFirst    : index == 0,
            isLast     : index == steps.length - 1,
            leftLineOn : index <= currentIndex,
            rightLineOn: index < currentIndex,
            onTap      : onStepTap == null ? null : () => onStepTap!(index),
          ),
        );
      }),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.label,
    required this.active,
    required this.done,
    required this.isFirst,
    required this.isLast,
    required this.leftLineOn,
    required this.rightLineOn,
    this.onTap,
  });

  final String label;
  final bool   active;
  final bool   done;
  final bool   isFirst;
  final bool   isLast;
  final bool   leftLineOn;
  final bool   rightLineOn;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color reached = context.mainColor;       // activo/completado (verde)
    final Color pending = context.disabledColor;   // aún no alcanzado
    final Color dotColor = (active || done) ? reached : pending;

    return MouseRegion(
      cursor: onTap == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child : GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Media línea izquierda (transparente en el primer paso).
                Expanded(child: Container(height: 2, color: isFirst ? Colors.transparent : (leftLineOn ? reached : pending))),
                Container(
                  width     : 22, height: 22,
                  alignment : Alignment.center,
                  decoration: BoxDecoration(color: (active || done) ? dotColor : pending.withValues(alpha: .25), shape: BoxShape.circle),
                  child     : Icon(Icons.check, size: 13, color: (active || done) ? Colors.white : pending),
                ),
                // Media línea derecha (transparente en el último paso).
                Expanded(child: Container(height: 2, color: isLast ? Colors.transparent : (rightLineOn ? reached : pending))),
              ],
            ),
            const SizedBox(height: 6),
            NText(
              text    : label,
              size    : 12,
              align   : TextAlign.center,
              color   : (active || done) ? reached : pending,
              weight  : active ? FontWeight.w600 : FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
