import 'package:flutter/material.dart';
import 'package:sublime/src/widgets/custom_icon_button.dart';

typedef SearchFilter<T> = List<String?> Function(T t);
typedef ResultBuilder<T> = Widget Function(T t);

class SearchScreen<T> extends SearchDelegate<T?> {
  SearchScreen({
    String? searchLabel,
    required this.suggestionsView,
    required this.failureView,
    required this.items,
    required this.filter,
    required this.itemBuilder,
  }) : super(searchFieldLabel: searchLabel);

  final Widget suggestionsView;
  final Widget failureView;
  final List<T> items;
  final SearchFilter<T> filter;
  final ResultBuilder<T> itemBuilder;

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: Theme.of(context).appBarTheme.copyWith(
            titleSpacing: 0,
          ),
      textTheme: Theme.of(context).textTheme.copyWith(
            headline6: const TextStyle(fontSize: 18),
          ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(fontSize: 18),
        border: InputBorder.none,
      ),
    );
  }

  @override
  Widget buildLeading(BuildContext context) {
    return CustomIconButton(
      icon: const BackButtonIcon(),
      tooltip: "Back",
      onPressed: () => close(context, null),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        CustomIconButton(
          icon: const Icon(Icons.clear),
          tooltip: "Clear",
          onPressed: () => query = "",
        ),
    ];
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }

  @override
  Widget buildResults(BuildContext context) {
    final String cleanQuery = query.toLowerCase().trim();

    final List<T> result = items.where((item) {
      return filter(item)
          .map((value) => value?.toLowerCase().trim())
          .any((value) => value?.contains(cleanQuery) == true);
    }).toList();

    return cleanQuery.isEmpty
        ? suggestionsView
        : (result.isEmpty
            ? failureView
            : ListView.separated(
                itemCount: result.length,
                itemBuilder: (context, index) => itemBuilder(result[index]),
                separatorBuilder: (context, index) => const Divider(),
              ));
  }
}
