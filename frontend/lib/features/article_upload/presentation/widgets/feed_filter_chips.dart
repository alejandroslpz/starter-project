import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/feed/feed_state.dart';

extension _FeedFilterLabel on FeedFilter {
  String get label {
    switch (this) {
      case FeedFilter.all:
        return 'All';
      case FeedFilter.fitnessNews:
        return 'Fitness News';
      case FeedFilter.news:
        return 'News';
      case FeedFilter.community:
        return 'Community';
    }
  }
}

class FeedFilterChips extends StatelessWidget {
  final List<FeedFilter> filters;
  final FeedFilter selected;
  final ValueChanged<FeedFilter> onSelected;

  const FeedFilterChips({
    super.key,
    required this.filters,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((filter) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter.label),
              selected: filter == selected,
              onSelected: (_) => onSelected(filter),
            ),
          );
        }).toList(),
      ),
    );
  }
}
