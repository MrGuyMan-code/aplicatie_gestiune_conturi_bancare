USE sistem_bancar_db;

-- 1. Inserăm o persoană fizică
INSERT INTO persoane_fizice (nume, prenume, cnp, adresa, data_nasterii) 
VALUES ('Popescu', 'Ion', '1900101123456', 'Str. Victoriei 10, Bucuresti', '1990-01-01');

-- 2. Inserăm o persoană juridică (reprezentant = Ion Popescu)
INSERT INTO persoane_juridice (denumire, cui, adresa, reprezentant_id) 
VALUES ('Tech Solutions SRL', 'RO12345678', 'Bd. Unirii 5, Bucuresti', 1);

-- 3. Creăm clienții (legăm persoanele de tabela clienti)
INSERT INTO clienti (client_code, tip_client, persoana_fizica_id, persoana_juridica_id, status) 
VALUES 
('CLI-001', 'FIZIC', 1, NULL, 'ACTIVE'),
('CLI-002', 'JURIDIC', NULL, 1, 'ACTIVE');

-- 4. Creăm conturile bancare ALE CLIENȚILOR cu sold 0
INSERT INTO accounts (iban, client_id, account_type, currency, balance, status) 
VALUES 
('RO49AAAA1B31007593840000', 1, 'CURRENT', 'RON', 0, 'ACTIVE'),
('RO12BBBB2C42008604951111', 1, 'SAVINGS', 'EUR', 0, 'ACTIVE'),
('RO88CCCC3D53009715062222', 2, 'CURRENT', 'RON', 0, 'ACTIVE');

-- 5. Creăm conturile interne ale băncii (Casierie RON și Casierie EUR)
INSERT INTO accounts (iban, client_id, account_type, currency, balance, status) 
VALUES 
('RO99BANK0000000000000001', NULL, 'INTERNAL', 'RON', 1000000, 'ACTIVE'),
('RO99BANK0000000000000002', NULL, 'INTERNAL', 'EUR', 100000, 'ACTIVE');

-- 6. Creăm utilizatorii de aplicație (pentru login)
-- Hash-ul este pentru parola: "parola123" (generat cu BCrypt, cost factor 12)
INSERT INTO users_app (client_id, email, password_hash, status) 
VALUES 
(1, 'ion.popescu@email.com', '$2a$12$vJkIJeJJnPOlBtFUr3Ws7u3icF.6aEPjUut8CzalZSXfKH4hL7.JG', 'ACTIVE'),
(2, 'contact@techsolutions.ro', '$2a$12$vJkIJeJJnPOlBtFUr3Ws7u3icF.6aEPjUut8CzalZSXfKH4hL7.JG', 'ACTIVE');

-- 7. Adăugăm metode de contact
INSERT INTO metode_contact (cod, descriere) VALUES 
('EMAIL', 'Adresă de email'),
('TELEFON', 'Număr de telefon'),
('FAX', 'Număr de fax'),
('ADRESA', 'Adresă poștală');

-- 8. Adăugăm contacte pentru clienți
INSERT INTO contacte (client_id, metoda_contact_id, element_contact) 
VALUES 
(1, 1, 'ion.popescu@email.com'),
(1, 2, '+40712345678'),
(2, 1, 'contact@techsolutions.ro');