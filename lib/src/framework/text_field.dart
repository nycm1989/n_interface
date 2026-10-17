import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show TextInputFormatter, FilteringTextInputFormatter;
import 'package:n_interface/src/extenssions/context_extension.dart' show ContextExtension;

import 'axis_layout.dart' show NAxisLayout;

class NTextField extends NAxisLayout {

  static OutlineInputBorder get _errorBorder => OutlineInputBorder(
    borderSide	 : BorderSide(color: Colors.red),
    borderRadius : BorderRadius.circular(10),
  );

  NTextField({
    super.axis        = .vertical,
    super.isRequired  = false,
    super.action,
    super.title,
    super.overflow,
    super.width,
    super.weight,
    super.height,
    super.margin,
    super.key,
    //--------------------------------------------
    bool      isNDropdown  = false,
    bool      enable      = true,
    bool      readOnly    = false,
    bool      obscureText = false,
    bool      bounded     = false,
    bool      showLength  = false,
    bool      hasError    = false,
    TextAlign align       = .start,
    int       ? maxLines    = 1,
    int       minLines    = 1,
    //--------------------------------------------
    Color                 ? color,
    TextInputType         ? type,
    TextFieldAction           ? suffix,
    TextFieldAction           ? prefix,
    String                ? hint,
    FocusNode             ? nextFocusNode,
    Color                 ? textColor,
    NTextController       ? controller,
    ValueChanged<String>  ? onChanged,
    num                   ? precision,
    TextStyle             ? textStyle,
    int                   ? maxLength,
    List<TextInputFormatter> ? inputFormatters,
    String                ? fontFamily = '',
  }) : super (
    child   :
    Form(
      key   : controller?.validator?.key,
      child :
      TextFormField(
        showCursor: !isNDropdown,
        focusNode : controller?.focusNode,
        maxLines  : maxLines,
        minLines  : minLines,
        maxLength : maxLength,
        style     :
        textStyle ?? TextStyle(
          fontSize: 12,
          color   : textColor
        ),
        onChanged         : (text) {
          onChanged?.call(text);
          controller != null
          ? controller.validator != null
            ? controller.validator?.validate()
            : true
          : true;
        },
        validator         : (text) {
          if(controller != null){
            if(controller.validator != null){
              if (!isRequired && (text == null || text.isEmpty)) return null;
              if(text == null) return controller.validator!.error??"";
              if(text.isEmpty) return controller.validator!.error??"";
              if(controller.validator!.dinamic  != null) return controller.validator!.dinamic!.call();
              if(controller.validator!.regExp   != null) return controller.validator!.regExp!.hasMatch(text) ? null : controller.validator!.error??"";
              if(controller.validator!.function != null) return controller.validator!.function!(text) ? null : controller.validator!.error??"";
            }
          }
          return null;
        },
        inputFormatters   :
        type == .number   ? [ CustomNumberFormatter(Patterns.fiatFormat ), ...?inputFormatters ] :
        type == .datetime ? [ FilteringTextInputFormatter.allow(Patterns.dateTime ), ...?inputFormatters ] :
        inputFormatters,
        keyboardType      : type == .none ? null : type,
        controller        : controller,
        readOnly          : readOnly,
        enabled           : isNDropdown ? false : enable,
        textAlign         : align,
        obscureText       : obscureText,
        textInputAction   : .send,
        textAlignVertical : .center,
        cursorWidth       : 0.5,
        decoration        :
        InputDecoration(
          border        : hasError ? _errorBorder : null,
          enabledBorder : hasError ? _errorBorder : null,
          focusedBorder : hasError ? _errorBorder : null,
          errorMaxLines : 6,
          errorStyle    :
          TextStyle(
            fontFamily  : fontFamily ?? 'Poppins',
            fontSize    : controller?.validator?.error != null ? 12 : 0,
            color       : Colors.red
          ),
          fillColor           : !isNDropdown ? null :  WidgetStateColor.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Colors.white;
            return Colors.white;
          }),
          counterText   : showLength ? null : "",
          isCollapsed   : true,
          hintText      : hint != "" ? hint : null,
          prefixIcon    : prefix ?? const TextFieldAction.prefix(margin: .only(left: 5)),
          suffixIcon    : suffix ?? const TextFieldAction.suffix(margin: .only(left: 5)),
          contentPadding: const EdgeInsets.symmetric( vertical: 12, horizontal: 16 ),
          suffixIconConstraints : const BoxConstraints( maxHeight : 30, minHeight : 30 ),
          prefixIconConstraints : const BoxConstraints( maxHeight : 30, minHeight : 30 ),
        ),
      ),
    ),
  );
}

