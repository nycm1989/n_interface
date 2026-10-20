# CLAUDE.md

Project rules for working on the `n_interface` repository.
Each rule is mandatory unless explicitly stated otherwise.

## 1. Build widgets as classes, never as methods

Do **not** create widgets through helper methods or functions that return a
`Widget`.

```dart
// ❌ Wrong
Widget _extensionsSection(BuildContext context) => Column(...);

// ❌ Wrong
final section = _buildSection();
```

Always extract the UI into its own `StatelessWidget` or `StatefulWidget` class.

```dart
// ✅ Correct
class ExtensionsSection extends StatelessWidget {
  const ExtensionsSection({super.key});

  @override
  Widget build(BuildContext context) =>
  Column(...);
}
```

Reasons:

- Keeps `build` methods small and readable.
- Enables independent rebuilds, const constructors and easier testing.
- Makes passing data explicit through constructor parameters instead of closures.

## 2. Arrow expressions put the widget on the next line

When a widget is the value of an arrow expression (`=>`), it must start on the
**following** line, never on the same line.

```dart
// ❌ Wrong
Widget build(BuildContext context) => _Section(...);

// ✅ Correct
Widget build(BuildContext context) =>
_Section(...);
```

## 3. Named arguments put the widget on the next line

When a widget is passed as a named argument, it must start on the **following**
line, never on the same line. This applies recursively to nested widgets.

```dart
// ❌ Wrong
Container(
  child: SizedBox(),
)

// ✅ Correct
Container(
  child:
  SizedBox(),
)
```

```dart
// ❌ Wrong
Expanded(child: NText(context: context, text: 'Hi'))

// ✅ Correct
Expanded(
  child:
  NText(
    context : context,
    text    : 'Hi',
  ),
)
```

## 4. One property per line

When a widget has more than one property, each property goes on its own line
instead of a single line. Single-property widgets may stay on one line.

This also applies to classes in general, including every `StatelessWidget` and
`StatefulWidget` constructor (their `required this.x` / `this.x` parameters must
each go on their own line too).

```dart
// ❌ Wrong
NButton(text: 'Primary', onTap: () => onToast('Primary pressed')),

// ✅ Correct
NButton(
  text  : 'Primary',
  onTap : () => onToast('Primary pressed'),
),
```

```dart
// ❌ Wrong
const _DropdownSection({required this.value, required this.onChanged});

// ✅ Correct
const _DropdownSection({
  required this.value,
  required this.onChanged,
});
```

## 5. Multi-property classes also start on the next line

If the value of a property (named argument or arrow expression) is a class that
has more than one property, that class must also start on the **following**
line, even when it is not a widget.

```dart
// ❌ Wrong
padding: (type) => EdgeInsets.symmetric(
  horizontal: type == NScreenType.mobile ? 16 : 40,
  vertical: 24,
),

// ✅ Correct
padding: (type) =>
EdgeInsets.symmetric(
  horizontal : type == NScreenType.mobile ? 16 : 40,
  vertical   : 24,
),
```

```dart
// ❌ Wrong
decoration: BoxDecoration(
  color: context.cardColor,
  borderRadius: BorderRadius.circular(14),
),

// ✅ Correct
decoration:
BoxDecoration(
  color        : context.cardColor,
  borderRadius : BorderRadius.circular(14),
),
```

## 6. No methods for single-use logic, and no methods outside classes

Do **not** create a method (or a top-level function) when its logic runs in a
single place. Inline the logic at the call site instead.

Also, never declare methods or functions outside of a widget or a class.

```dart
// ❌ Wrong: method used only once
void _openDialog() { ... }
...
NButton(onTap: _openDialog)

// ✅ Correct: logic inlined at the call site
NButton(
  onTap: () {
    ...
  },
)
```

```dart
// ❌ Wrong: function outside a class
void showSuccess() => NToast.show(...);

// ✅ Correct: put it inside the widget/class that uses it
class MyPage extends StatelessWidget {
  void _showSuccess() => NToast.show(...);
  ...
}
```

## 7. Methods follow the same rule

The same rule applies to every method (declarations and calls), not only widgets:
when a method has **more than two** parameters/arguments, each one goes on its
own line, including named parameters/arguments. The positional parameters stay
on the opening line; the named ones are listed below.

```dart
// ❌ Wrong
void _toast(String message, {bool isValid = true, bool center = false}) =>
    NToast.show(context, message: message, isValid: isValid, center: center);

// ✅ Correct
void _toast(String message, {
  bool isValid = true,
  bool center  = false,
}) =>
NToast.show(context,
  message : message,
  isValid : isValid,
  center  : center,
);
```

