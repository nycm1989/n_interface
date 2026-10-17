import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, FilteringTextInputFormatter;
import 'package:n_interface/n_interface.dart' show NTooltip, ContextExtension;
import 'axis_layout.dart' show NAxisLayout;

class NTextField extends StatefulWidget {
  final Axis       axis;
  final bool       isRequired;
  final Widget? action;
  final String?    title;
  final TextOverflow? overflow;
  final double?    width;
  final FontWeight?  weight;
  final double?    height;
  final EdgeInsetsGeometry? margin;
  final bool       isNDropdown;
  final bool       enable;
  final bool       readOnly;
  final bool       obscureText;
  final bool       bounded;
  final bool       showLength;
  final bool       hasError;
  final bool       grouped;
  final TextAlign  align;
  final int?       maxLines;
  final int        minLines;
  final Color?     color;
  final TextInputType? type;
  final NTextFieldAction? suffix;
  final NTextFieldAction? prefix;
  final String?    hint;
  final FocusNode? nextFocusNode;
  final Color?     textColor;
  final NTextController? controller;
  final ValueChanged<String>? onChanged;
  final FutureOr<void> Function(String)? onEnter;
  final num?       precision;
  final TextStyle? textStyle;
  final int?       maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const NTextField({
    this.axis        = Axis.vertical,
    this.isRequired  = false,
    this.action,
    this.title,
    this.overflow,
    this.width,
    this.weight,
    this.height,
    this.margin,
    this.isNDropdown  = false,
    this.enable      = true,
    this.readOnly    = false,
    this.obscureText = false,
    this.bounded     = false,
    this.showLength  = false,
    this.hasError    = false,
    this.grouped     = false,
    this.align       = .start,
    this.maxLines    = 1,
    this.minLines    = 1,
    this.color,
    this.type,
    this.suffix,
    this.prefix,
    this.hint,
    this.nextFocusNode,
    this.textColor,
    this.controller,
    this.onChanged,
    this.onEnter,
    this.precision,
    this.textStyle,
    this.maxLength,
    this.inputFormatters,
    super.key
  });

  @override
  State<NTextField> createState() => _NTextFieldState();
}

class _NTextFieldState extends State<NTextField> {
  bool _isLoading = false;

  static OutlineInputBorder createBorder(Color color) => OutlineInputBorder(
    borderSide	 : BorderSide(color: color),
    borderRadius : BorderRadius.circular(10),
  );

