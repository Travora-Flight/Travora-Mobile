import 'package:flutter/material.dart';
import 'package:graduation_project/models/servicess/car_service/select_bags.dart';
import 'package:graduation_project/services/car_service/select_bags_service.dart';
import 'package:graduation_project/screens/car_service/policy_screen.dart';

class SelectBagsScreen extends StatefulWidget {
  const SelectBagsScreen({super.key});

  @override
  State<SelectBagsScreen> createState() => _SelectBagsScreenState();
}

class _SelectBagsScreenState extends State<SelectBagsScreen> {
  final SelectBagsService _service = SelectBagsService();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  List<BagItem> _allBags = [];

  @override
  void initState() {
    super.initState();
    _loadBags();
  }

  Future<void> _loadBags() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _service.getMyBags();

      if (!response.isValid) {
        setState(() {
          _errorMessage = response.errorMessage ?? 'Failed to load bags';
          _isLoading = false;
        });
        return;
      }

      final List<BagItem> allBags = [];
      for (var passenger in response.passengers) {
        allBags.addAll(passenger.bags);
      }

      setState(() {
        _allBags = allBags;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _toggleSelectAll() {
    final bool allSelected = _allBags.every((bag) => bag.isSelected);
    setState(() {
      for (var bag in _allBags) {
        bag.isSelected = !allSelected;
      }
    });
  }

  Future<void> _onNext() async {
    final selectedTags = _allBags
        .where((bag) => bag.isSelected)
        .map((bag) => bag.tagNumber)
        .toList();

    if (selectedTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one bag')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _service.selectBags(selectedTags);

      if (result.success) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PolicyScreen()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to select bags, try again')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryBlue = Color(0xFF274C77);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Your Bags",
          style: TextStyle(
            color: primaryBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBags,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Choose Bags you need to deliver",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: _allBags.isEmpty
                            ? const Center(child: Text('No bags found'))
                            : ListView.builder(
                                itemCount: _allBags.length,
                                itemBuilder: (context, index) {
                                  return _buildBagCard(index);
                                },
                              ),
                      ),
                      _buildBottomButtons(primaryBlue),
                    ],
                  ),
                ),
    );
  }

  Widget _buildBagCard(int index) {
    final bag = _allBags[index];
    const Color primaryBlue = Color(0xFF274C77);
    const Color borderColor = Color(0xFFA3CEF1);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    bag.isSelected = !bag.isSelected;
                  });
                },
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: bag.isSelected ? primaryBlue : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: bag.isSelected
                          ? primaryBlue
                          : const Color(0xFFA3CEF1),
                      width: 2,
                    ),
                  ),
                  child: bag.isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 18)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                bag.tagNumber,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const SizedBox(width: 38),
              _buildInfoChip(
                Icons.shopping_bag_outlined,
                "WEIGHT",
                "${bag.weightKg.toStringAsFixed(0)} kg",
              ),
              const SizedBox(width: 12),
              _buildInfoChip(Icons.flight_takeoff, "JOURNEY", bag.journey),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(left: 38, top: 13, bottom: 13),
            child: Divider(color: Color(0xFFE2E8F0), thickness: 1.2),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 38.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on,
                      color: Colors.white, size: 12),
                ),
                const SizedBox(width: 10),
                Text(
                  "${bag.gate}, ${bag.terminal}",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value) {
    return Container(
      width: 131,
      height: 57,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0).withOpacity(0.6)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.black87),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF90A1B9),
                        fontWeight: FontWeight.bold)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(Color primaryBlue) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleSelectAll,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryBlue, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: Text("select all",
                  style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [primaryBlue, const Color(0xFFA3CEF1)]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Next",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