## 8. Align properties and values with whitespace

Every property and value of a class or method must be aligned using whitespace
(tabs or spaces) in declarations, assignments and injections. Inside each
contiguous group (same indentation), pad each line so that its separator
(`:` or `=`) — or the start of the name in a declaration — lines up with the
widest entry of the group. This includes typed constructor parameters, where the
type is padded so every parameter name starts on the same column (see rule 11).

```dart
// ❌ Wrong
class NSwitcher extends StatelessWidget {
  final bool value;
  final bool divider;
  final bool animate;
  final String? detail;
  final double height;

// ✅ Correct
class NSwitcher extends StatelessWidget {
  final bool    value;
  final bool    divider;
  final bool    animate;
  final String? detail;
  final double  height;
```

```dart
// ❌ Wrong
const NSwitcher({
  this.margin,
  this.icons = const [],
  this.texts = const [],
  this.divider = false,
  this.animate = true,
  this.height = 30,
  super.key
});

// ✅ Correct
const NSwitcher({
  this.margin,
  this.icons   = const [],
  this.texts   = const [],
  this.divider = false,
  this.animate = true,
  this.height  = 30,
  super.key
});
```

```dart
// ❌ Wrong
NToast.show(context,
  message: message,
  isValid: isValid,
  center: center,
);

// ✅ Correct
NToast.show(context,
  message : message,
  isValid : isValid,
  center  : center,
);
```

## 9. Do not justify code to an imaginary maximum width

When aligning (rule 8), never pad lines up to the widest possible column. If a
group mixes entries of very different lengths, split it so a single long entry
does not stretch the others with large gaps, which overlap and turn the code
into unreadable tangles.

Keep the alignment compact: the extra padding must stay small (a few spaces).
Entries that would need a bigger gap form their own group.

```dart
// ❌ Wrong: the long name stretches every other line
theme                      : ThemeData(),
debugShowCheckedModeBanner : false,
home                       : const DemoPage(),

// ✅ Correct: the long name does not stretch the others
theme : ThemeData(),
debugShowCheckedModeBanner : false,
home  : const DemoPage(),
```

## 10. Declarations and injections must state their type

Every declaration (and injection) must state its explicit type. Never rely on
type inference (`final x = ...`, `var x = ...`, untyped `const x = ...`).

```dart
// ❌ Wrong
final _dialogTitle = NTextController();

// ✅ Correct
final NTextController _dialogTitle = NTextController();
```

## 11. Align constructor parameter types and names

Following rule 8, in a constructor that declares typed parameters (not
`this.x`), the type must be padded with whitespace so that every parameter name
starts in a straight line, at the column of the **longest type** in the group.

```dart
// ❌ Wrong
NDropdown({
  NTextController? controller,
  ValueChanged<String>? onChanged,
  Future<void> Function()? onLoading,
  Function()? onFinished,
});

// ✅ Correct
NDropdown({
  NTextController?         controller,
  ValueChanged<String>?    onChanged,
  Future<void> Function()? onLoading,
  Function()?              onFinished,
});
```

## 12. Use `Row`/`Column` `spacing` instead of intermediate `SizedBox`

`Row` and `Column` already expose a `spacing` property. Use it to separate
children instead of inserting `SizedBox` widgets (or `Padding`) between them.
Only keep a `SizedBox` when the gap is irregular (a different size between
specific children) or when it is not a gap (e.g. `Expanded(child: SizedBox(...))`).

```dart
// ❌ Wrong
Column(
  children: [
    const NText(text: 'One'),
    const SizedBox(height: 12),
    const NText(text: 'Two'),
  ],
)

// ✅ Correct
Column(
  spacing : 12,
  children: [
    const NText(text: 'One'),
    const NText(text: 'Two'),
  ],
)
```

```dart
// ❌ Wrong
Row(
  children: [
    const NText(text: 'One'),
    const SizedBox(width: 8),
    const NText(text: 'Two'),
  ],
)

// ✅ Correct
Row(
  spacing : 8,
  children: [
    const NText(text: 'One'),
    const NText(text: 'Two'),
  ],
)
```

## 13. Use `Color.withValues` instead of `Color.withOpacity`

`Color.withOpacity` is deprecated and no longer works as expected. To change a
color's alpha, use `Color.withValues(alpha: ...)` instead. The alpha is a
`double` between `0.0` and `1.0`, and the same applies to `Colors` constants.

```dart
// ❌ Wrong
Colors.black.withOpacity(0.1);
color.withOpacity(0.5);

// ✅ Correct
Colors.black.withValues(alpha: 0.1);
color.withValues(alpha: 0.5);
```