  @override
  Widget build(BuildContext context) {
    return NAxisLayout(
      axis        : widget.axis,
      isRequired  : widget.isRequired,
      action      : widget.action,
      title       : widget.title,
      overflow    : widget.overflow,
      width       : widget.width,
      weight      : widget.weight,
      height      : widget.height,
      margin      : widget.margin,
      child       :
      Form(
        key   : widget.controller?.validator?.key,
        child :
        TextFormField(
          showCursor  : !widget.isNDropdown,
          focusNode   : widget.controller?.focusNode,
          maxLines    : widget.maxLines,
          minLines    : widget.minLines,
          maxLength   : widget.maxLength,
          style       : widget.textStyle ?? TextStyle(fontSize: 12, color: widget.textColor),
          onChanged   : (text) {
            widget.onChanged?.call(widget.grouped ? GroupedNumberFormatter.ungroup(text) : text);
            widget.controller != null ? widget.controller!.validator != null ? widget.controller!.validator?.validate() : true : true;
          },
          onFieldSubmitted: (text) async {
            if (widget.onEnter != null) {
              setState(() => _isLoading = true);
              try {
                await Future.value(widget.onEnter!(widget.grouped ? GroupedNumberFormatter.ungroup(text) : text));
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            }
          },
          validator: (value) {
            final String? text = widget.grouped && value != null ? GroupedNumberFormatter.ungroup(value) : value;
            if (widget.controller != null) {
              if (widget.controller!.validator != null) {
                if (!widget.isRequired && (text == null || text.isEmpty)) return null;
                if (text == null) return widget.controller!.validator!.error ?? "";
                if (text.isEmpty) return widget.controller!.validator!.error ?? "";
                if (widget.controller!.validator!.dinamic != null) return widget.controller!.validator!.dinamic!.call();
                if (widget.controller!.validator!.regExp != null) return widget.controller!.validator!.regExp!.hasMatch(text) ? null : widget.controller!.validator!.error ?? "";
                if (widget.controller!.validator!.function != null) return widget.controller!.validator!.function!(text) ? null : widget.controller!.validator!.error ?? "";
              }
            }
            return null;
          },
          inputFormatters: widget.type == TextInputType.number
            ? [widget.grouped ? GroupedNumberFormatter() : NCustomNumberFormatter(NPatterns.fiatFormat), ...?widget.inputFormatters]
            : widget.type == TextInputType.datetime
              ? [FilteringTextInputFormatter.allow(NPatterns.dateTime), ...?widget.inputFormatters]
              : widget.inputFormatters,
          keyboardType      : widget.type == TextInputType.none ? null : widget.type,
          controller        : widget.grouped ? (widget.controller?..grouped = true) : widget.controller,
          readOnly          : widget.readOnly,
          enabled           : widget.isNDropdown ? false : widget.enable,
          textAlign         : widget.align,
          obscureText       : widget.obscureText,
          textInputAction   : TextInputAction.send,
          textAlignVertical : TextAlignVertical.center,
          cursorWidth       : 0.5,
          decoration        :
          InputDecoration(
            border        : widget.hasError ? createBorder(Colors.red) : null,
            enabledBorder : widget.hasError ? createBorder(Colors.red) : null,
            focusedBorder : widget.hasError ? createBorder(Colors.red) : null,
            errorMaxLines : 6,
            errorStyle    :
            TextStyle(
              fontFamily  : "Poppins",
              fontSize    : widget.controller?.validator?.error != null ? 12 : 0,
              color       : Colors.red,
            ),
            fillColor: !widget.isNDropdown
              ? null
              : WidgetStateColor.resolveWith((states) {
                  if (states.contains(WidgetState.disabled)) return Colors.white;
                  return Colors.white;
                }),
            counterText : widget.showLength ? null : "",
            isCollapsed : true,
            hintText    : widget.hint != "" ? widget.hint : null,
            prefixIcon  : widget.prefix ?? const NTextFieldAction.prefix(margin: EdgeInsets.only(left: 5)),
            suffixIcon  : _isLoading
              ? const SizedBox(
                  width: 30,
                  height: 30,
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 1),
                  ),
                )
              : (widget.suffix ?? const NTextFieldAction.suffix(margin: EdgeInsets.only(left: 5))),
            contentPadding        : const EdgeInsets.symmetric(vertical: 12),
            suffixIconConstraints : const BoxConstraints(maxHeight: 30, minHeight: 30),
            prefixIconConstraints : const BoxConstraints(maxHeight: 30, minHeight: 30),
          ),
        ),
      ),
    );
  }
}


class NCustomNumberFormatter extends TextInputFormatter {
  final RegExp allowedPattern;

  NCustomNumberFormatter(this.allowedPattern);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue
  ) {
    final newText = newValue.text;

    if (newText.isEmpty) return newValue;
    if (allowedPattern.hasMatch(newText)) return newValue;
    return oldValue;
  }
}

/// Separador de miles en vivo para campos `type: .number` con `grouped: true`
/// (`1234.5` → `1,234.5`), manteniendo el tope de 2 decimales de
/// [NPatterns.fiatFormat]. El texto del controller queda **con** comas: todo
/// lectura de ese texto debe limpiarlas con `PriceFactory.extract`.
class GroupedNumberFormatter extends TextInputFormatter {
  static final RegExp _typing  = RegExp(r'^-?[0-9]*(\.[0-9]{0,2})?$');
  static final RegExp _numeric = RegExp(r'^-?[0-9]*(\.[0-9]*)?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue
  ) {
    final String raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty)                return const TextEditingValue();
    if (!_typing.hasMatch(raw))     return oldValue;

    final String formatted = _group(raw);

