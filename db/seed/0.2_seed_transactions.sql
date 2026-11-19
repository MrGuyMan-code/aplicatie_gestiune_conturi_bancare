USE sistem_bancar_db;

-- Presupunem că avem următoarele ID-uri (verifică-le în baza ta!):
-- Cont client 1 (Ion Popescu RON): id = 1, iban = 'RO49AAAA1B31007593840000'
-- Cont client 2 (Ion Popescu EUR): id = 2, iban = 'RO12BBBB2C42008604951111'
-- Cont client 3 (Tech Solutions RON): id = 3, iban = 'RO88CCCC3D53009715062222'
-- Cont intern RON: id = 4, iban = 'RO99BANK0000000000000001'
-- Cont intern EUR: id = 5, iban = 'RO99BANK0000000000000002'

-- ============================================================
-- DEPUNERE 1: 1500.50 RON în contul RO49... (Ion Popescu RON)
-- ============================================================
INSERT INTO transactions_cold (transaction_ref, transaction_type, amount, currency, source_account_id, target_account_id, description, entry_datetime, value_date, created_at)
VALUES ('BANK-DEP-20261119-0001', 'DEP_CASH', 1500.50, 'RON', 4, 1, 'Depunere initiala numerar', NOW(), CURDATE(), NOW());

SET @tx1 = LAST_INSERT_ID();

INSERT INTO transactions_hot (transaction_id, status, posting_datetime, updated_at)
VALUES (@tx1, 'COMPLETED', NOW(), NOW());

INSERT INTO ledger_entries (transaction_id, account_id, amount, entry_type, currency, deleted, created_at)
VALUES 
(@tx1, 4, -1500.50, 'DEBIT', 'RON', 0, NOW()),
(@tx1, 1, 1500.50, 'CREDIT', 'RON', 0, NOW());

UPDATE accounts SET balance = balance - 1500.50 WHERE id = 4;
UPDATE accounts SET balance = balance + 1500.50 WHERE id = 1;

-- ============================================================
-- DEPUNERE 2: 320.00 EUR în contul RO12... (Ion Popescu EUR)
-- ============================================================
-- ATENȚIE: folosim contul intern EUR (id = 5), nu cel RON (id = 4)!
INSERT INTO transactions_cold (transaction_ref, transaction_type, amount, currency, source_account_id, target_account_id, description, entry_datetime, value_date, created_at)
VALUES ('BANK-DEP-20261119-0002', 'DEP_CASH', 320.00, 'EUR', 5, 2, 'Depunere initiala numerar EUR', NOW(), CURDATE(), NOW());

SET @tx2 = LAST_INSERT_ID();

INSERT INTO transactions_hot (transaction_id, status, posting_datetime, updated_at)
VALUES (@tx2, 'COMPLETED', NOW(), NOW());

INSERT INTO ledger_entries (transaction_id, account_id, amount, entry_type, currency, deleted, created_at)
VALUES 
(@tx2, 5, -320.00, 'DEBIT', 'EUR', 0, NOW()),  -- id 5 = cont intern EUR
(@tx2, 2, 320.00, 'CREDIT', 'EUR', 0, NOW());

UPDATE accounts SET balance = balance - 320.00 WHERE id = 5;  -- id 5 = cont intern EUR
UPDATE accounts SET balance = balance + 320.00 WHERE id = 2;

-- ============================================================
-- DEPUNERE 3: 5000.00 RON în contul RO88... (Tech Solutions RON)
-- ============================================================
INSERT INTO transactions_cold (transaction_ref, transaction_type, amount, currency, source_account_id, target_account_id, description, entry_datetime, value_date, created_at)
VALUES ('BANK-DEP-20261119-0003', 'DEP_CASH', 5000.00, 'RON', 4, 3, 'Depunere initiala numerar', NOW(), CURDATE(), NOW());

SET @tx3 = LAST_INSERT_ID();

INSERT INTO transactions_hot (transaction_id, status, posting_datetime, updated_at)
VALUES (@tx3, 'COMPLETED', NOW(), NOW());

INSERT INTO ledger_entries (transaction_id, account_id, amount, entry_type, currency, deleted, created_at)
VALUES 
(@tx3, 4, -5000.00, 'DEBIT', 'RON', 0, NOW()),
(@tx3, 3, 5000.00, 'CREDIT', 'RON', 0, NOW());

UPDATE accounts SET balance = balance - 5000.00 WHERE id = 4;
UPDATE accounts SET balance = balance + 5000.00 WHERE id = 3;