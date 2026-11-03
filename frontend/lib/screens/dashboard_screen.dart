import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  final List<dynamic> accounts; // <--- Am adăugat câmpul pentru conturi

  const DashboardScreen({super.key, required this.accounts}); // <--- Cerem lista în constructor

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Ținem minte ce card este selectat în carusel
  int _currentIndex = 0;
  
  // Controller pentru a putea schimba pagina din cod (dacă e nevoie)
  final PageController _pageController = PageController(viewportFraction: 0.85);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Conturile Mele', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // 1. CARUSELUL DE CARDURI
          Container(
            height: 250, 
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: PageView.builder(
              clipBehavior: Clip.none,
              controller: _pageController,
              itemCount: widget.accounts.length, // <--- Modificat aici
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final account = widget.accounts[index]; // <--- Modificat aici
                return _buildBankCard(account);
              },
            ),
          ),
          
          const SizedBox(height: 10),

          // Indicatori mici (puncte) sub carusel
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.accounts.length, // <--- Modificat aici
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index ? Colors.blue.shade800 : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // 2. BUTOANELE DE ACȚIUNE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                _buildActionButton(
                  icon: Icons.receipt_long,
                  label: 'Generează Extras',
                  onTap: () {
                    // Folosim widget.accounts
                    print('Se generează extrasul pentru IBAN: ${widget.accounts[_currentIndex]['iban']}');
                  },
                ),
                const SizedBox(height: 15),
                _buildActionButton(
                  icon: Icons.history,
                  label: 'Vizualizare Tranzacții',
                  onTap: () {
                    print('Se afișează tranzacțiile pentru IBAN: ${widget.accounts[_currentIndex]['iban']}');
                  },
                ),
                const SizedBox(height: 15),
                _buildActionButton(
                  icon: Icons.swap_horiz,
                  label: 'Realizează Transfer',
                  iconColor: Colors.green.shade700,
                  onTap: () {
                    print('Se inițiază transferul din contul: ${widget.accounts[_currentIndex]['iban']}');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget personalizat pentru design-ul cardului bancar
  Widget _buildBankCard(Map<String, dynamic> account) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sus pe card: Tipul contului și iconița
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                account['type'], // <-- Aceasta vine din JSON ca 'CURRENT' sau 'SAVINGS'
                style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const Icon(Icons.credit_card, color: Colors.white70),
            ],
          ),
          
          // Mijloc: IBAN-ul
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('IBAN', style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 4),
              Text(
                account['iban'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          
          // Jos pe card: Soldul și valuta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sold disponibil', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    // Am adaugat try/catch pentru a evita erorile de tip (daca balance e null sau string)
                    '${(account['balance'] as num?)?.toStringAsFixed(2) ?? '0.00'} ${account['currency']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                account['currency'],
                style: TextStyle(color: Colors.blue.shade200, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget ajutător pentru a nu repeta codul butoanelor
  Widget _buildActionButton({
    required IconData icon, 
    required String label, 
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? Colors.blue.shade800, size: 28),
            const SizedBox(width: 15),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}