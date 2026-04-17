import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class FilterModal extends StatefulWidget {
  const FilterModal({super.key});

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  RangeValues _currentRangeValues = const RangeValues(0, 5000);
  double _selectedRating = 0;
  String _selectedCategory = 'All';

  final List<String> _categories = ['All', 'Pottery', 'Paintings', 'Textiles', 'Jewelry', 'Woodwork'];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Filter Products", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Price Range
          const Text("Price Range", style: TextStyle(fontWeight: FontWeight.bold)),
          RangeSlider(
            values: _currentRangeValues,
            max: 10000,
            divisions: 20,
            activeColor: AppColors.primary,
            labels: RangeLabels(
              "₹${_currentRangeValues.start.round()}",
              "₹${_currentRangeValues.end.round()}",
            ),
            onChanged: (RangeValues values) {
              setState(() {
                _currentRangeValues = values;
              });
            },
          ),
          
          const SizedBox(height: 24),

          // Categories
          const Text("Category", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                bool isSelected = _selectedCategory == _categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : (isDarkMode ? Colors.white : Colors.black)),
                    onSelected: (bool selected) {
                      setState(() {
                        _selectedCategory = _categories[index];
                      });
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Rating
          const Text("Minimum Rating", style: TextStyle(fontWeight: FontWeight.bold)),
          Slider(
            value: _selectedRating,
            max: 5,
            divisions: 5,
            label: "$_selectedRating Stars",
            activeColor: Colors.amber,
            onChanged: (double value) {
              setState(() {
                _selectedRating = value;
              });
            },
          ),

          const SizedBox(height: 32),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("APPLY FILTERS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
