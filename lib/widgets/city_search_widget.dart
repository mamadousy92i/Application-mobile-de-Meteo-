import 'package:flutter/material.dart';
import 'dart:async';
import '../services/nominatim_search_service.dart';

class CitySearchWidget extends StatefulWidget {
  final Function(CitySearchResult) onCitySelected;

  const CitySearchWidget({super.key, required this.onCitySelected});

  @override
  State<CitySearchWidget> createState() => _CitySearchWidgetState();
}

class _CitySearchWidgetState extends State<CitySearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final NominatimSearchService _searchService = NominatimSearchService();

  List<NominatimResult> _suggestions = [];
  bool _isLoading = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showSuggestions = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final results = await _searchService.searchCities(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _suggestions.clear();
            _isLoading = false;
          });
        }
      }
    });
  }

  void _selectCity(NominatimResult result) {
    _controller.text = result.name;
    setState(() {
      _showSuggestions = false;
      _suggestions.clear();
    });

    widget.onCitySelected(result.toCitySearchResult());

    // Effacer le champ après sélection
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //  Détection automatique du thème
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        //  Champ de recherche adaptatif
        Container(
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Theme.of(context).cardColor.withAlpha(204)
                    : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isDarkMode
                      ? Colors.white.withAlpha(51)
                      : Colors.grey.withAlpha(77),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDarkMode ? 77 : 26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher une ville...',
              hintStyle: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Theme.of(context).iconTheme.color?.withAlpha(179),
              ),
              suffixIcon:
                  _isLoading
                      ? Container(
                        width: 20,
                        height: 20,
                        margin: const EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                      : _controller.text.isNotEmpty
                      ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Theme.of(
                            context,
                          ).iconTheme.color?.withAlpha(179),
                        ),
                        onPressed: () {
                          _controller.clear();
                          setState(() {
                            _suggestions.clear();
                            _showSuggestions = false;
                          });
                        },
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),

        // 📋 Liste des suggestions adaptative
        if (_showSuggestions) ...[
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withAlpha(26)
                        : Colors.grey.withAlpha(51),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkMode ? 102 : 26),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                _suggestions.isEmpty && !_isLoading
                    ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Aucune ville trouvée',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _suggestions.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1,
                            color: Theme.of(
                              context,
                            ).dividerColor.withAlpha(128),
                          ),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return _buildSuggestionTile(suggestion, isDarkMode);
                      },
                    ),
          ),
        ],
      ],
    );
  }

  Widget _buildSuggestionTile(NominatimResult suggestion, bool isDarkMode) {
    return InkWell(
      onTap: () => _selectCity(suggestion),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            //  Icône adaptative selon le thème
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF667EEA).withAlpha(51)
                        : const Color(0xFF667EEA).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_city_rounded,
                color: Color(0xFF667EEA),
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // Informations de la ville
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //  Nom principal avec couleur adaptative
                  Text(
                    suggestion.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  //  Localisation complète avec couleur adaptative
                  Text(
                    suggestion.formattedName,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ✅ Icône de sélection adaptative
            Icon(
              Icons.add_circle_outline_rounded,
              color:
                  isDarkMode
                      ? const Color(0xFF667EEA).withAlpha(204)
                      : const Color(0xFF667EEA),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
