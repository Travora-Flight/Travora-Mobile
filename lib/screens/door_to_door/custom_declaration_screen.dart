import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import '../../services/customs_services/customs_service.dart';
import '../../models/servicess/customs_models/customs_item_model.dart';
import '../../models/servicess/customs_models/invoice_model.dart';
import '../../models/servicess/customs_models/customs_category_model.dart';
import 'policy_screen.dart';

class CustomDeclarationScreen extends StatefulWidget {
  const CustomDeclarationScreen({super.key});

  @override
  State<CustomDeclarationScreen> createState() =>
      _CustomDeclarationScreenState();
}

class _CustomDeclarationScreenState extends State<CustomDeclarationScreen> {
  final ImagePicker _picker = ImagePicker();
  final CustomsService _customsService = CustomsService();
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  List<CustomsCategoryModel> _categories = [];

  double _customsValue = 0;
  double _totalCustomsFee = 0;
  double _totalDeclaredValue = 0;

  final List<Map<String, dynamic>> _items = [
    {
      "categoryId": null,
      "categoryName": null,
      "image": null,
      "isExpanded": true,
      "descriptionController": TextEditingController(),
      "valueController": TextEditingController(),
      "quantityController": TextEditingController(),
      "suggestions": <String>[],
      "showSuggestions": false,
    }
  ];

