import 'package:flutter/material.dart';
import '../services/transfer_service.dart';
import 'package:uuid/uuid.dart';

class TransferScreen extends StatefulWidget {
  final List<dynamic> accounts;     // Lista de conturi
  final String initialIban;         // Contul selectat din carusel

  const TransferScreen({
    super.key,
    required this.accounts,
    required this.initialIban,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _targetIbanController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  late String _selectedIban;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedIban = widget.initialIban;
  }

  @override
  void dispose() {
    _targetIbanController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    // 1. Validări locale
    if (_targetIbanController.text.isEmpty ||
        _amountController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rog completează toate câmpurile!')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Suma trebuie să fie un număr pozitiv!')),
      );
      return;
    }

    // 2. Pornim loading-ul
    setState(() => _isLoading = true);

    final idempotencyKey = const Uuid().v4();
    // 3. Apelăm serviciul
    final service = TransferService();
    final errorMessage = await service.executeTransfer(
      sourceIban: _selectedIban,
      targetIban: _targetIbanController.text.trim(),
      amount: amount,
      description: _descriptionController.text.trim(),
      idempotencyKey: idempotencyKey,
    );

    // 4. Oprim loading-ul
    if (!mounted) return;
    setState(() => _isLoading = false);

    // 5. Verificăm rezultatul
    if (errorMessage == null) {
      // Succes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transfer efectuat cu succes!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);  // Ne întoarcem la Dashboard
    } else {
      // Eroare
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'Transfer bancar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. ComboBox pentru contul sursă
              const Text(
                'Contul sursă:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedIban,
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade800),
                    items: widget.accounts.map((account) {
                      final iban = account['iban'] as String;
                      final currency = account['currency'] as String;
                      final balance = account['balance'];
                      return DropdownMenuItem<String>(
                        value: iban,
                        child: Text(
                          '$iban ($balance $currency)',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedIban = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Câmp pentru IBAN destinație
              TextFormField(
                controller: _targetIbanController,
                decoration: InputDecoration(
                  labelText: 'IBAN destinație',
                  prefixIcon: const Icon(Icons.account_balance),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 3. Câmp pentru sumă
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Sumă',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 4. Câmp pentru descriere
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descriere (obligatoriu)',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // 5. Butonul de transfer
              ElevatedButton(
                onPressed: _isLoading ? null : _handleTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Trimite transfer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}