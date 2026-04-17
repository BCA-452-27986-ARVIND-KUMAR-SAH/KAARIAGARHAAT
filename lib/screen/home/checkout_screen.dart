import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/order.dart';
import 'package:kaarigarhaat/models/shipping_address.dart';
import 'package:kaarigarhaat/utils/cart_data.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import 'order_success_screen.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double totalAmount;

  const CheckoutScreen({super.key, required this.totalAmount});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Razorpay _razorpay;
  String _selectedPayment = 'UPI';
  bool _isLoading = false;
  ShippingAddress? _selectedAddress;

  final String _razorpayKey = 'rzp_test_STKaP3CCP3fePN'; 

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _firestoreService.getAddresses(user.uid).first.then((addresses) {
        if (addresses.isNotEmpty) {
          if (mounted) {
            setState(() {
              _selectedAddress = addresses.firstWhere(
                (addr) => addr.isDefault, 
                orElse: () => addresses.first
              );
            });
          }
        }
      });
    }

    String? preferred = prefs.getString('default_payment_method');
    if (preferred != null) {
      setState(() {
        if (preferred == 'COD') {
          _selectedPayment = 'Cash on Delivery';
        } else if (preferred == 'UPI') {
          _selectedPayment = 'UPI';
        } else if (preferred.startsWith('****')) {
          _selectedPayment = 'Credit / Debit Card';
        }
      });
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _placeOrderInFirestore(paymentId: response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed: ${response.message ?? 'Unknown Error'}"), 
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  Future<void> _handlePlaceOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a delivery address"), backgroundColor: Colors.orange),
      );
      return;
    }

    if (_selectedPayment == 'Cash on Delivery') {
      setState(() => _isLoading = true);
      _placeOrderInFirestore();
    } else {
      _startRazorpayPayment();
    }
  }

  void _startRazorpayPayment() {
    var options = {
      'key': _razorpayKey,
      'amount': (widget.totalAmount * 100).toInt(),
      'name': 'Kaarigar Haat',
      'description': 'Handicraft Order Payment',
      'prefill': {
        'contact': _selectedAddress?.phoneNumber ?? '9876543210', 
        'email': FirebaseAuth.instance.currentUser?.email ?? 'customer@kaarigarhaat.com'
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  Future<void> _placeOrderInFirestore({String? paymentId}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && _selectedAddress != null) {
        String fullAddress = "${_selectedAddress!.name}, ${_selectedAddress!.houseNumber}, ${_selectedAddress!.area}, ${_selectedAddress!.city}, ${_selectedAddress!.state} - ${_selectedAddress!.pincode}";

        List<String> artisanIds = CartData.items.map((item) => item.artisanId.trim()).toSet().toList();

        OrderModel newOrder = OrderModel(
          id: '',
          userId: user.uid,
          items: List.from(CartData.items),
          artisanIds: artisanIds,
          totalAmount: widget.totalAmount,
          status: 'Processing',
          address: fullAddress,
          paymentMethod: _selectedPayment,
          paymentId: paymentId,
          createdAt: DateTime.now(),
        );

        DocumentReference docRef = await _firestoreService.placeOrder(newOrder);
        
        OrderModel finalOrder = OrderModel(
          id: docRef.id,
          userId: newOrder.userId,
          items: newOrder.items,
          artisanIds: newOrder.artisanIds,
          totalAmount: newOrder.totalAmount,
          status: newOrder.status,
          address: newOrder.address,
          paymentMethod: newOrder.paymentMethod,
          paymentId: newOrder.paymentId,
          createdAt: newOrder.createdAt,
        );

        CartData.items.clear();

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => OrderSuccessScreen(order: finalOrder)),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : AppColors.textDark,
        elevation: 0,
      ),
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Delivery Address",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _selectedAddress != null 
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedAddress!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            "${_selectedAddress!.houseNumber}, ${_selectedAddress!.area}, ${_selectedAddress!.city}, ${_selectedAddress!.state}", 
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      )
                    : const Text("No address selected", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddressListScreen()),
                      ).then((_) => _loadInitialData());
                    },
                    child: const Text("Change", style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _paymentOption("UPI", Icons.account_balance_wallet_outlined, isDarkMode),
            _paymentOption("Credit / Debit Card", Icons.credit_card_outlined, isDarkMode),
            _paymentOption("Net Banking", Icons.language_outlined, isDarkMode),
            _paymentOption("Cash on Delivery", Icons.money_outlined, isDarkMode),
            const SizedBox(height: 30),
            const Text(
              "Order Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _summaryRow("Subtotal", "₹${widget.totalAmount - 50}", isDarkMode),
                  _summaryRow("Shipping", "₹50.00", isDarkMode),
                  const Divider(height: 24),
                  _summaryRow("Total Amount", "₹${widget.totalAmount}", isDarkMode, isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handlePlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _selectedPayment == 'Cash on Delivery' ? "PLACE ORDER" : "PROCEED TO PAY",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _paymentOption(String title, IconData icon, bool isDarkMode) {
    bool isSelected = _selectedPayment == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedPayment = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 12),
            Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isDarkMode, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? (isDarkMode ? Colors.white : AppColors.textDark) : Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppColors.primary : (isDarkMode ? Colors.white : AppColors.textDark))),
        ],
      ),
    );
  }
}
