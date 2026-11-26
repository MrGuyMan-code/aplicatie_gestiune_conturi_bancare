import 'package:flutter/material.dart';
import '../services/atm_service.dart';

class AtmScreen extends StatefulWidget {
  final List<dynamic> accounts;
  const AtmScreen({super.key, required this.accounts});

  @override
  State<AtmScreen> createState() => _AtmScreenState();
}

class _AtmScreenState extends State<AtmScreen> {
  String? _selectedIban;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _selectedIban = widget.accounts[0]['iban'];
    }
  }

  Future<void> _operate(bool isDeposit) async {
    final amount = double.tryParse(_amountController.text);
    if (_selectedIban == null || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selectează un cont și introdu o sumă validă!')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final service = AtmService();
    final error = isDeposit
        ? await service.deposit(_selectedIban!, amount)
        : await service.withdraw(_selectedIban!, amount);
    setState(() => _isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isDeposit ? 'Depunere reușită!' : 'Retragere reușită!'),
          backgroundColor: Colors.green,
        ),
      );
      _amountController.clear();
      // Reîncărcăm conturile? Pentru simplitate, nu acum.
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A192F),
      appBar: AppBar(
        title: const Text('ATM BANK'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedIban,
                  isExpanded: true,
                  items: widget.accounts.map((acc) {
                    final iban = acc['iban'] as String;
                    final currency = acc['currency'] as String;
                    final balance = acc['balance'];
                    return DropdownMenuItem<String>(
                      value: iban,
                      child: Text('$iban ($balance $currency)'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedIban = value),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'Introdu suma',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _operate(true),
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('DEPUNERE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _operate(false),
                    icon: const Icon(Icons.arrow_upward),
                    label: const Text('RETRAGERE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 30),
              const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
            ],
          ],
        ),
      ),
    );
  }
}