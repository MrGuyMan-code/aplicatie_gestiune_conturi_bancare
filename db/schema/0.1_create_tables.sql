
CREATE DATABASE IF NOT EXISTS sistem_bancar_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE sistem_bancar_db;


SET NAMES utf8mb4;
SET time_zone = '+00:00'; -- setez fusul orar (important pentru timestamp deoarece putem avea clienti de pe diferite fusuri orare)


-- 1. PERSOANE_FIZICE

CREATE TABLE persoane_fizice (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,	
    nume            VARCHAR(50)  NOT NULL,	-- numele de familie a persoanei
    prenume         VARCHAR(50)  NOT NULL,	-- prenumele persoanei
    cnp             CHAR(13)     NOT NULL,	
    adresa          VARCHAR(255) NULL,
    data_nasterii   DATE         NULL,
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),	-- data la care a fost adaugata aceasta persoana
    updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                 ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_pf_cnp (cnp),
    KEY idx_pf_nume_prenume (nume, prenume)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci; -- punem inno db ca sa putem face commituri desi este default de obicei

-- 2. PERSOANE_JURIDICE

CREATE TABLE persoane_juridice (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    denumire        VARCHAR(255) NOT NULL,	-- denumirea persoanei juridice
    cui             VARCHAR(20)  NOT NULL,	-- codul de identidicare
    adresa          VARCHAR(255) NULL,
    reprezentant_id BIGINT UNSIGNED NULL,	-- id-ul reprezentantului
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                 ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_pj_cui (cui),
    KEY idx_pj_denumire (denumire),
    KEY idx_pj_reprezentant (reprezentant_id),
    CONSTRAINT fk_pj_reprezentant
        FOREIGN KEY (reprezentant_id) REFERENCES persoane_fizice(id)
        ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 3. METODE_CONTACT (cauta: EMAIL, TELEFON, FAX, etc.)

CREATE TABLE metode_contact (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    cod             VARCHAR(20)  NOT NULL,
    descriere       VARCHAR(100) NULL,
    PRIMARY KEY (id),
    UNIQUE KEY uq_metode_cod (cod)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 4. CLIENTI (unifică persoane fizice și juridice)

CREATE TABLE clienti (
    id                      BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    client_code             VARCHAR(32)  NOT NULL,	-- codul clientului care e unic (poate in viitor va inlocui tabela id)
    tip_client              VARCHAR(10)  NOT NULL,
    persoana_fizica_id      BIGINT UNSIGNED NULL, -- id persoana fizica sau NULL 
    persoana_juridica_id    BIGINT UNSIGNED NULL, -- id persoana juridica sau NULL
    status                  VARCHAR(16)  NOT NULL DEFAULT 'ACTIVE',
    created_at              DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at              DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                         ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_clienti_code (client_code),
    KEY idx_clienti_tip (tip_client),
    KEY idx_clienti_status (status),
    KEY idx_clienti_pf (persoana_fizica_id),
    KEY idx_clienti_pj (persoana_juridica_id),
	CONSTRAINT fk_clienti_pf
	    FOREIGN KEY (persoana_fizica_id) REFERENCES persoane_fizice(id)
	    ON DELETE RESTRICT ON UPDATE RESTRICT,
	
	CONSTRAINT fk_clienti_pj
	    FOREIGN KEY (persoana_juridica_id) REFERENCES persoane_juridice(id)
	    ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_clienti_tip
        CHECK (tip_client IN ('FIZIC', 'JURIDIC')),
    CONSTRAINT chk_clienti_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'CLOSED')),
    CONSTRAINT chk_clienti_exact_one
        CHECK (
            (tip_client = 'FIZIC'
                AND persoana_fizica_id IS NOT NULL
                AND persoana_juridica_id IS NULL)
            OR
            (tip_client = 'JURIDIC'
                AND persoana_juridica_id IS NOT NULL
                AND persoana_fizica_id IS NULL)
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- 5. CONTACTE (un client poate avea mai multe contacte)

CREATE TABLE contacte (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    client_id           BIGINT UNSIGNED NOT NULL,
    metoda_contact_id   BIGINT UNSIGNED NOT NULL,
    element_contact     VARCHAR(255) NOT NULL,
    created_at          DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_contacte_client (client_id),
    KEY idx_contacte_metoda (metoda_contact_id),
    KEY idx_contacte_element (element_contact),
    CONSTRAINT fk_contacte_client
        FOREIGN KEY (client_id) REFERENCES clienti(id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_contacte_metoda
        FOREIGN KEY (metoda_contact_id) REFERENCES metode_contact(id)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 6. ACCOUNTS — conturile bancare

CREATE TABLE accounts (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    iban            VARCHAR(34)  NOT NULL,
    client_id       BIGINT UNSIGNED NOT NULL,
    account_type    VARCHAR(16)  NOT NULL,	-- tip cont
    currency        CHAR(3)      NOT NULL DEFAULT 'RON',
    balance         DECIMAL(20,4) NOT NULL DEFAULT 0.0000, -- am pus balanta cu mai multe 0 pentru a evita erori de rotunjire
    status          VARCHAR(16)  NOT NULL DEFAULT 'ACTIVE',
    opened_at       DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    closed_at       DATETIME(6)  NULL,
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                 ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_accounts_iban (iban),
    KEY idx_accounts_client (client_id),
    KEY idx_accounts_status (status),
    KEY idx_accounts_currency (currency),
    CONSTRAINT fk_accounts_client
        FOREIGN KEY (client_id) REFERENCES clienti(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_accounts_type
        CHECK (account_type IN ('CURRENT', 'SAVINGS', 'CREDIT')),
    CONSTRAINT chk_accounts_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'CLOSED')),
    CONSTRAINT chk_accounts_balance_non_negative
        CHECK (balance >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;



-- 7. TRANSACTION_SEQUENCES — contor pentru ID-ul compus (In versiunile ulterioare voi scapa de el)

CREATE TABLE transaction_sequences (
    node_code       VARCHAR(8)  NOT NULL,
    sequence_date   DATE        NOT NULL,
    current_value      BIGINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (node_code, sequence_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 8. TRANSACTIONS_COLD — date imutabile (nu se modifică niciodată)

CREATE TABLE transactions_cold (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    transaction_ref     VARCHAR(64)  NOT NULL,
    transaction_type    VARCHAR(16)  NOT NULL,
    amount              DECIMAL(20,4) NOT NULL,
    currency            CHAR(3)      NOT NULL DEFAULT 'RON',
    source_account_id   BIGINT UNSIGNED NULL,
    target_account_id   BIGINT UNSIGNED NULL,
    description         TEXT NULL,
    entry_datetime      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    value_date          DATE         NOT NULL,
    idempotency_key     VARCHAR(64)  NULL,
    created_at          DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_transactions_cold_ref (transaction_ref),
    UNIQUE KEY uq_transactions_cold_idempotency (idempotency_key),
    KEY idx_transactions_cold_type (transaction_type),
    KEY idx_transactions_cold_entry_dt (entry_datetime),
    KEY idx_transactions_cold_value_date (value_date),
    KEY idx_transactions_cold_source (source_account_id),
    KEY idx_transactions_cold_target (target_account_id),
    KEY idx_transactions_cold_ref_prefix (transaction_ref(20)),
	CONSTRAINT fk_transactions_cold_source
	    FOREIGN KEY (source_account_id) REFERENCES accounts(id)
	    ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT fk_transactions_cold_target
	    FOREIGN KEY (target_account_id) REFERENCES accounts(id)
	    ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT chk_transactions_cold_type
        CHECK (transaction_type IN ('TRF', 'DEP', 'WDR', 'FEE', 'INT', 'REV')),
    CONSTRAINT chk_transactions_cold_amount_positive
        CHECK (amount > 0),
    CONSTRAINT chk_transactions_cold_has_account
        CHECK (source_account_id IS NOT NULL OR target_account_id IS NOT NULL),
    CONSTRAINT chk_transactions_cold_source_diff_target
        CHECK (source_account_id IS NULL
            OR target_account_id IS NULL
            OR source_account_id <> target_account_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 9. TRANSACTIONS_HOT — date mutabile (starea curentă)

CREATE TABLE transactions_hot (
    transaction_id             BIGINT UNSIGNED NOT NULL,
    status                     VARCHAR(16)  NOT NULL DEFAULT 'PENDING',
    posting_datetime           DATETIME(6)  NULL,
    failure_reason             VARCHAR(255) NULL,
    reversed_by_transaction_id BIGINT UNSIGNED NULL,
    updated_at                 DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                            ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (transaction_id),
    KEY idx_transactions_hot_status (status),
    KEY idx_transactions_hot_posting_dt (posting_datetime),
    KEY idx_transactions_hot_reversed_by (reversed_by_transaction_id),
    CONSTRAINT fk_transactions_hot_cold
        FOREIGN KEY (transaction_id) REFERENCES transactions_cold(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_transactions_hot_reversed_by
        FOREIGN KEY (reversed_by_transaction_id) REFERENCES transactions_cold(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_transactions_hot_status
        CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED',
                          'FAILED', 'REVERSED')),
    CONSTRAINT chk_transactions_hot_failure_reason
        CHECK (
            (status = 'FAILED' AND failure_reason IS NOT NULL)
            OR
            (status <> 'FAILED')
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. LEDGER_ENTRIES — intrările contabile (la fiecare tranzactie reusita sunt 2 intrari ledger)

CREATE TABLE ledger_entries (
    id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    transaction_id  BIGINT UNSIGNED NOT NULL,
    account_id      BIGINT UNSIGNED NOT NULL,
    amount          DECIMAL(20,4) NOT NULL,
    entry_type      VARCHAR(8)   NOT NULL,
    currency        CHAR(3)      NOT NULL DEFAULT 'RON',
    created_at      DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    KEY idx_ledger_transaction (transaction_id),
    KEY idx_ledger_account (account_id),
    KEY idx_ledger_created (created_at),
    KEY idx_ledger_account_created (account_id, created_at),
    CONSTRAINT fk_ledger_transaction
        FOREIGN KEY (transaction_id) REFERENCES transactions_cold(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_ledger_account
        FOREIGN KEY (account_id) REFERENCES accounts(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_ledger_entry_type
        CHECK (entry_type IN ('DEBIT', 'CREDIT')),
    CONSTRAINT chk_ledger_amount_nonzero
        CHECK (amount <> 0),
    CONSTRAINT chk_ledger_amount_sign
        CHECK (
            (entry_type = 'DEBIT'  AND amount < 0) OR
            (entry_type = 'CREDIT' AND amount > 0)
        )
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 11 .USERS — conturile de aplicație ale clienților

CREATE TABLE users_app (
    id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    client_id           BIGINT UNSIGNED NOT NULL,
    email               VARCHAR(255) NOT NULL,
    password_hash       VARCHAR(255) NOT NULL,
    status              VARCHAR(16)  NOT NULL DEFAULT 'ACTIVE',
    last_login_at       DATETIME(6)  NULL,
    failed_login_count  INT UNSIGNED NOT NULL DEFAULT 0,
    locked_until        DATETIME(6)  NULL,
    created_at          DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    updated_at          DATETIME(6)  NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
                                     ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    UNIQUE KEY uq_users_email (email),
    UNIQUE KEY uq_users_client (client_id),
    KEY idx_users_status (status),
    CONSTRAINT fk_users_client
        FOREIGN KEY (client_id) REFERENCES clienti(id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_users_status
        CHECK (status IN ('ACTIVE', 'BLOCKED', 'CLOSED'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
