import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../utils/colors.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, dynamic>> savedCards = [];
  String upiId = "artisan@okaxis";
  String defaultMethod = "UPI";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _expController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPaymentData();
  }

  Future<void> _loadPaymentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      String? cardsJson = prefs.getString('saved_cards');
      if (cardsJson != null) {
        savedCards = List<Map<String, dynamic>>.from(json.decode(cardsJson));
      }
      upiId = prefs.getString('upi_id') ?? "artisan@okaxis";
      defaultMethod = prefs.getString('default_payment_method') ?? "UPI";
    });
  }

  Future<void> _savePaymentData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_cards', json.encode(savedCards));
    await prefs.setString('upi_id', upiId);
    await prefs.setString('default_payment_method', defaultMethod);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expController.dispose();
    _cvvController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  void _addNewCard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 20, left: 20, right: 20,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 50, height: 5, decoration: const BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(10))))),
              const SizedBox(height: 20),
              const Text("Add New Card", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildTextField("Card Holder Name", Icons.person_outline, controller: _nameController),
              const SizedBox(height: 16),
              _buildTextField("Card Number", Icons.credit_card, controller: _numberController, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField("Expiry Date", Icons.calendar_today, controller: _expController, hint: "MM/YY")),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField("CVV", Icons.lock_outline, controller: _cvvController, obscureText: true)),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (_numberController.text.isNotEmpty) {
                      setState(() {
                        String lastFour = _numberController.text.length > 4 ? _numberController.text.substring(_numberController.text.length - 4) : _numberController.text;
                        savedCards.add({
                          "brand": "Visa",
                          "number": "**** **** **** $lastFour",
                          "exp": _expController.text,
                          "color": Colors.indigo.value, // Store as int for JSON
                        });
                        _savePaymentData();
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text("SAVE CARD", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _editUpi() {
    _upiController.text = upiId;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit UPI ID"),
        content: TextField(
          controller: _upiController,
          decoration: const InputDecoration(hintText: "example@upi", prefixIcon: Icon(Icons.alternate_email)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                upiId = _upiController.text;
                defaultMethod = "UPI";
                _savePaymentData();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {required TextEditingController controller, TextInputType? keyboardType, bool obscureText = false, String? hint}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Payment Methods", style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (savedCards.isNotEmpty) ...[
              const Text("Saved Cards", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...savedCards.asMap().entries.map((entry) {
                int idx = entry.key;
                var card = entry.value;
                return _buildPaymentCard(
                  context, card["brand"], card["number"], "Exp: ${card["exp"]}", Color(card["color"]), isDarkMode,
                  () {
                    setState(() {
                      savedCards.removeAt(idx);
                      _savePaymentData();
                    });
                  },
                );
              }),
              const SizedBox(height: 24),
            ],
            const Text("Other Methods", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildOtherMethod(Icons.account_balance_wallet_outlined, "UPI ID", upiId, isDarkMode, "UPI", () => _editUpi()),
            _buildOtherMethod(Icons.money_outlined, "Cash on Delivery", "Enabled", isDarkMode, "COD", () {
              setState(() {
                defaultMethod = "COD";
                _savePaymentData();
              });
            }),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton.icon(
                onPressed: _addNewCard,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text("ADD NEW CARD", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, String brand, String number, String exp, Color color, bool isDarkMode, VoidCallback onDelete) {
    bool isDefault = defaultMethod == number;
    return GestureDetector(
      onTap: () {
        setState(() {
          defaultMethod = number;
          _savePaymentData();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(20),
          border: isDefault ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(brand, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                if (isDefault) const Icon(Icons.check_circle, color: Colors.white),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, color: Colors.white70), constraints: const BoxConstraints(), padding: EdgeInsets.zero),
              ],
            ),
            const SizedBox(height: 24),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(exp, style: const TextStyle(color: Colors.white70)), const Icon(Icons.credit_card, color: Colors.white70)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherMethod(IconData icon, String title, String subtitle, bool isDarkMode, String methodKey, VoidCallback onTap) {
    bool isSelected = defaultMethod == methodKey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : (isDarkMode ? Colors.white10 : Colors.grey.shade100), width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }
}
