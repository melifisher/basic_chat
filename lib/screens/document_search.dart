import 'package:flutter/material.dart';
import 'dart:async';

class DocumentSearchScreen extends StatefulWidget {
  const DocumentSearchScreen({super.key});

  @override
  State<DocumentSearchScreen> createState() => _DocumentSearchScreenState();
}

class _DocumentSearchScreenState extends State<DocumentSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  bool _isLoading = false;
  bool _hasSearched = false;
  List<DocumentItem> _searchResults = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.trim().isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock search results - replace with your API call
    final mockResults = [
      DocumentItem(
        id: '1',
        title: 'Annual Report 2024',
        snippet: 'This document contains financial data related to "$query" and quarterly figures...',
        dateModified: DateTime.now().subtract(const Duration(days: 5)),
        matchCount: 7,
      ),
      DocumentItem(
        id: '2',
        title: 'Project Proposal: $query Implementation',
        snippet: 'A comprehensive analysis of implementing $query across departments...',
        dateModified: DateTime.now().subtract(const Duration(days: 12)),
        matchCount: 15,
      ),
      DocumentItem(
        id: '3',
        title: 'Meeting Minutes - January 2024',
        snippet: 'Discussion about $query and its impact on our operations...',
        dateModified: DateTime.now().subtract(const Duration(days: 45)),
        matchCount: 3,
      ),
      DocumentItem(
        id: '4',
        title: 'Technical Documentation',
        snippet: 'Specifications and requirements for $query integration...',
        dateModified: DateTime.now().subtract(const Duration(days: 2)),
        matchCount: 9,
      ),
    ];

    if (!mounted) return;

    setState(() {
      _searchResults = mockResults;
      _isLoading = false;
    });
    
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Search'),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              // color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: SearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search for documents or fragments...',
              leading: Icon(Icons.search, color: colorScheme.primary),
              trailing: [
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                        _hasSearched = false;
                      });
                    },
                  ),
              ],
              onSubmitted: (value) => _performSearch(value),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else if (_hasSearched && _searchResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No documents found',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try a different search term',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_searchResults.length} results',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort,
                          size: 16,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Sort',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    onSelected: (value) {
                      // Implement sorting logic here
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'relevance',
                        child: Text('Relevance'),
                      ),
                      const PopupMenuItem(
                        value: 'date',
                        child: Text('Date modified'),
                      ),
                      const PopupMenuItem(
                        value: 'name',
                        child: Text('Document name'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return DocumentResultCard(
                      document: item,
                      onTap: () {
                        // Handle document selection
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Selected document: ${item.title}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      searchTerm: _searchController.text,
                    );
                  },
                ),
              ),
            )
          else if (!_hasSearched)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 72,
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Search for documents',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 280,
                      child: Text(
                        'Enter keywords to find documents and document fragments',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DocumentItem {
  final String id;
  final String title;
  final String snippet;
  final DateTime dateModified;
  final int matchCount;

  DocumentItem({
    required this.id,
    required this.title,
    required this.snippet,
    required this.dateModified,
    required this.matchCount,
  });
}

class DocumentResultCard extends StatelessWidget {
  final DocumentItem document;
  final VoidCallback onTap;
  final String searchTerm;

  const DocumentResultCard({
    super.key,
    required this.document,
    required this.onTap,
    required this.searchTerm,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  String _highlightSnippet(String snippet, String term) {
    if (term.isEmpty) return snippet;

    // This is a simplified approach - in a real app, you'd use a proper highlighting library
    // or implement a more sophisticated algorithm for highlighting
    final parts = snippet.split(RegExp(term, caseSensitive: false));
    
    if (parts.length == 1) return snippet;
    
    return parts.join('**$term**');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final highlightedSnippet = _highlightSnippet(document.snippet, searchTerm);
    
    return Card(
      elevation: 1,
      surfaceTintColor: colorScheme.surfaceTint,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.insert_drive_file_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.title,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  children: _buildHighlightedText(highlightedSnippet, searchTerm, context),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${document.matchCount} matches',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(document.dateModified),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<TextSpan> _buildHighlightedText(String text, String term, BuildContext context) {
    if (term.isEmpty) {
      return [TextSpan(text: text)];
    }

    final colorScheme = Theme.of(context).colorScheme;
    final parts = text.split('**$term**');
    final result = <TextSpan>[];
    
    for (var i = 0; i < parts.length; i++) {
      result.add(TextSpan(text: parts[i]));
      
      if (i < parts.length - 1) {
        result.add(
          TextSpan(
            text: term,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
              backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
            ),
          ),
        );
      }
    }
    
    return result;
  }
}