    return TextEditingValue(
      text      : formatted,
      selection : TextSelection.collapsed(offset: _caret(formatted, _digitsBeforeCaret(newValue))),
    );
  }

  /// Quita el separador de miles (`"24,000.00"` → `"24000.00"`); deja intacto
  /// cualquier texto que no sea un número, para que una dirección con comas no
  /// las pierda si el campo se marcó `grouped` por error.
  static String ungroup(String text) =>
  _numeric.hasMatch(text.replaceAll(',', '')) ? text.replaceAll(',', '') : text;

  /// Agrupa un texto ya numérico (`"24000.00"` → `"24,000.00"`); deja intacto
  /// cualquier texto que no sea un número.
  static String group(String text) =>
  text.isEmpty || !_numeric.hasMatch(text.replaceAll(',', ''))
  ? text
  : _group(text.replaceAll(',', ''));

  static String _group(String raw) {
    final String    body      = raw.startsWith('-') ? raw.substring(1) : raw;
    final int       dot       = body.indexOf('.');
    final String    integer   = dot == -1 ? body : body.substring(0, dot);
    final String    decimals  = dot == -1 ? ""   : body.substring(dot);
    final StringBuffer grouped = StringBuffer();

    for (int index = 0; index < integer.length; index++) {
      if (index > 0 && (integer.length - index) % 3 == 0) grouped.write(',');
      grouped.write(integer[index]);
    }

    return "${raw.startsWith('-') ? '-' : ''}$grouped$decimals";
  }

  /// Cantidad de caracteres útiles (sin comas) que quedan antes del cursor: es
  /// la posición estable entre el texto crudo y el agrupado.
  static int _digitsBeforeCaret(TextEditingValue value) {
    final int caret = value.selection.baseOffset < 0 ? value.text.length : value.selection.baseOffset;
    return caret - value.text.substring(0, caret).split(',').length + 1;
  }

  static int _caret(String formatted, int digitsBefore) {
    if (digitsBefore <= 0) return 0;

    int seen = 0;
    for (int index = 0; index < formatted.length; index++) {
      if (formatted[index] != ',') seen++;
      if (seen == digitsBefore) return index + 1;
    }
    return formatted.length;
  }
}



enum _ActionType{
  prefix,
  suffix
}

class NTextFieldAction extends StatefulWidget {
  final String      ? asset;
  final String      ? text;
  final String      ? tooltip;
  final IconData    ? icon;
  final Color       ? textColor;
  final double      ? iconSize;
  // ignore: library_private_types_in_public_api
  final _ActionType   type;
  final EdgeInsetsGeometry?  margin;
  final FutureOr<void> Function()? onTap;

  const NTextFieldAction.suffix({
    super.key,
    this.text,
    this.asset,
    this.icon,
    this.textColor,
    this.margin,
    this.onTap,
    this.iconSize,
    this.tooltip
  }) : type = .suffix;

  const NTextFieldAction.prefix({
    super.key,
    this.text,
    this.asset,
    this.icon,
    this.textColor,
    this.margin,
    this.onTap,
    this.iconSize,
    this.tooltip
  }) : type = .prefix;

  @override
  State<NTextFieldAction> createState() => _NTextFieldActionState();
}

class _NTextFieldActionState extends State<NTextFieldAction> {
  StreamController<bool>? streamController;
  bool over = false;

  @override
  void initState()  {
    super.initState();
    streamController?.close();
    streamController == null;
  }

  @override
  void reassemble() {
    super.reassemble();
    streamController?.close();
    streamController == null;
  }

