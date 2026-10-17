# n_interface

A personal collection of **Flutter widgets, helpers and extensions** for building
responsive, theme-aware interfaces with a consistent look and feel.

Every public API is exported from a single entry point:

```dart
import 'package:n_interface/n_interface_helper.dart';
```

## Table of contents

- [Installation](#installation)
- [Widgets](#widgets)
  - [NText](#ntext)
  - [NButton](#nbutton)
  - [NTextField](#ntextfield)
  - [NDropdown](#ndropdown)
  - [NAxisLayout](#naxislayout)
  - [NFlexibleBox](#nflexiblebox)
  - [NResponsiveBuilder](#nresponsivebuilder)
  - [NAsyncLoader](#nasyncloader)
  - [NSwitcher](#nswitcher)
  - [NTooltip](#ntooltip)
  - [NSubMenu](#nsubmenu)
  - [NErrorHandler](#nerrorhandler)
  - [CreateDialog](#createdialog)
  - [NToast](#ntoast)
- [Enums & data classes](#enums--data-classes)
- [Extensions](#extensions)
- [License](#license)

## Installation

Add the package to your `pubspec.yaml` dependencies (path or git, depending on how
you consume it):

```yaml
dependencies:
  n_interface:
    path: ../n_interface
```

Then run:

```bash
flutter pub get
```

Requires Flutter `>=3.3.0` and Dart SDK `^3.13.2`.

---

## Widgets

### NText

A `Text` wrapper that pulls its color from the current theme and exposes the most
common typographic options.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `context` | `BuildContext` | required | Used to resolve theme colors. |
| `text` | `String` | required | The text to display. |
| `size` | `double` | `12` | Font size. |
| `weight` | `FontWeight` | `w400` | Font weight. |
| `color` | `Color?` | `null` | Overrides the theme color. |
| `align` | `TextAlign?` | `null` | Text alignment. |
| `overflow` | `TextOverflow?` | `null` | Overflow behavior. |
| `maxLines` | `int?` | `null` | Maximum number of lines. |
| `margin` | `EdgeInsetsGeometry?` | `null` | Outer padding. |
| `shadow` | `Shadow?` | `null` | Text shadow. |
| `style` | `FontStyle?` | `null` | Italic/oblique style. |
| `decoration` | `TextDecoration?` | `null` | Underline, line-through, etc. |

Named constructors: `NText.bold` (emphasized theme color), `NText.button` (uses the
main brand color).

```dart
NText(context: context, text: 'Total', size: 14)
NText.bold(context: context, text: 'Amount')
NText.button(context: context, text: 'Brand-colored label')
```

### NButton

A theme-aware button with hover, loading, disabled and selected states, plus
optional icon assets.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `onTap` | `FutureOr<void> Function()?` | `null` | Tap handler. `null` disables the button. |
| `text` | `String` | `""` | Button label. |
| `asset` / `overAsset` / `disableAsset` / `selectedAsset` | `String?` | `null` | Icon assets per state. |
| `tooltip` | `String?` | `null` | Tooltip message. |
| `readOnlyTooltip` | `String?` | `null` | Non-null makes the button read-only and shows this on hover. |
| `isSelected` | `bool` | `false` | Selected decoration (`white` variant). |
| `turned` | `bool` | `false` | Puts the icon after the text. |
| `size` | `double` | `12` | Text/icon size. |
| `width` / `height` | `double?` | `null` | Fixed dimensions. |
| `margin` / `padding` | `EdgeInsetsGeometry?` | `null` | Spacing. |
| `showBorder` | `bool` | `true` | Draws the border. |
| `shadow` | `bool` | `true` | Draws the drop shadow. |
| `textAlign` / `textOverflow` | — | `null` | Text layout. |

Named constructors: `NButton` (primary), `NButton.red` (destructive),
`NButton.flat` (text-only), `NButton.white` (outlined / selectable).

```dart
NButton(
  text: 'Save',
  onTap: () async => await repository.save(),
  tooltip: 'Persist changes',
)

NButton.red(text: 'Delete', onTap: () => delete())
NButton.flat(text: 'Cancel', onTap: () => close())
NButton.white(text: 'Filter', isSelected: true, onTap: () {})
```

### NTextField

A form text field built on `NAxisLayout`, backed by `TextFormField` and a
`NTextController`. Handles validation, input formatting and loading actions.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `title` | `String?` | `null` | Field label. |
| `controller` | `NTextController?` | `null` | Text + focus + validator holder. |
| `isRequired` | `bool` | `false` | Marks the field required (adds `*`). |
| `hint` | `String?` | `null` | Placeholder text. |
| `type` | `TextInputType?` | `null` | Keyboard type; `number`/`datetime` apply formatters. |
| `enable` / `readOnly` / `obscureText` | `bool` | `false` | Field state. |
| `maxLines` / `minLines` / `maxLength` | `int?` | `1` / `1` / `null` | Sizing. |
| `hasError` | `bool` | `false` | Forces the red error border. |
| `showLength` | `bool` | `false` | Shows the character counter. |
| `suffix` / `prefix` | `TextFieldAction?` | default icons | Trailing/leading actions. |
| `onChanged` | `ValueChanged<String>?` | `null` | Change callback. |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Extra formatters. |

Related classes:

- `NTextController` — `TextEditingController` extension with `focusNode`, `validator`
  and `focus(context)`.
- `TextFieldValidator` — named constructors: `.email`, `.number`, `.notEmpty`,
  `.dateTime`, `.coords`, `.phonenumber`, `.onlytextspaces`,
  `.onlytextwithoutspaces`, `.alphanumericwithoutexpressions`, `.maximum`,
  `.rangeMinMax`, `.pattern`, `.regExp`, `.numbersAndLetters`, `.length`,
  `.rangeLength`, `.range`.
- `TextFieldAction.prefix` / `TextFieldAction.suffix` — leading/trailing action with
  `asset`, `icon`, `text`, `onTap` and loading support.
- `CustomNumberFormatter` — `TextInputFormatter` that only accepts a `RegExp`.
- `Patterns` — ready-made regex presets (`email`, `dotNumber`, `fiatFormat`,
  `cryptoFormat`, `phonenumber`, `dateTime`, `coords`, …).

```dart
final _email = NTextController(
  validator: TextFieldValidator.email(
    key: GlobalKey<FormState>(),
    error: 'Invalid email',
  ),
);

NTextField(
  title: 'Email',
  isRequired: true,
  hint: 'you@example.com',
  controller: _email,
  type: TextInputType.emailAddress,
  onChanged: (value) {},
)
```

### NDropdown

A themed, overlay-based dropdown that extends `NAxisLayout`. It can be a plain
`String` list or a fully custom menu, and supports async loading.

```dart
NDropdown<String>(
  context: context,
  title: 'Country',
  isRequired: true,
  items: const ['Spain', 'France', 'Germany'],
  onSelection: (item, index) => print('$item ($index)'),
  itemBuilder: (item, index) => NText(context: context, text: item),
)
```

Key options: `arrow`, `hint`, `error` / `errorText`, `enable`, `readOnly`,
`menuWidth`, `menuMaxHeight`, `menuButton`, `headerDecoration`, `controller`,
`onLoading`, `onFinished`, `onChanged`.

`NDropdownScope` is an `InheritedWidget` that exposes a `close()` callback so custom
menu content can dismiss the dropdown.

### NAxisLayout

A labeled layout primitive that renders as a `Column` or `Row` depending on `axis`.
Ideal for form rows where a title sits next to a field.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `axis` | `Axis` | required | `vertical` → `Column`, `horizontal` → `Row`. |
| `child` | `Widget` | required | Main content. |
| `title` | `String?` | `null` | Optional label. |
| `action` | `Widget?` | `null` | Widget next to the title / child. |
| `isRequired` | `bool` | `false` | Prepends a `*`. |
| `width` / `height` | `double?` | `null` | Content size. |
| `alignment` | `Alignment?` | `null` | Content alignment. |
| `overflow` | `TextOverflow?` | `.clip` | Title overflow. |
| `margin` | `EdgeInsetsGeometry?` | `.zero` | Outer margin. |

### NFlexibleBox

A widget that behaves like `Expanded` when `expandWhen` is `true`, and like a
loose `Flexible` (shrinks to its child) when `false`.

```dart
Row(
  children: [
    NFlexibleBox(expandWhen: true, child: input),
    NFlexibleBox(expandWhen: false, width: 80, child: button),
  ],
)
```

### NResponsiveBuilder

Builds a layout from the available size, exposing the `ScreenType` (mobile,
tablet, desktop) and an `AxisData` describing the main/secondary axis. It is
wrapped in an `NAsyncLoader`, so it can run async work before the first frame.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `builder` | `Widget Function(ScreenType, BoxConstraints, AxisData)` | required | Main builder. |
| `breakSize` | `double` | `650` | Breakpoint: below → vertical, above → horizontal. |
| `padding` | `EdgeInsetsGeometry Function(ScreenType)?` | `null` | Dynamic padding. |
| `onLoading` / `onFinished` / `indicator` | — | `null` | Loading hooks. |

`AxisData` fields: `main` (`Axis`), `second` (`Axis`), `expand` (`bool`).

```dart
NResponsiveBuilder(
  onLoading: () async => await loadData(),
  builder: (screenType, size, axis) =>
    Flex(
      direction: axis.main,
      children: const [Sidebar(), Content()],
    ),
)
```

### NAsyncLoader

A stateful wrapper that renders `child`, swaps in `indicator` while an async
operation is running, and fires `onLoading` once on mount and `onTap` on tap.

| Property | Type | Description |
| --- | --- | --- |
| `child` | `Widget` | Shown when idle. |
| `indicator` | `Widget?` | Shown while loading (defaults to a small spinner). |
| `onLoading` | `Future<void> Function()?` | Runs once when mounted. |
| `onTap` | `FutureOr<void> Function()?` | Runs on tap; enables the click cursor. |
| `onFinished` | `Function()?` | Called after any async work completes. |
| `onEnter` / `onExit` | `PointerEnter/ExitEventListener?` | Hover callbacks. |

### NSwitcher

A dual-state toggle switch (built on `animated_toggle_switch`) with optional icons,
labels, a detail text and an optional bottom divider.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `bool` | required | Current state. |
| `onChanged` | `Function(bool)?` | `null` | Change callback; `null` disables. |
| `detail` | `String?` | `null` | Label shown to the left. |
| `icons` / `texts` | `List<IconData>` / `List<String>` | `[]` | Two entries for thumb content. |
| `height` | `double` | `30` | Switch height. |
| `divider` | `bool` | `false` | Draws a bottom divider. |
| `animate` | `bool` | `true` | Animated transitions. |
| `indicatorColor` | `Color?` | `null` | Fixed thumb color (both states). |

### NTooltip

Wraps a child and shows a themed tooltip. Returns the child unchanged when
`message` is empty.

```dart
NTooltip(
  message: 'Refresh',
  child: Icon(Icons.refresh),
)
```

### NSubMenu

A contextual submenu opened in an `Overlay`, anchored to an icon/asset trigger.
Configure the opening direction with `NSubMenuAlignment`
(`topLeft`, `topRight`, `bottomLeft`, `bottomRight`).

```dart
NSubMenu(
  asset: 'assets/more.png',
  alignment: NSubMenuAlignment.bottomRight,
  items: [
    NSubMenuItem(text: 'Edit', onTap: () {}),
    NSubMenuItem(text: 'Delete', color: Colors.red, onTap: () {}),
  ],
)
```

`NSubMenuItem` fields: `asset`, `text`, `color`, `tooltip`, `onTap`.

### NErrorHandler

Catches build-time exceptions from its `builder` and renders an `onError` widget
(or a red error text by default).

```dart
NErrorHandler(
  builder: (context) => NText(context: context, text: riskyValue),
  onError: (context, error, stack) =>
    NText(context: context, text: 'Something went wrong'),
)
```

### CreateDialog

A static helper that pushes a responsive modal route: centered on desktop, a
drag-to-dismiss bottom sheet on mobile, with a blurred veil behind it.

```dart
CreateDialog.make(
  context,
  title: 'Confirm',
  onLoading: () async => await fetchDetails(),
  onDismissed: () => print('closed'),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [ /* content */ ],
  ),
);
```

Options: `title`, `child` (required), `onLoading`, `onDismissed`, `maxWidth`
(default `600`), `theme`.

### NToast

A static helper that shows a toast via `flutter_styled_toast` — green for success,
red for failure, either at the bottom (slide) or centered (fade).

```dart
NToast.show(context, message: 'Saved successfully');
NToast.show(context, message: 'Operation failed', isValid: false, center: true);
```

---

## Enums & data classes

| Type | Values / Fields | Description |
| --- | --- | --- |
| `ScreenType` | `mobile`, `tablet`, `desktop` | Size category of the current viewport. |
| `AxisData` | `main`, `second`, `expand` | Axis configuration produced by `NResponsiveBuilder`. |
| `NSubMenuAlignment` | `topLeft`, `topRight`, `bottomLeft`, `bottomRight` | Submenu anchor direction. |
| `NSubMenuItem` | `asset`, `text`, `color`, `tooltip`, `onTap` | Single submenu entry. |

---

## Extensions

All extensions are exported from the same entry point and are available as soon
as you import the library.

| Extension | On | Highlights |
| --- | --- | --- |
| `ContextExtension` | `BuildContext` | `topSize`, `bottomSize`, `pop()`, and theme getters: `primaryColor`, `textColor`, `mainColor`, `successColor`, `errorColor`, `dividerColor`, `cardColor`, `backgroundColor`, `disabledColor`, `overedColor`, `borderColor`, `greyCard`, … |
| `ScreenTypeExtension` | `BoxConstraints` | `getScreenType` → `ScreenType` from `maxWidth`. |
| `DateTimeExtension` | `DateTime` | `isEarlier`, `isToday`, `format` (`dd/MM/yyyy`), `formatWithTime`, `iso8601CalendarDate`, `eee` / `eeeeddMMMM` / `mMMMyyyy` locale formats, `hhMM`, `hHmm`, `paseOrNull`. |
| `DurationExtension` | `Duration` | `format` (`HH:mm`), `parseOrNull`. |
| `ListExtension<E>` | `List<E>` | `singleWhereOrNull`, `removeEmpty`. |
| `ListNumExtension<T extends num>` | `List<T>` | `getMin`, `getMax` (0 when empty). |
| `MapDynamicExtension` | `Map<String, dynamic>` | `clearEmpty` (drops nulls, empties and audit keys). |
| `MapStringExtension` | `Map<String, String>` | `clearEmpty`. |
| `NumExtension` | `num` | `clearString()` (0 → `null`). |
| `StringExtension` | `String` | `clearString()` (`"0"`, `"0.00"`, `""` → `null`). |

```dart
final max = [1.5, 9.2, 3.0].getMax;               // 9.2
final nice = DateTime.now().formatWithTime;        // e.g. 17/10/2026 09:30
final color = context.mainColor;                   // theme primary
final id = ''.clearString();                       // null
```

---

## License

See [LICENSE](LICENSE).
