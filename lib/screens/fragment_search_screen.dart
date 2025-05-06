import 'package:flutter/material.dart';
import 'dart:async';
import '../models/fragment_models/document_fragment_with_matches.dart';
import '../services/document_fragment_service.dart';
import 'fragment_detail_screen.dart';

class FragmentSearchScreen extends StatefulWidget {
  const FragmentSearchScreen({super.key});

  @override
  _FragmentSearchScreenState createState() => _FragmentSearchScreenState();
}

class _FragmentSearchScreenState extends State<FragmentSearchScreen> with SingleTickerProviderStateMixin {
  final _service = DocumentFragmentService();
  List<DocumentFragmentWithMatches> _searchResults = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _hasSearched = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _sortBy = 'match'; 
  bool _ascending = true;
  List<String> _cleanQueryTerms = [];

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

  void _sortSearch(){
    setState(() {
      _isLoading = true;
    });

    List<DocumentFragmentWithMatches> sortedResults = [..._searchResults];
    if (_sortBy == 'id') {
      sortedResults.sort((a, b) {
        final comp = a.fragment.documentId.compareTo(b.fragment.documentId);
        return _ascending ? comp : -comp;
      });
    }

    if (_sortBy == 'match') {
      sortedResults.sort((a, b) {
        final comp = a.matchCount.compareTo(b.matchCount);
        return _ascending ? comp : -comp;
      });
    }

    setState(() {
      _searchResults = sortedResults;
      _isLoading = false;
    });

  }

  void _performSearch(String texto) async {
    final query = texto.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = true;
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });
    
    try {
      // await Future.delayed(Duration(milliseconds: 150));

      final cleanQuery = Stopwords.removeStopwords(query.toLowerCase());
      _cleanQueryTerms = cleanQuery
      .split(RegExp(r'\s+'))
      .where((term) => term.isNotEmpty)
      .toList();

      final results = _service.searchByKeywords(cleanQuery);

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
  
  Future<void> _loadFragments() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      await DocumentFragmentService.fetchFragments(collectionName: "langchain");
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fragments loaded successfully')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading fragments: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busqueda de Documentos'),
        centerTitle: false,
        elevation: 0,
      ),
      floatingActionButton: _service.isEmpty() 
        ? FloatingActionButton(
            onPressed: _loadFragments,
            tooltip: 'Cargar fragmentos',
            child: const Icon(Icons.upload_file)
          )
        : null,
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
              hintText: 'Buscar fragmentos...',
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
          // const SizedBox(height: 8),
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
                      'No se encontraron documentos',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Intenta con un término de búsqueda diferente',
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                      setState(() {
                        if (_sortBy == value) {
                          _ascending = !_ascending; // Toggle direction
                        } else {
                          _sortBy = value;
                          _ascending = true;
                        }
                        _sortSearch();
                      });
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'id',
                        child: Text('Document ID'),
                      ),
                      const PopupMenuItem(
                        value: 'match',
                        child: Text('Match'),
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
                    return _buildResultCard(item);
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
                      'Busca por documentos',
                      style: textTheme.titleLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 280,
                      child: Text(
                        'Ingresa palabras clave para encontrar documentos y fragmentos de documentos',                        textAlign: TextAlign.center,
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

  TextSpan highlightText(String text, List<String> queryTerms) {
    final List<TextSpan> spans = [];
    final lowerText = text.toLowerCase();
    int start = 0;

    while (start < text.length) {
      int matchStart = -1;
      int matchEnd = -1;
      String? matchedTerm;

      for (final term in queryTerms) {
        final lowerTerm = term.toLowerCase();
        final index = lowerText.indexOf(lowerTerm, start);
        if (index >= 0 && (matchStart == -1 || index < matchStart)) {
          matchStart = index;
          matchEnd = index + lowerTerm.length;
          matchedTerm = text.substring(matchStart, matchEnd);
        }
      }

      if (matchStart == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (matchStart > start) {
        spans.add(TextSpan(text: text.substring(start, matchStart)));
      }

      spans.add(TextSpan(
        text: matchedTerm,
        style: const TextStyle(
          backgroundColor: Colors.yellow,
          fontWeight: FontWeight.bold,
        ),
      ));

      start = matchEnd;
    }

    return TextSpan(style: const TextStyle(color: Colors.black), children: spans);
  }

  Widget _buildResultCard(DocumentFragmentWithMatches result) {
    final fragment = result.fragment;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FragmentDetailScreen(
                fragment: fragment,
                matchCount: result.matchCount,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${result.matchCount} ${result.matchCount == 1 ? 'match' : 'matches'}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: ${fragment.documentId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              RichText(
                text: highlightText(fragment.text, _cleanQueryTerms),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (fragment.metadata.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${fragment.metadata.length} metadata items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