  final Map<String, List<String>> categoryProducts = {
    'Electronics': [
      'iPhone',
      'Samsung Galaxy',
      'Xiaomi',
      'Huawei',
      'Nokia',
      'Oppo',
      'Realme',
      'MacBook',
      'Dell',
      'HP',
      'Lenovo',
      'Asus',
      'Acer',
      'MSI',
      'iPad',
      'Samsung Galaxy Tab',
      'Huawei MatePad',
      'Lenovo Tab',
      'Microsoft Surface',
      'AirPods',
      'Sony Headphones',
      'JBL Headphones',
      'Bose Headphones',
      'Beats',
      'Anker Soundcore',
      'Apple Watch',
      'Samsung Galaxy Watch',
      'Huawei Watch',
      'Xiaomi Mi Band',
      'Garmin',
      'USB-C Charger',
      'Lightning Cable',
      'USB-C Cable',
      'Wireless Charger',
      'Power Bank',
      'Car Charger',
      'Samsung TV',
      'LG TV',
      'Sony TV',
      'TCL TV',
      'Hisense TV',
      'Panasonic TV',
      'Canon Camera',
      'Nikon Camera',
      'Sony Camera',
      'Fujifilm Camera',
      'GoPro',
    ],
    'Clothing': [
      'T-Shirts',
      'Shirts',
      'Jeans',
      'Suits',
      'Casual Pants',
      'Dresses',
      'Tops',
      'Abayas',
      'Baby Sets',
      'Boys Clothing',
      'Girls Clothing',
      'School Uniforms',
      'Leather Jackets',
      'Winter Coats',
      'Hoodies',
      'Blazers',
      'Tracksuits',
      'Gym Wear',
      'Swimwear',
      'Yoga Wear',
      'Sneakers',
      'Formal Shoes',
      'Sandals',
      'Boots',
      'Slippers',
      'Belts',
      'Hats',
      'Caps',
      'Scarves',
      'Sunglasses',
      'Skirts',
      'Blouses',
    ],
    'Furniture': [
      'Sofas',
      'Coffee Tables',
      'TV Units',
      'Beds',
      'Wardrobes',
      'Nightstands',
      'Office Chairs',
      'Desks',
      'Book Shelves',
      'Cabinets',
      'Dining Tables',
      'Garden Chairs',
      'Outdoor Tables',
    ],
    'Jewelry': [
      'Gold Ring',
      'Silver Ring',
      'Diamond Ring',
      'Gold Necklace',
      'Silver Necklace',
      'Pearl Necklace',
      'Charm Bracelet',
      'Gold Bracelet',
      'Silver Bracelet',
      'Stud Earrings',
      'Hoop Earrings',
      'Drop Earrings',
      'Rolex',
      'Casio',
      'Fossil',
      'Tissot',
      '18K Gold Set',
      '21K Gold Set',
      '24K Gold Bar',
      'Sterling Silver Set',
      'Handmade Silver Piece',
    ],
    'Medical supplies': [
      'Antibiotics',
      'Pain Killers',
      'Blood Pressure Medicine',
      'Cold & Flu',
      'Headache Relief',
      'Antacid',
      'Vitamin C',
      'Omega 3',
      'Protein Powder',
      'Blood Pressure Monitor',
      'Glucometer',
      'Nebulizer',
      'Bandages',
      'Antiseptics',
      'First Aid Kit',
      'Thermometer',
      'Face Masks',
      'Hand Sanitizer',
    ],
    'Sport equipment': [
      'Bicycles',
      'Scooters',
      'Balls',
    ],
    'Others': [
      'Oil Painting',
      'Acrylic Painting',
      'Watercolor Painting',
      'Stone Sculpture',
      'Metal Sculpture',
      'Wood Sculpture',
      'Handmade Pottery',
      'Wooden Crafts',
      'Handmade Textile Art',
      'Digital Illustration',
      '3D Art',
      'Digital Prints',
      'Paint Brushes',
      'Canvas',
      'Acrylic Paint Set',
      'Arabic Calligraphy Piece',
      'English Calligraphy Piece',
      'Calligraphy Tools',
      'Fruits',
      'Vegetables',
      'Meat',
      'Chicken',
      'Fish',
      'Frozen Vegetables',
      'Frozen Meat',
      'Ice Cream',
      'Ready Meals',
      'Chips',
      'Biscuits',
      'Chocolate',
      'Nuts',
      'Soft Drinks',
      'Juices',
      'Energy Drinks',
      'Tea',
      'Coffee',
      'Milk',
      'Cheese',
      'Yogurt',
      'Butter',
      'Bread',
      'Cakes',
      'Pastries',
      'Croissants',
      'Canned Beans',
      'Tuna',
      'Corn',
      'Tomato Paste',
      'Lipstick',
      'Foundation',
      'Mascara',
      'Eyeliner',
      'Face Wash',
      'Moisturizer',
      'Sunscreen',
      'Serum',
      'Shampoo',
      'Conditioner',
      'Hair Oil',
      'Hair Mask',
      'Men Perfume',
      'Women Perfume',
      'Unisex Perfume',
      'Body Lotion',
      'Deodorant',
      'Soap',
      'Makeup Brushes',
      'Hair Dryer',
      'Hair Straightener',
      'School Books',
      'University Books',
      'Language Learning',
      'Romance Novel',
      'Mystery Novel',
      'Fantasy Novel',
      'Quran',
      'Bible',
      'Hadith Books',
      'Story Books',
      'Coloring Books',
      'Computer Science Book',
      'Engineering Book',
      'Medical Book',
      'Marvel Comics',
      'DC Comics',
      'Manga',
      'Fashion Magazine',
      'Technology Magazine',
      'Sports Magazine',
      'Plush Toys',
      'Toy Cars',
      'Building Blocks',
      'Puzzles',
      'Learning Boards',
      'STEM Toys',
      'Superhero Figures',
      'Anime Figures',
      'Barbie',
      'Baby Dolls',
      'Chess',
      'Monopoly',
      'Ludo',
      'Umbrellas',
      'Curtains',
      'Carpets',
      'Wall Art',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _customsService.getCategories();
      setState(() {
        _categories = categories;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addNewItem() {
    setState(() {
      _items.add({
        "categoryId": null,
        "categoryName": null,
        "image": null,
        "isExpanded": true,
        "descriptionController": TextEditingController(),
        "valueController": TextEditingController(),
        "quantityController": TextEditingController(),
        "suggestions": <String>[],
        "showSuggestions": false,
      });
    });
  }

  Future<void> _pickImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _items[index]['image'] = File(image.path);
      });
    }
  }

  void _onDescriptionChanged(int index, String value) {
    final String? selectedCategoryName = _items[index]['categoryName'];
    if (selectedCategoryName == null || value.isEmpty) {
      setState(() {
        _items[index]['suggestions'] = <String>[];
        _items[index]['showSuggestions'] = false;
      });
      return;
    }

    final List<String> products = categoryProducts[selectedCategoryName] ?? [];
    final List<String> filtered = products
        .where((p) => p.toLowerCase().contains(value.toLowerCase()))
        .toList();

    setState(() {
      _items[index]['suggestions'] = filtered;
      _items[index]['showSuggestions'] = filtered.isNotEmpty;
    });
  }

