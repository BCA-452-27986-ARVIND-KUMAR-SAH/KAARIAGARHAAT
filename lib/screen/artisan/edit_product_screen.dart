import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ImagePicker _picker = ImagePicker();
  
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  
  final List<String> _categories = ['Paintings', 'Pottery', 'Jewelry', 'Handloom', 'Woodcraft', 'Home Decor'];
  late String _selectedCategory;
  bool _isLoading = false;
  
  List<dynamic> _currentImages = []; // Mixture of String (URLs) and File (New picks)

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.title);
    _priceController = TextEditingController(text: widget.product.price);
    _descriptionController = TextEditingController(text: widget.product.description);
    _selectedCategory = widget.product.category;
    _currentImages = List.from(widget.product.imageUrls);
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _currentImages.addAll(pickedFiles.map((file) => File(file.path)).toList());
      });
    }
  }

  Future<List<String>> _uploadNewImages(String productId) async {
    List<String> finalUrls = [];
    
    for (var image in _currentImages) {
      if (image is String) {
        // Keep existing URL
        finalUrls.add(image);
      } else if (image is File) {
        // Upload new file
        String fileName = 'products/$productId/image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        finalUrls.add(downloadUrl);
      }
    }
    return finalUrls;
  }

  Future<void> _updateProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> updatedImageUrls = await _uploadNewImages(widget.product.id);

      Product updatedProduct = Product(
        id: widget.product.id,
        title: _nameController.text.trim(),
        price: _priceController.text.trim(),
        artisan: widget.product.artisan,
        artisanId: widget.product.artisanId,
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        imageUrls: updatedImageUrls,
        createdAt: widget.product.createdAt,
      );

      await _firestoreService.updateProduct(updatedProduct);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product updated!")));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Product", style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _currentImages.length + 1,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  if (index == _currentImages.length) {
                    return GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                      ),
                    );
                  }

                  var img = _currentImages[index];
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: img is String ? NetworkImage(img) : FileImage(img) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4, right: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _currentImages.removeAt(index)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            
            const SizedBox(height: 30),
            _buildLabel("Product Name"),
            _buildTextField(_nameController, "e.g. Madhubani Painting"),
            
            const SizedBox(height: 20),
            _buildLabel("Category"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.background.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  isExpanded: true,
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            _buildLabel("Price (₹)"),
            _buildTextField(_priceController, "Price", keyboardType: TextInputType.number),

            const SizedBox(height: 20),
            _buildLabel("Description"),
            _buildTextField(_descriptionController, "Description", maxLines: 5),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: _updateProduct,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("SAVE CHANGES", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(padding: const EdgeInsets.only(bottom: 8.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)));
  }

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}
