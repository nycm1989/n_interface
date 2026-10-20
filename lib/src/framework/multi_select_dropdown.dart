import 'package:flutter/material.dart' show BoxConstraints, BuildContext, Column, ConstrainedBox, EdgeInsets, Expanded, FontWeight, Icons, InkWell, ListView, MainAxisSize, Padding, Row, ScrollController, Scrollbar, SizedBox, State, StatefulWidget, StatelessWidget, TextOverflow, ValueChanged, VoidCallback, Widget;
import 'package:n_interface/n_interface.dart' show NTextFieldAction, NTextController, NDropdown, NTextField, ContextExtension, NText;
import 'package:n_interface/src/framework/check.dart' show NCheck;

/// Dropdown reutilizable que conserva el aspecto de [NDropdown] y permite
/// seleccionar cualquier cantidad de elementos sin cerrar el menú.
class NMultiSelectDropdown<T> extends StatefulWidget {
  final BuildContext                   context;
  final List<T>                        items;
  final List<T>                        selectedItems;
  final Object Function(T item)        itemKeyBuilder;
  final String Function(T item)        itemLabelBuilder;
  final String Function(List<T> items) selectionTextBuilder;
  final ValueChanged<List<T>>          onSelectionChanged;
  final String                       ? title;
  final String                       ? hint;
  final String                         searchHint;
  final String                         emptyText;
  final String                         clearText;
  final bool                           enable;
  final double                       ? menuWidth;
  final double                         menuMaxHeight;
  final NTextFieldAction              ? prefix;
  final NTextFieldAction              ? suffix;

  const NMultiSelectDropdown({
    super.key,
    required this.context,
    required this.items,
    required this.selectedItems,
    required this.itemKeyBuilder,
    required this.itemLabelBuilder,
    required this.selectionTextBuilder,
    required this.onSelectionChanged,
    required this.searchHint,
    required this.emptyText,
    required this.clearText,
    this.title,
    this.hint,
    this.enable        = true,
    this.menuWidth,
    this.menuMaxHeight = 250,
    this.prefix,
    this.suffix,
  });

  @override
  State<NMultiSelectDropdown<T>> createState() => _NMultiSelectDropdownState<T>();
}

class _NMultiSelectDropdownState<T> extends State<NMultiSelectDropdown<T>> {
  final NTextController _searchController = NTextController();
  final ScrollController    _scrollController = ScrollController();
  String                    _query            = '';

  /// Elementos cuyo texto coincide con la búsqueda.
  List<T> get _filteredItems => widget.items
    .where((T item) => widget.itemLabelBuilder(item).trim().toLowerCase().contains(_query.trim().toLowerCase()))
    .toList(growable: false);

  /// La comparación es por clave, no por instancia: la lista de origen puede recargarse.
  bool _isSelected(T item) => widget.selectedItems.any((T selected) => widget.itemKeyBuilder(selected) == widget.itemKeyBuilder(item));

  /// Entrega al consumidor una lista nueva e inmutable con [item] alternado.
  void _toggle(T item) => widget.onSelectionChanged(List<T>.unmodifiable(<T>[
    ...widget.selectedItems.where((T selected) => widget.itemKeyBuilder(selected) != widget.itemKeyBuilder(item)),
    if (!_isSelected(item)) item,
  ]));

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
  NDropdown<T>(
    title         : widget.title,
    hint          : widget.hint,
    text          : widget.selectionTextBuilder(widget.selectedItems),
    enable        : widget.enable,
    menuWidth     : widget.menuWidth,
    menuMaxHeight : widget.menuMaxHeight,
    prefix        : widget.prefix,
    suffix        : widget.suffix,
    child         :
    _MultiSelectMenu(
      width             : widget.menuWidth,
      searchHint        : widget.searchHint,
      searchController  : _searchController,
      onSearchChanged   : (String value) => setState(() => _query = value),
      clearText         : widget.clearText,
      hasSelection      : widget.selectedItems.isNotEmpty,
      onClear           : () => widget.onSelectionChanged(<T>[]),
      emptyText         : widget.emptyText,
      maxHeight         : widget.menuMaxHeight,
      scrollController  : _scrollController,
      count             : _filteredItems.length,
      labelOf           : (int index) => widget.itemLabelBuilder(_filteredItems[index]),
      isSelected        : (int index) => _isSelected(_filteredItems[index]),
      onToggle          : (int index) => _toggle(_filteredItems[index]),
    ),
  );
}

/// Buscador, acción de limpiar y lista de opciones del menú.
class _MultiSelectMenu extends StatelessWidget {
  final double                     ? width;
  final String                       searchHint;
  final NTextController          searchController;
  final ValueChanged<String>         onSearchChanged;
  final String                       clearText;
  final bool                         hasSelection;
  final VoidCallback                 onClear;
  final String                       emptyText;
  final double                       maxHeight;
  final ScrollController             scrollController;
  final int                          count;
  final String Function(int index)   labelOf;
  final bool   Function(int index)   isSelected;
  final void   Function(int index)   onToggle;

  const _MultiSelectMenu({
    required this.width,
    required this.searchHint,
    required this.searchController,
    required this.onSearchChanged,
    required this.clearText,
    required this.hasSelection,
    required this.onClear,
    required this.emptyText,
    required this.maxHeight,
    required this.scrollController,
    required this.count,
    required this.labelOf,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) =>
  SizedBox(
    width : width,
    child :
    Column(
      mainAxisSize: MainAxisSize.min,
      children    : [
        Padding(
          padding : const EdgeInsets.all(10),
          child   :
          NTextField(
            controller: searchController,
            hint      : searchHint,
            prefix    : const NTextFieldAction.prefix(icon: Icons.search),
            onChanged : onSearchChanged,
          ),
        ),
        if (hasSelection)
        InkWell(
          onTap : onClear,
          child :
          Padding(
            padding : const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child   :
            Row(
              children: [
                Expanded(child: NText( text: clearText, size: 11, weight: FontWeight.w600, color: context.mainColor)),
              ],
            ),
          ),
        ),
        if (count == 0)
        Padding(
          padding : const EdgeInsets.all(14),
          child   : NText( text: emptyText, size: 12, color: context.disabledColor),
        )
        else
        ConstrainedBox(
          constraints : BoxConstraints(maxHeight: maxHeight),
          child       :
          Scrollbar(
            thumbVisibility : true,
            controller      : scrollController,
            child           :
            ListView.builder(
              controller  : scrollController,
              shrinkWrap  : true,
              padding     : EdgeInsets.zero,
              itemCount   : count,
              itemBuilder : (BuildContext itemContext, int index) =>
              _MultiSelectOption(
                label     : labelOf(index),
                isSelected: isSelected(index),
                onToggle  : () => onToggle(index),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Opción marcable con check y etiqueta.
class _MultiSelectOption extends StatelessWidget {
  final String       label;
  final bool         isSelected;
  final VoidCallback onToggle;

  const _MultiSelectOption({required this.label, required this.isSelected, required this.onToggle});

  @override
  Widget build(BuildContext context) =>
  InkWell(
    onTap : onToggle,
    child :
    Padding(
      padding : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child   :
      Row(
        spacing : 10,
        children: [
          NCheck(value: isSelected, onCheck: onToggle),
          Expanded(
            child:
            NText(
              text    : label,
              size    : 12,
              weight  : isSelected ? FontWeight.w600 : FontWeight.normal,
              color   : isSelected ? context.mainColor : context.textColor,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