  String _getOrdinalTitle(int index) {
    List<String> ordinals = [
      "First",
      "Second",
      "Third",
      "Fourth",
      "Fifth",
      "Sixth"
    ];
    if (index < ordinals.length) return ordinals[index];
    return "Next";
  }

  Future<void> _submitItems() async {
    for (int i = 0; i < _items.length; i++) {
      final desc = (_items[i]['descriptionController'] as TextEditingController)
          .text
          .trim();
      final value =
          (_items[i]['valueController'] as TextEditingController).text.trim();
      final qty = (_items[i]['quantityController'] as TextEditingController)
          .text
          .trim();

      if (_items[i]['categoryId'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Please select a category for ${_getOrdinalTitle(i)} item"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (desc.isEmpty || value.isEmpty || qty.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text("Please fill all fields for ${_getOrdinalTitle(i)} item"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      CustomsItemModel? lastResult;
      for (int i = 0; i < _items.length; i++) {
        final desc =
            (_items[i]['descriptionController'] as TextEditingController)
                .text
                .trim();
        final value = double.tryParse(
                (_items[i]['valueController'] as TextEditingController)
                    .text
                    .trim()) ??
            0;
        final qty = int.tryParse(
                (_items[i]['quantityController'] as TextEditingController)
                    .text
                    .trim()) ??
            1;
        final File? image = _items[i]['image'];
        final String categoryId = _items[i]['categoryId'].toString();
        final String categoryName = _items[i]['categoryName'].toString();

        lastResult = await _customsService.addCustomsItem(
          externalCategoryId: categoryId,
          externalCategoryName: categoryName,
          itemDescription: desc,
          declaredValue: value,
          quantity: qty,
          purchaseInvoice: image,
        );

        if (!lastResult.success) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(lastResult.errorMessage ??
                  "Error adding ${_getOrdinalTitle(i)} item"),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      }

      if (lastResult != null) {
        setState(() {
          _totalDeclaredValue = lastResult!.totalDeclaredValue;
          _totalCustomsFee = lastResult!.totalCustomsFee;
        });
      }

      final InvoiceModel invoice = await _customsService.getInvoice();

      if (!mounted) return;

      setState(() {
        _customsValue = invoice.breakdown.customsValue;
        _totalCustomsFee = invoice.breakdown.customsFee;
        _totalDeclaredValue = invoice.breakdown.totalAmount;
        _isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const PolicyScreen(serviceName: "Door to Door"),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      (item['descriptionController'] as TextEditingController).dispose();
      (item['valueController'] as TextEditingController).dispose();
      (item['quantityController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color fieldFillColor = const Color(0xFF274C77).withOpacity(0.20);
    const Color darkBlue = Color(0xFF274C77);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Custom Declaration",
            style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Decleare your items",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 20),
                ...List.generate(_items.length, (index) {
                  final bool isExpanded = _items[index]['isExpanded'] ?? true;
                  final TextEditingController descController =
                      _items[index]['descriptionController'];
                  final TextEditingController valueController =
                      _items[index]['valueController'];
                  final TextEditingController quantityController =
                      _items[index]['quantityController'];
                  final List<String> suggestions =
                      List<String>.from(_items[index]['suggestions'] ?? []);
                  final bool showSuggestions =
                      _items[index]['showSuggestions'] ?? false;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _items[index]['isExpanded'] = !isExpanded;
                          });
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${_getOrdinalTitle(index)} Item",
                                  style: const TextStyle(
                                      color: darkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Icon(
                                isExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: darkBlue,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (isExpanded) ...[
                        _buildLabel("Item Category"),
                        _isCategoriesLoading
                            ? Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: fieldFillColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: darkBlue,
                                    ),
                                  ),
                                ),
                              )
                            : LayoutBuilder(
                                builder: (context, constraints) {
                                  return DropdownMenu<int>(
                                    width: constraints.maxWidth,
                                    hintText: "select Category",
                                    inputDecorationTheme: InputDecorationTheme(
                                      filled: true,
                                      fillColor: fieldFillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 0),
                                      constraints:
                                          const BoxConstraints(maxHeight: 48),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none),
                                    ),
                                    menuStyle: MenuStyle(
                                      shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                            color: darkBlue, width: 1.5),
                                      )),
                                    ),
                                    onSelected: (int? categoryId) {
                                      final selected = _categories.firstWhere(
                                          (c) => c.categoryId == categoryId);
                                      setState(() {
                                        _items[index]['categoryId'] =
                                            categoryId;
                                        _items[index]['categoryName'] =
                                            selected.name;
                                        _items[index]
                                            ['suggestions'] = <String>[];
                                        _items[index]['showSuggestions'] =
                                            false;
                                        descController.clear();
                                      });
                                    },
                                    dropdownMenuEntries: _categories
                                        .map((c) => DropdownMenuEntry(
                                            value: c.categoryId, label: c.name))
                                        .toList(),
                                  );
                                },
                              ),

                        const SizedBox(height: 15),

                        _buildLabel("Item Description"),
                        TextField(
                          controller: descController,
                          onChanged: (value) =>
                              _onDescriptionChanged(index, value),
                          decoration: InputDecoration(
                            hintText: "description",
                            hintStyle: const TextStyle(
                                color: Color(0xFF7B7B7B), fontSize: 14),
                            filled: true,
                            fillColor: fieldFillColor,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                          ),
                        ),

                        // Suggestions list
                        if (showSuggestions)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: darkBlue.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ],
                            ),
                            constraints: const BoxConstraints(maxHeight: 160),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: suggestions.length,
                              itemBuilder: (context, sIndex) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      descController.text = suggestions[sIndex];
                                      _items[index]['showSuggestions'] = false;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    child: Text(suggestions[sIndex],
                                        style: const TextStyle(fontSize: 14)),
                                  ),
                                );
                              },
                            ),
                          ),

                        const SizedBox(height: 15),

                        // 3. Value & Quantity
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("value"),
                                  TextField(
                                    controller: valueController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "\$220",
                                      hintStyle: const TextStyle(
                                          color: Color(0xFF7B7B7B),
                                          fontSize: 14),
                                      filled: true,
                                      fillColor: fieldFillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel("Quntity"),
                                  TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      hintText: "2",
                                      hintStyle: const TextStyle(
                                          color: Color(0xFF7B7B7B),
                                          fontSize: 14),
                                      filled: true,
                                      fillColor: fieldFillColor,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _buildLabel("Upload invoce or receipt"),
                        GestureDetector(
                          onTap: () => _pickImage(index),
                          child: CustomPaint(
                            painter: DashedBorderPainter(
                                color: darkBlue.withOpacity(0.5)),
                            child: Container(
                              height: 100,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: fieldFillColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: _items[index]['image'] == null
                                  ? const Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.upload_outlined,
                                            color: Colors.grey),
                                        Text("Enter to upload",
                                            style:
                                                TextStyle(color: Colors.grey)),
                                      ],
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Image.file(_items[index]['image'],
                                          fit: BoxFit.cover),
                                    ),
                            ),
                          ),
                        ),
                      ],
                      if (index != _items.length - 1)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(thickness: 1, color: Colors.grey),
                        ),
                    ],
                  );
                }),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: _isLoading ? null : _addNewItem,
                    child: const Text("+ add Item",
                        style: TextStyle(
                            color: darkBlue,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold))),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: fieldFillColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: darkBlue.withOpacity(0.1))),
                  child: Column(
                    children: [
                      _SummaryRow(
                          label: "Customs value", value: "\$$_customsValue"),
                      _SummaryRow(
                          label: "Customs fee", value: "\$$_totalCustomsFee"),
                      const Divider(color: darkBlue),
                      _SummaryRow(
                          label: "Total",
                          value: "\$$_totalDeclaredValue",
                          isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                _buildNextButton(context, darkBlue),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: darkBlue),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 5),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.black)));

  Widget _buildNextButton(BuildContext context, Color color) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, const Color(0xFFA3CEF1)]),
          borderRadius: BorderRadius.circular(16)),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitItems,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent),
        child: const Text("Next",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    Path path = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(16)));
    double dashWidth = 5, dashSpace = 3, distance = 0;
    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        canvas.drawPath(
            pathMetric.extractPath(distance, distance + dashWidth), paint);
        distance += dashWidth + dashSpace;
      }
      distance = 0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow(
      {required this.label, required this.value, this.isBold = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