  @override
  void dispose()    {
    super.dispose();
    streamController?.close();
    streamController == null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor  : widget.onTap != null ? SystemMouseCursors.click: MouseCursor.uncontrolled,
      onEnter : widget.onTap != null ? (event) => setState(() => over = !over) : null,
      onExit  : widget.onTap != null ? (event) => setState(() => over = !over) : null,
      child:
      Padding(
        padding : widget.margin ?? .zero,
        child   :
        GestureDetector(
          onTap: () async {
            if(widget.onTap is Future<void> Function()){
              streamController = StreamController<bool>();
              setState(()=> streamController?.add(true));
              await Future.value(widget.onTap!())
              .whenComplete(() {
                streamController?.close();
                setState(()=> streamController = null);
              })
              .then((value) {
                streamController?.close();
                setState(()=> streamController = null);
              })
              .onError((error, stackTrace) {
                try{ setState(()=> streamController = null); }
                catch(e) { streamController = null; }
                // showOnErrorDialog(context, error, stackTrace, origin: kIsWeb ? "TextInput.GestureDetector" : StackTrace.current.toString());
              });
            } else {
              streamController?.close();
              streamController = null;
              widget.onTap?.call();
            }
          },
          child:
          StreamBuilder<bool>(
            stream  : streamController?.stream,
            builder : (context, snapshot) =>
            Row(
              mainAxisSize  : .min,
              children      : [
                if(widget.type == .prefix && widget.asset != null)
                _AssetIconContainer(
                  type            : widget.type,
                  iconSize        : widget.iconSize,
                  asset           : widget.asset,
                  icon            : widget.icon,
                  connectionState : snapshot.connectionState,
                  loadColor       : widget.textColor,
                  tooltip         : widget.tooltip,
                ),
                if(widget.text != null)
                Padding(
                  padding : EdgeInsets.only(
                    left  :  widget.asset == null && widget.type == .prefix ? 7 : 0,
                    right :  widget.asset == null && widget.type == .suffix ? 7 : 0,
                    bottom: 2
                  ),
                  child   :
                  Text(
                    widget.text!,
                    style:
                    TextStyle(
                      color: widget.textColor ?? Colors.grey.shade700
                    ),
                  ),
                ),
                if(widget.type == .suffix && (widget.asset != null || widget.icon != null))
                _AssetIconContainer(
                  type            : widget.type,
                  asset           : widget.asset,
                  icon            : widget.icon,
                  iconSize        : widget.iconSize,
                  connectionState : snapshot.connectionState,
                  loadColor       : widget.textColor,
                  tooltip         : widget.tooltip,
                )
              ]
            )
          )
        ),
      )
    );
  }
}

class _AssetIconContainer extends StatelessWidget {
  final String    ? asset;
  final IconData  ? icon;
  final Color     ? loadColor;
  final double    ? iconSize;
  final String    ? tooltip;
  final ConnectionState connectionState;
  final _ActionType type;

  const _AssetIconContainer({
    required this.asset,
    required this.icon,
    required this.iconSize,
    required this.connectionState,
    required this.loadColor,
    required this.tooltip,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return NTooltip(
      message : tooltip ?? "",
      child   :
      Container(
        // color   : Colors.red,
        padding  : .only(
          left  : type == .prefix ? 7 : 4,
          right : type == .suffix ? 7 : 4
        ),
        child   : [ConnectionState.none, ConnectionState.done].contains(connectionState)
        ? asset != null
          ? Image.asset(
            asset!,
            width : iconSize ?? 17,
            height: iconSize ?? 17,
          )
          : Icon(icon, color: context.textColor, size: iconSize ?? 17)
        : SizedBox.square(
          dimension : iconSize ?? 17,
          child     :
          CircularProgressIndicator(
            strokeWidth: 1,
            color: loadColor ?? Colors.grey
          ),
        )
      ),
    );
  }
}


class NTextController extends TextEditingController{
  NTextFieldValidator? validator;
  final FocusNode focusNode = FocusNode();

  /// Modo separador de miles. El texto **pintado** lleva comas y [text]
  /// devuelve el número limpio, así los `num.tryParse(controller.text)` de los
  /// call sites siguen funcionando sin tocarlos. Lo enciende
  /// `NTextField(grouped: true)`; pasarlo aquí además formatea el valor
  /// inicial.
  bool grouped;

  NTextController({ String? text, this.validator, this.grouped = false }) : super(text: text) {
    if (grouped) value = TextEditingValue(text: GroupedNumberFormatter.group(text ?? ""));
  }

  @override
  String get text => grouped ? GroupedNumberFormatter.ungroup(value.text) : value.text;

  @override
  set text(String newText) =>
  value = value.copyWith(
    text      : grouped ? GroupedNumberFormatter.group(newText) : newText,
    selection : const TextSelection.collapsed(offset: -1),
    composing : TextRange.empty,
  );

  /// El cursor se mueve sobre el texto **pintado** (con comas), pero el setter
  /// heredado valida los límites contra `text` (sin comas, más corto) y lanza
  /// `invalid text selection`. Se replica acotando contra lo pintado.
  @override
  set selection(TextSelection newSelection) {
    if (!grouped) { super.selection = newSelection; return; }

    value = value.copyWith(
      selection : newSelection.end <= value.text.length ? newSelection : TextSelection.collapsed(offset: value.text.length),
      composing : TextRange.empty,
    );
  }

