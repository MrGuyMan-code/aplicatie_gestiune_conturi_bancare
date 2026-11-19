import 'package:flutter/material.dart';
import '../services/transaction_service.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  final String iban;
  const TransactionsScreen({super.key, required this.iban});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  int _currentPage = 0;
  bool _isLoading = false;
  List<dynamic> _transactions = [];
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _loadPage(0);
  }

  Future<void> _loadPage(int page) async {
    setState(() => _isLoading = true);
    final service = TransactionService();
    final data = await service.getTransactions(iban: widget.iban, page: page);
    setState(() => _isLoading = false);

    if (data != null) {
      setState(() {
        _transactions = data['content'];
        _currentPage = data['number'];
        _totalPages = data['totalPages'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Tranzacții', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final amount = (tx['amount'] as num).toDouble();
                      final isDebit = amount < 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: Icon(
                            isDebit ? Icons.arrow_upward : Icons.arrow_downward,
                            color: isDebit ? Colors.red : Colors.green,
                          ),
                          title: Text(tx['description'] ?? 'Fără descriere'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx['date'] != null
                                    ? DateFormat('dd.MM.yyyy HH:mm').format(DateTime.parse(tx['date']))
                                    : '',
                              ),
                              if (tx['otherIban'] != null && tx['otherIban'] != 'N/A')
                                Text(
                                  'Cont: ${tx['otherIban']}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${isDebit ? '-' : '+'}${amount.abs().toStringAsFixed(2)} RON',
                            style: TextStyle(
                              color: isDebit ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Paginare
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentPage > 0 ? () => _loadPage(_currentPage - 1) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage > 0 ? Colors.blue.shade800 : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Anterior'),
                      ),
                      Text('Pagina ${_currentPage + 1} din $_totalPages'),
                      ElevatedButton(
                        onPressed: _currentPage < _totalPages - 1 ? () => _loadPage(_currentPage + 1) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentPage < _totalPages - 1 ? Colors.blue.shade800 : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Următor'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}