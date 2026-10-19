-- ============================================================
-- NUKE: șterge toate tabelele din sistem_bancar_db
-- Ordinea contează: întâi cele care referă, apoi cele referite.
-- IF EXISTS previne erorile dacă un tabel lipsește.
-- ============================================================

USE sistem_bancar_db;

-- Dezactivare verificare FK temporar (opțional, dar util)
SET FOREIGN_KEY_CHECKS = 0;

-- Tabele care referă altele (copiii)
DROP TABLE IF EXISTS ledger_entries;
DROP TABLE IF EXISTS transactions_hot;
DROP TABLE IF EXISTS transactions_cold;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS contacte;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS transaction_sequences;
DROP TABLE IF EXISTS clienti;
DROP TABLE IF EXISTS metode_contact;
DROP TABLE IF EXISTS persoane_juridice;
DROP TABLE IF EXISTS persoane_fizice;

-- Reactivare verificare FK
SET FOREIGN_KEY_CHECKS = 1;