  /// `TextFormField.didChange` reescribe el value en cada tecla cuando
  /// `controller.text` difiere del texto pintado — con `grouped` difieren
  /// siempre que haya una coma — y lo hace con la selección inválida, lo que
  /// manda el cursor al final. Si el texto no cambió, esa reescritura no aporta
  /// nada: se conserva la selección para poder escribir en medio del número.
  @override
  set value(TextEditingValue newValue) {
    if (!grouped) { super.value = newValue; return; }

    final String groupedText = GroupedNumberFormatter.group(newValue.text);

    if (groupedText == value.text && !newValue.selection.isValid) return;

    super.value = newValue.selection.end <= groupedText.length
    ? newValue.copyWith(text: groupedText)
    : TextEditingValue(text: groupedText, selection: TextSelection.collapsed(offset: groupedText.length));
  }

  /// El pintado debe usar `value.text` — con comas —; el `text` heredado ya
  /// devuelve el número sin ellas.
  @override
  TextSpan buildTextSpan({ required BuildContext context, TextStyle? style, required bool withComposing }) =>
  grouped
  ? TextSpan(style: style, text: value.text)
  : super.buildTextSpan(context: context, style: style, withComposing: withComposing);

  NTextFieldValidator changeValidator(NTextFieldValidator validator) => this.validator = validator;
  void focus(BuildContext context) => FocusScope.of(context).requestFocus(focusNode);
}

class NTextFieldValidator{
  GlobalKey<FormState> key;
  RegExp? regExp;
  Function(String text)? function;
  String? error;
  String? Function()? dinamic;

  NTextFieldValidator({ required this.key });

  // Validadores predefinidos como métodos estáticos
  NTextFieldValidator.email   ({ required this.key, this.error }) : regExp = NPatterns.email;
  NTextFieldValidator.number  ({ required this.key, this.error }) : regExp = NPatterns.dotNumber;
  NTextFieldValidator.notEmpty({ required this.key, this.error }) : regExp = NPatterns.notEmpty;
  NTextFieldValidator.dateTime({ required this.key, this.error }) : regExp = NPatterns.dateTime;
  NTextFieldValidator.coords  ({ required this.key, this.error }) : regExp = NPatterns.coords;
  NTextFieldValidator.url     ({ required this.key, this.error }) : function = NPatterns.url;
  NTextFieldValidator.phonenumber({ required this.key, this.error }) : regExp = NPatterns.phonenumber;
  NTextFieldValidator.superonlytextspaces({ required this.key, this.error }) : regExp = NPatterns.superonlytextspaces;
  NTextFieldValidator.superonlytextwithoutspaces({ required this.key, this.error }) : regExp = NPatterns.superonlytextwithoutspaces;
  NTextFieldValidator.alphanumericwithoutexpressions({ required this.key, this.error }) : regExp = NPatterns.alphanumericwithoutexpressions;

  // Validación personalizada basada en expresión regular proporcionada por el usuario
  NTextFieldValidator.pattern ({ required this.key, this.error, required String pattern }) :
    regExp = RegExp(pattern, unicode: true);


  NTextFieldValidator.maximum({ required this.key, this.error, required num max }) :
  function = ((text) {
    if (text.isEmpty) return true;
    final n = num.tryParse(text);
    if (n == null) return false;
    return n <= max;
  });

  /// Espejo de [NTextFieldValidator.maximum] para el piso de un rango. A
  /// diferencia de aquel, el vacío no pasa: exigir un mínimo implica que el
  /// campo tiene que traer un número.
  NTextFieldValidator.minimum({ required this.key, this.error, required num min }) :
  function = ((text) {
    if (text.isEmpty) return false;
    final n = num.tryParse(text);
    if (n == null) return false;
    return n >= min;
  });

  // Nueva validacion para valor minimo y maximo
  NTextFieldValidator.rangeMinMax({
    required this.key,
    required num min,
    required num max,
    this.error,
  }) :
  function = ((text) {
    if (text.isEmpty) return false;

    final n = num.tryParse(text);
    if (n == null) return false;

    // 🔴 BLOQUEO DE RANGO INVÁLIDO
    if (max < min) return false;
    if (n < min) return false;
    if (n > max) return false;

    return true;
  });




