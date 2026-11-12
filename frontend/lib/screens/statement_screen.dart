import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import '../services/statement_service.dart';

class StatementScreen extends StatefulWidget {
  final List<dynamic> accounts;      // Lista de conturi
  final String initialIban;          // Contul selectat din carusel

  const StatementScreen({
    super.key,
    required this.accounts,
    required this.initialIban,
  });

  @override
  State<StatementScreen> createState() => _StatementScreenState();
}

class _StatementScreenState extends State<StatementScreen> {
  DateTimeRange? _selectedRange;
  bool _isLoading = false;
  late String _selectedIban; // IBAN-ul curent din ComboBox

  @override
  void initState() {
    super.initState();
    _selectedIban = widget.initialIban; // Pornim cu cel selectat din carusel
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _selectedRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800, // Albastrul băncii
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedRange = picked);
    }
  }

  Future<void> _generateStatement() async {
    if (_selectedRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Te rog selectează o perioadă!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final service = StatementService();
    final file = await service.downloadStatement(
      iban: _selectedIban,
      start: _selectedRange!.start,
      end: _selectedRange!.end,
    );

    setState(() => _isLoading = false);

    if (file != null) {
      await OpenFile.open(file.path);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eroare la descărcare!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Același fundal ca Dashboard
      appBar: AppBar(
        title: const Text(
          'Extras de cont',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. ComboBox pentru IBAN
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
                    return DropdownMenuItem<String>(
                      value: iban,
                      child: Text(
                        '$iban ($currency)',
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
            
            const SizedBox(height: 30),

            // 2. Buton pentru selectarea perioadei
            ElevatedButton.icon(
              onPressed: _pickDateRange,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedRange == null
                    ? 'Alege perioada'
                    : '${_selectedRange!.start.toLocal().toString().split(' ')[0]} - ${_selectedRange!.end.toLocal().toString().split(' ')[0]}',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue.shade800,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),

            const SizedBox(height: 40),

            // 3. Butonul de descărcare
            ElevatedButton(
              onPressed: _isLoading ? null : _generateStatement,
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
                      'Descarcă extras',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}