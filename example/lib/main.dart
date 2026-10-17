import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:n_interface/n_interface.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by the locale-aware getters of DateTimeExtension.
  await initializeDateFormatting();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) =>
  StyledToast(
    child :
    MaterialApp(
      title : 'n_interface example',
      debugShowCheckedModeBanner : false,
      theme :
      ThemeData(
        useMaterial3  : true,
        colorScheme   : ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        scaffoldBackgroundColor : const Color(0xFFF4F5F7),
        cardColor     : Colors.white,
        dividerColor  : const Color(0xFFE3E5E8),
        disabledColor : const Color(0xFFBDBDBD),
      ),
      home  :
      const DemoPage(),
    ),
  );
}

/// Signature used by the widgets that need to show a toast.
typedef ToastCallback = void Function(
  String message, {
  bool isValid,
  bool center,
});

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  final GlobalKey<FormState> _nameKey   = GlobalKey<FormState>();
  final GlobalKey<FormState> _emailKey  = GlobalKey<FormState>();
  final GlobalKey<FormState> _amountKey = GlobalKey<FormState>();

  late final NTextController _name   = NTextController(
    validator :
    TextFieldValidator.notEmpty(
      key   : _nameKey,
      error : 'Name is required',
    ),
  );
  late final NTextController _email  = NTextController(
    validator :
    TextFieldValidator.email(
      key   : _emailKey,
      error : 'Enter a valid email',
    ),
  );
  late final NTextController _amount = NTextController(
    text : '0',
    validator :
    TextFieldValidator.rangeMinMax(
      key   : _amountKey,
      min   : 1,
      max   : 1000,
      error : 'Value must be between 1 and 1000',
    ),
  );
  final NTextController _dialogTitle = NTextController();

  bool   _switch     = true;
  bool   _switch2    = false;
  bool   _throwError = false;
  String _company    = 'n_interface';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _amount.dispose();
    _dialogTitle.dispose();
    super.dispose();
  }

  void _toast(String message, {
    bool isValid = true,
    bool center  = false,
  }) =>
  NToast.show(context,
    message : message,
    isValid : isValid,
    center  : center,
  );

  @override
  Widget build(BuildContext context) =>
  Scaffold(
    body :
    SafeArea(
      child :
      NResponsiveBuilder(
        onLoading : () async => await Future<void>.delayed(const Duration(milliseconds: 500)),
        indicator :
        const Center(
          child :
          CircularProgressIndicator(),
        ),
        padding   : (type) =>
        EdgeInsets.symmetric(
          horizontal : type == ScreenType.mobile ? 16 : 40,
          vertical   : 24,
        ),
        builder   : (screenType, size, axis) =>
        SingleChildScrollView(
          child :
          Column(
            crossAxisAlignment : CrossAxisAlignment.stretch,
            children : [
              _Header(
                screenType : screenType,
                axis : axis,
              ),
              const SizedBox(height: 8),
              const _TextSection(),
              _ButtonSection(onToast: _toast),
              _FieldSection(
                name   : _name,
                email  : _email,
                amount : _amount,
              ),
              _DropdownSection(
                value     : _company,
                onChanged : (value) => setState(() => _company = value),
              ),
              _SwitchSection(
                first  : _switch,
                second : _switch2,
                onFirstChanged  : (value) => setState(() => _switch = value),
                onSecondChanged : (value) => setState(() => _switch2 = value),
              ),
              const _LayoutSection(),
              _AsyncSection(size: size),
              _SubMenuSection(onToast: _toast),
              _ErrorSection(
                throwError : _throwError,
                onToggle   : () => setState(() => _throwError = !_throwError),
              ),
              const _ExtensionsSection(),
              _DialogSection(
                controller : _dialogTitle,
                onToast    : _toast,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Header extends StatelessWidget {
  final ScreenType screenType;
  final AxisData   axis;

  const _Header({
    required this.screenType,
    required this.axis,
  });

  @override
  Widget build(BuildContext context) =>
  Column(
    crossAxisAlignment : CrossAxisAlignment.start,
    children : [
      NText.bold(
        text    : 'n_interface',
        size    : 28,
      ),
      const SizedBox(height: 4),
      NText(
        text    : 'A showcase of every widget exported from n_interface.dart',
        size    : 14,
        color   : context.textMutedColor,
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing    : 8,
        runSpacing : 8,
        children   : [
          _Chip(label: 'ScreenType.${screenType.name}'),
          _Chip(label: 'axis.main: ${axis.main.name}'),
          _Chip(label: 'axis.second: ${axis.second.name}'),
          _Chip(label: 'expand: ${axis.expand}'),
        ],
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) =>
  Container(
    padding    :
    const EdgeInsets.symmetric(
      horizontal : 10,
      vertical   : 5,
    ),
    decoration :
    BoxDecoration(
      color : context.mainSoftColor,
      borderRadius : BorderRadius.circular(20),
    ),
    child :
    NText(
      text    : label,
      size    : 11,
      color   : context.mainColor,
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _Section({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) =>
  Container(
    width : double.infinity,
    margin     : const EdgeInsets.only(bottom: 20),
    padding    : const EdgeInsets.all(16),
    decoration :
    BoxDecoration(
      color  : context.cardColor,
      borderRadius : BorderRadius.circular(14),
      border : Border.all(color: context.dividerColor),
    ),
    child :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        NText.bold(
          text    : title,
          size    : 15,
        ),
        const SizedBox(height: 2),
        NText(
          text    : subtitle,
          size    : 12,
          color   : context.textMutedColor,
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _TextSection extends StatelessWidget {
  const _TextSection();

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NText',
    subtitle : 'Theme-aware text with normal, bold and button variants.',
    child    :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        NText(
          text    : 'Normal text',
        ),
        const SizedBox(height: 6),
        NText.bold(
          text    : 'Bold text',
        ),
        const SizedBox(height: 6),
        NText.button(
          text    : 'Button-styled text',
        ),
        const SizedBox(height: 6),
        NText(
          text     : 'Ellipsized text long enough to overflow the available width',
          overflow : TextOverflow.ellipsis,
          maxLines : 1,
        ),
        const SizedBox(height: 6),
        NText(
          text    : 'Shadowed text',
          shadow  :
          const Shadow(
            color : Colors.black26,
            blurRadius : 4,
            offset     : Offset(1, 1),
          ),
        ),
      ],
    ),
  );
}

class _ButtonSection extends StatelessWidget {
  final ToastCallback onToast;

  const _ButtonSection({required this.onToast});

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NButton',
    subtitle : 'Primary, red, flat and white buttons with hover, loading and disabled states.',
    child    :
    Wrap(
      spacing    : 10,
      runSpacing : 10,
      crossAxisAlignment : WrapCrossAlignment.center,
      children   : [
        NButton(
          text  : 'Primary',
          onTap : () => onToast('Primary pressed'),
        ),
        NButton.red(
          text  : 'Delete',
          onTap : () => onToast('Delete pressed', isValid: false),
        ),
        NButton.flat(
          text  : 'Cancel',
          onTap : () => onToast('Cancel pressed'),
        ),
        NButton.white(
          text  : 'Selected',
          isSelected : true,
          onTap : () {},
        ),
        NButton(
          text  : 'Async',
          onTap : () async {
            await Future<void>.delayed(const Duration(milliseconds: 1200));
            if (context.mounted) onToast('Async action finished');
          },
        ),
        NButton(
          asset   : 'assets/add.png',
          tooltip : 'Add',
          onTap   : () => onToast('Icon button'),
        ),
        NTooltip(
          message : 'I am a tooltip',
          child   :
          NButton(
            text  : 'Hover me',
            onTap : () {},
          ),
        ),
        const NButton(
          text  : 'Disabled',
          onTap : null,
        ),
        NButton(
          text  : 'Read only',
          readOnlyTooltip : 'Not available right now',
          onTap : () {},
        ),
      ],
    ),
  );
}

class _FieldSection extends StatelessWidget {
  final NTextController name;
  final NTextController email;
  final NTextController amount;

  const _FieldSection({
    required this.name,
    required this.email,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NTextField',
    subtitle : 'Text fields with validation, input formatting and custom prefix/suffix actions.',
    child    :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        NTextField(
          title : 'Name',
          isRequired : true,
          hint  : 'Jane Doe',
          controller : name,
          width : 280,
        ),
        const SizedBox(height: 12),
        NTextField(
          title : 'Email',
          isRequired : true,
          hint  : 'jane@example.com',
          controller : email,
          type  : TextInputType.emailAddress,
          width : 280,
          prefix     :
          const TextFieldAction.prefix(icon: Icons.mail_outline),
        ),
        const SizedBox(height: 12),
        NTextField(
          title : 'Amount',
          hint  : '1 - 1000',
          controller : amount,
          type  : TextInputType.number,
          width : 280,
          suffix     :
          TextFieldAction.suffix(
            icon  : Icons.clear,
            onTap : amount.clear,
          ),
        ),
        const SizedBox(height: 16),
        NButton(
          text  : 'Validate all',
          onTap : () {
            name.validator?.validate();
            email.validator?.validate();
            amount.validator?.validate();
          },
        ),
      ],
    ),
  );
}

class _DropdownSection extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _DropdownSection({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NDropdown',
    subtitle : 'Overlay-based dropdown, with optional async loading on open.',
    child    :
    NDropdown<String>(
      title : 'Company',
      isRequired  : true,
      width : 280,
      text  : value,
      hint  : 'Pick a company',
      items : const ['n_interface', 'Flutter', 'Dart'],
      itemBuilder : (item, index) =>
      NText(
        text    : item,
      ),
      onSelection : (item, index) => onChanged(item),
    ),
  );
}

class _SwitchSection extends StatelessWidget {
  final bool first;
  final bool second;
  final ValueChanged<bool> onFirstChanged;
  final ValueChanged<bool> onSecondChanged;

  const _SwitchSection({
    required this.first,
    required this.second,
    required this.onFirstChanged,
    required this.onSecondChanged,
  });

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NSwitcher',
    subtitle : 'Dual-state toggle with optional icons, labels and divider.',
    child    :
    Column(
      children : [
        NSwitcher(
          detail    : 'Enable notifications',
          value     : first,
          icons     : const [Icons.notifications_off_outlined, Icons.notifications_active],
          onChanged : onFirstChanged,
        ),
        const SizedBox(height: 12),
        NSwitcher(
          divider   : true,
          value     : second,
          texts     : const ['Off', 'On'],
          onChanged : onSecondChanged,
        ),
      ],
    ),
  );
}

class _LayoutSection extends StatelessWidget {
  const _LayoutSection();

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NAxisLayout / NFlexibleBox',
    subtitle : 'Axis switching layouts and expand/collapse flex helpers.',
    child    :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        NAxisLayout(
          axis  : Axis.horizontal,
          title : 'Axis layout',
          isRequired : true,
          action     :
          NText(
            text    : '(action)',
            size    : 11,
          ),
          child :
          NText(
            text    : 'Horizontal content',
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height : 40,
          child  :
          Row(
            children : [
              NFlexibleBox(
                expandWhen : true,
                child :
                Container(
                  color     : context.mainSoftColor,
                  alignment : Alignment.center,
                  child     :
                  NText(
                    text    : 'expandWhen: true',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              NFlexibleBox(
                expandWhen : false,
                width : 90,
                child :
                Container(
                  color     : context.mainColor,
                  alignment : Alignment.center,
                  child     :
                  NText(
                    text    : 'Fixed',
                    color   : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _AsyncSection extends StatelessWidget {
  final BoxConstraints size;

  const _AsyncSection({required this.size});

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NAsyncLoader',
    subtitle : 'Shows an indicator while an async task runs (this one takes 800ms).',
    child    :
    NAsyncLoader(
      onLoading  : () async =>
        await Future<void>.delayed(const Duration(milliseconds: 800)),
      onFinished : () => debugPrint('Async loader finished'),
      child :
      Container(
        width : double.infinity,
        padding    : const EdgeInsets.all(16),
        decoration :
        BoxDecoration(
          color : context.mainSoftColor,
          borderRadius : BorderRadius.circular(10),
        ),
        child :
        NText(
          text    : 'Loaded in ${size.maxWidth.toStringAsFixed(0)}px width container.',
        ),
      ),
    ),
  );
}

class _SubMenuSection extends StatelessWidget {
  final ToastCallback onToast;

  const _SubMenuSection({required this.onToast});

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NSubMenu',
    subtitle : 'Contextual overlay menu anchored to an asset trigger.',
    child    :
    Row(
      children : [
        NSubMenu(
          asset     : 'assets/menu.png',
          alignment : NSubMenuAlignment.bottomRight,
          items     : [
            NSubMenuItem(
              text  : 'Edit',
              onTap : () => onToast('Edit'),
            ),
            NSubMenuItem(
              text  : 'Duplicate',
              onTap : () => onToast('Duplicate'),
            ),
            NSubMenuItem(
              text  : 'Delete',
              color : context.errorColor,
              onTap : () => onToast('Delete', isValid: false),
            ),
          ],
        ),
        const SizedBox(width: 12),
        NText(
          text    : 'Tap the icon to open the menu',
          size    : 12,
        ),
      ],
    ),
  );
}

class _ErrorSection extends StatelessWidget {
  final bool throwError;
  final VoidCallback onToggle;

  const _ErrorSection({
    required this.throwError,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'NErrorHandler',
    subtitle : 'Catches build-time exceptions and renders a fallback.',
    child    :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        NErrorHandler(
          builder : (context) {
            if (throwError) throw StateError('Simulated build error');
            return NText(
              text    : 'This child builds successfully.',
            );
          },
          onError : (context, error, stackTrace) =>
          Row(
            children : [
              const Icon(
                Icons.error_outline,
                color : Colors.red,
                size  : 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child :
                NText(
                  text    : 'Recovered from error: $error',
                  color   : context.errorColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NButton.flat(
          text  : throwError ? 'Recover' : 'Simulate error',
          onTap : onToggle,
        ),
      ],
    ),
  );
}

class _ExtensionsSection extends StatelessWidget {
  const _ExtensionsSection();

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'Extensions',
    subtitle : 'ContextExtension, DateTimeExtension, DurationExtension, List/Map/String helpers.',
    child    :
    Column(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        _KeyValueRow(
          label : 'context.mainColor',
          value : context.mainColor.toString(),
        ),
        _KeyValueRow(
          label : 'DateTime.now().formatWithTime',
          value : DateTime.now().formatWithTime,
        ),
        _KeyValueRow(
          label : 'DateTime.now().eeeeddMMMM',
          value : DateTime.now().eeeeddMMMM,
        ),
        _KeyValueRow(
          label : 'DateTime.now().hHmm',
          value : DateTime.now().hHmm,
        ),
        _KeyValueRow(
          label : '[4, 9, 2].getMax',
          value : '${[4, 9, 2].getMax}',
        ),
        _KeyValueRow(
          label : 'Duration(hours: 2, minutes: 5).format',
          value :
          const Duration(
            hours   : 2,
            minutes : 5,
          ).format,
        ),
        _KeyValueRow(
          label : '"" .clearString()',
          value : '${''.clearString()}',
        ),
        _KeyValueRow(
          label : '{"a": ""}.clearEmpty()',
          value : '${({'a': '', 'b': 'x'}).clearEmpty()}',
        ),
      ],
    ),
  );
}

class _KeyValueRow extends StatelessWidget {
  final String label;
  final String value;

  const _KeyValueRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) =>
  Padding(
    padding : const EdgeInsets.symmetric(vertical: 3),
    child   :
    Row(
      crossAxisAlignment : CrossAxisAlignment.start,
      children : [
        SizedBox(
          width : 260,
          child :
          NText.bold(
            text    : label,
            size    : 12,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child :
          NText(
            text    : value,
            size    : 12,
            color   : context.textMutedColor,
          ),
        ),
      ],
    ),
  );
}

class _DialogSection extends StatelessWidget {
  final NTextController controller;
  final ToastCallback   onToast;

  const _DialogSection({
    required this.controller,
    required this.onToast,
  });

  @override
  Widget build(BuildContext context) =>
  _Section(
    title    : 'CreateDialog / NToast',
    subtitle : 'Responsive modal route plus success/error toasts.',
    child    :
    Wrap(
      spacing    : 10,
      runSpacing : 10,
      children   : [
        NButton(
          text  : 'Open dialog',
          onTap : () {
            CreateDialog.make(
              context,
              title : 'Create record',
              maxWidth    : 460,
              onDismissed : () => debugPrint('Dialog dismissed'),
              child :
              _CreateRecordDialog(
                controller : controller,
                onConfirm  : () => onToast('Record created'),
              ),
            );
          },
        ),
        NButton.white(
          text  : 'Success toast',
          onTap : () => onToast('Saved successfully'),
        ),
        NButton.white(
          text  : 'Center error toast',
          onTap : () => onToast('Something failed',
            isValid : false,
            center  : true,
          ),
        ),
      ],
    ),
  );
}

class _CreateRecordDialog extends StatelessWidget {
  final NTextController controller;
  final VoidCallback    onConfirm;

  const _CreateRecordDialog({
    required this.controller,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) =>
  Padding(
    padding : const EdgeInsets.all(16),
    child   :
    Column(
      mainAxisSize : MainAxisSize.min,
      crossAxisAlignment : CrossAxisAlignment.stretch,
      children     : [
        NText(
          text    : 'Dialog content is fully themed and responsive. On mobile it opens '
              'as a drag-to-dismiss bottom sheet.',
          size    : 13,
        ),
        const SizedBox(height: 16),
        NTextField(
          title : 'Record name',
          hint  : 'e.g. Invoice #1',
          controller : controller,
        ),
        const SizedBox(height: 20),
        Row(
          children : [
            NFlexibleBox(
              expandWhen : true,
              child :
              NButton(
                text  : 'Create',
                onTap : () {
                  context.pop();
                  onConfirm();
                },
              ),
            ),
            const SizedBox(width: 8),
            NButton.flat(
              text  : 'Cancel',
              onTap : () => context.pop(),
            ),
          ],
        ),
      ],
    ),
  );
}