class CustomNumberFormatter extends TextInputFormatter {
  final RegExp allowedPattern;

  CustomNumberFormatter(this.allowedPattern);

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


class TextFieldAction extends _TextFieldAction{
  const TextFieldAction.suffix({
    super.key,
    super.text,
    super.asset,
    super.icon,
    super.textColor,
    super.margin,
    super.onTap,
    super.iconSize,
    super.weight
  }) : super(type: .suffix);

  const TextFieldAction.prefix({
    super.key,
    super.text,
    super.asset,
    super.icon,
    super.textColor,
    super.margin,
    super.onTap,
    super.iconSize,
    super.weight
  }) : super(type: .prefix);
}



/// Defines the position of an action widget inside a text field.
enum _ActionType{
  /// Action placed at the start (left) of the text field.
  prefix,
  /// Action placed at the end (right) of the text field.
  suffix
}

class _TextFieldAction extends StatefulWidget {
  final FutureOr<void> Function()? onTap;
  final String      ? asset;
  final String      ? text;
  final IconData    ? icon;
  final Color       ? textColor;
  final double        iconSize;
  final _ActionType   type;
  final FontWeight  ? weight;
  final EdgeInsetsGeometry?  margin;
  const _TextFieldAction({
    this.asset,
    this.text,
    this.icon,
    this.textColor,
    this.margin,
    this.iconSize = 17,
    this.type = .prefix,
    this.onTap,
    this.weight,
    super.key
  });