  NTextFieldValidator.regExp({ required this.key, this.error, required this.regExp });


  NTextFieldValidator.numbersAndLetters({ required this.key, this.error}) :
    regExp = NPatterns.numbersAndLetters;


  NTextFieldValidator.length({
    this.error,
    required this.key,
    required int length
  }) : regExp = NPatterns.length(length: length);


  NTextFieldValidator.rangeLength({
    this.error,
    int min = 0,
    required this.key,
    required int max,
  }) : regExp = NPatterns.rangeLength(min: min, max: max);


  NTextFieldValidator.range({
    this.error,
    required this.key,
    required double min,
    required double max
  }) : function = NPatterns.range(min: min, max: max);


  void updateFunction({ Function(String text)? function }) {
    this.function = function;
    regExp        = null;
  }


  void updateRegExp({ required RegExp regExp }) {
    this.regExp = regExp;
    function    = null;
  }


  void updateError({ required String error }) {
    this.error = error;
  }


  bool validate({
    String? Function()? dinamic,
    String ? text
  }) {
    if (text?.isEmpty ?? false) return true;

    if(dinamic != null) {
      this.dinamic  = dinamic;
      function      = null;
      regExp        = null;
    }

    return key.currentState?.validate()??false;
  }
}

class NPatterns {
  static RegExp get email             => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static RegExp get dotNumber         => RegExp(r"^-?[0-9]+([.][0-9]*)?$");
  static RegExp get cryptoFormat      => RegExp(r"^-?[0-9]+(\.[0-9]{0,5})?$");
  static RegExp get fiatFormat        => RegExp(r"^-?[0-9]+(\.[0-9]{0,2})?$");

  static RegExp get phonenumber       => RegExp(r'^[0-9]+$');
  static RegExp get superonlytextspaces     => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  static RegExp get alphanumericwithoutexpressions      => RegExp(r'^[0-9a-zA-Z]+$');
  static RegExp get superonlytextwithoutspaces => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$');
  // Char-class (NO anclada) para `FilteringTextInputFormatter.allow` en campos de
  // NOMBRE/APELLIDO de persona: letras + tildes + ñ + espacios + puntos. Bloquea
  // números y otros símbolos al teclear (los validadores anclados `^...$` de
  // arriba no sirven como filtro allow, que evalúa carácter por carácter).
  static RegExp get personNameChars => RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ .]');

  static RegExp get periodNumber      => RegExp(r"^-?[0-9]+([,][0-9]*)?$");
  static RegExp get notEmpty          => RegExp(r'^\S.*$');
  static RegExp get numbersAndLetters => RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
  static RegExp get dateTime          => RegExp(r"\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}\b");
  static RegExp get coords            => RegExp(r'^([-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)),\s*([-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?))$');

  /// Acepta únicamente URLs absolutas HTTP o HTTPS con un host válido.
  /// Se usa una expresión regular más flexible para aceptar dominios con guiones
  /// y otras variaciones válidas.
  static bool Function(String value) get url => (value) {
    if (value.isEmpty || value.contains(RegExp(r'\s'))) return false;

    // Expresión regular que acepta http(s)://dominio.ext/ruta
    // Permite guiones, puntos y guiones bajos en dominio y ruta
    final RegExp urlPattern = RegExp(
      r'^https?://[a-zA-Z0-9\-\.]+(\.[a-zA-Z]{2,})?(/.*)?$',
      caseSensitive: false,
    );

    return urlPattern.hasMatch(value);
  };


  static RegExp length({ required num length }) {
    final pattern = r'^\d{' + length.toInt().toString() + r'}$';
    return RegExp(pattern);
  }


  static RegExp rangeLength({
    required num max,
    num min = 0,
  }) => RegExp(r'^.{' + min.toString() + r',' + max.toString() + r'}$');


  static bool Function(String n) range({
    required num min,
    required num max,
  }) {
    assert(min <= max);

    return (n) => (dotNumber).hasMatch(n)
    ? num.parse(n) >= min && num.parse(n) <= max
    : false;
  }


  static bool Function(String n) regExpOrNull({ required RegExp? regExp })
    => (n) => regExp != null ? regExp.hasMatch(n) : false;
}