  @override
  State<_TextFieldAction> createState() => __TextFieldActionState();
}

class __TextFieldActionState extends State<_TextFieldAction> {
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
              mainAxisSize : .min,
              children     : [
                if(widget.type == .prefix && widget.asset != null)
                _AssetIconContainer(
                  iconSize        : widget.iconSize,
                  asset           : widget.asset,
                  icon            : widget.icon,
                  connectionState : snapshot.connectionState,
                  loadColor       : widget.textColor,
                ),
                if(widget.text != null)
                Padding(
                  padding :
                  EdgeInsets.only(
                    left  : widget.type == .prefix ? 15 : 5,
                    right : widget.type == .suffix ? 15 : 5
                  ),
                  child   :
                  Text(
                    widget.text!,
                    style:
                    TextStyle(
                      fontWeight: widget.weight,
                      color     : widget.textColor ?? Colors.grey.shade700
                    ),
                  ),
                ),
                if(widget.type == .suffix && (widget.asset != null || widget.icon != null))
                _AssetIconContainer(
                  asset           : widget.asset,
                  icon            : widget.icon,
                  iconSize        : widget.iconSize,
                  connectionState : snapshot.connectionState,
                  loadColor       : widget.textColor,
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
  final double      iconSize;
  final ConnectionState connectionState;
  const _AssetIconContainer({
    required this.asset,
    required this.icon,
    required this.iconSize,
    required this.connectionState,
    required this.loadColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width   : iconSize,
      height  : iconSize,
      margin  : const .symmetric(horizontal: 5),
      child   : [ConnectionState.none, ConnectionState.done].contains(connectionState)
      ? asset != null
        ? Image.asset(asset!)
        : Icon(icon, color: context.textColor, size: 17)
      : CircularProgressIndicator(
        strokeWidth: 1,
        color: loadColor ?? Colors.grey
      )
    );
  }
}


class NTextController extends TextEditingController{
  TextFieldValidator? validator;
  final FocusNode focusNode = FocusNode();
  NTextController({ super.text, this.validator });

  TextFieldValidator changeValidator(TextFieldValidator validator) => this.validator = validator;
  void focus(BuildContext context) => FocusScope.of(context).requestFocus(focusNode);
}

class TextFieldValidator{
  GlobalKey<FormState> key;
  RegExp? regExp;
  Function(String text)? function;
  String? error;
  String? Function()? dinamic;

  TextFieldValidator({ required this.key });

  // Validadores predefinidos como métodos estáticos
  TextFieldValidator.email   ({ required this.key, this.error }) : regExp = Patterns.email;
  TextFieldValidator.number  ({ required this.key, this.error }) : regExp = Patterns.dotNumber;
  TextFieldValidator.notEmpty({ required this.key, this.error }) : regExp = Patterns.notEmpty;
  TextFieldValidator.dateTime({ required this.key, this.error }) : regExp = Patterns.dateTime;
  TextFieldValidator.coords  ({ required this.key, this.error }) : regExp = Patterns.coords;
  TextFieldValidator.phonenumber({ required this.key, this.error }) : regExp = Patterns.phonenumber;
  TextFieldValidator.superonlytextspaces({ required this.key, this.error }) : regExp = Patterns.superonlytextspaces;
  TextFieldValidator.superonlytextwithoutspaces({ required this.key, this.error }) : regExp = Patterns.superonlytextwithoutspaces;
  TextFieldValidator.alphanumericwithoutexpressions({ required this.key, this.error }) : regExp = Patterns.alphanumericwithoutexpressions;

  // Validación personalizada basada en expresión regular proporcionada por el usuario
  TextFieldValidator.pattern ({ required this.key, this.error, required String pattern }) :
    regExp = RegExp(pattern, unicode: true);


  TextFieldValidator.maximum({ required this.key, this.error, required num max }) :
  function = ((text) {
    if (text.isEmpty) return true;
    final n = num.tryParse(text);
    if (n == null) return false;
    return n <= max;
  });

  // Nueva validacion para valor minimo y maximo
  TextFieldValidator.rangeMinMax({
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




  TextFieldValidator.regExp({ required this.key, this.error, required this.regExp });


  TextFieldValidator.numbersAndLetters({ required this.key, this.error}) :
    regExp = Patterns.numbersAndLetters;


  TextFieldValidator.length({
    this.error,
    required this.key,
    required int length
  }) : regExp = Patterns.length(length: length);


  TextFieldValidator.rangeLength({
    this.error,
    int min = 0,
    required this.key,
    required int max,
  }) : regExp = Patterns.rangeLength(min: min, max: max);


  TextFieldValidator.range({
    this.error,
    required this.key,
    required double min,
    required double max
  }) : function = Patterns.range(min: min, max: max);


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

class Patterns {
  static RegExp get email             => RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static RegExp get dotNumber         => RegExp(r"^-?[0-9]+([.][0-9]*)?$");
  static RegExp get cryptoFormat      => RegExp(r"^-?[0-9]+(\.[0-9]{0,5})?$");
  static RegExp get fiatFormat        => RegExp(r"^-?[0-9]+(\.[0-9]{0,2})?$");

  static RegExp get phonenumber       => RegExp(r'^[0-9]+$');
  static RegExp get superonlytextspaces     => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
  static RegExp get alphanumericwithoutexpressions      => RegExp(r'^[0-9a-zA-Z]+$');
  static RegExp get superonlytextwithoutspaces => RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ]+$');

  static RegExp get periodNumber      => RegExp(r"^-?[0-9]+([,][0-9]*)?$");
  static RegExp get notEmpty          => RegExp(r'^\S.*$');
  static RegExp get numbersAndLetters => RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z0-9]+$');
  static RegExp get dateTime          => RegExp(r"\b(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}\b");
  static RegExp get coords            => RegExp(r'^([-+]?([1-8]?\d(\.\d+)?|90(\.0+)?)),\s*([-+]?(180(\.0+)?|((1[0-7]\d)|([1-9]?\d))(\.\d+)?))$');


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