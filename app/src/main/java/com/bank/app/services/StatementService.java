package com.bank.app.services;

import com.bank.app.dtos.StatementEntry;
import com.bank.app.entities.Account;
import com.bank.app.entities.AccountBalanceSnapshot;
import com.bank.app.entities.LedgerEntry;
import com.bank.app.entities.TransactionsCold;
import com.bank.app.repositories.AccountBalanceSnapshotRepository;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.LedgerEntryRepository;
import com.bank.app.repositories.TransactionsColdRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class StatementService {

    private final AccountRepository accountRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final AccountBalanceSnapshotRepository snapshotRepository;
    private final TransactionsColdRepository transactionsColdRepository; // <--- Adăugat

    public StatementService(AccountRepository accountRepository,
                            LedgerEntryRepository ledgerEntryRepository,
                            AccountBalanceSnapshotRepository snapshotRepository,
                            TransactionsColdRepository transactionsColdRepository) { // <--- Adăugat
        this.accountRepository = accountRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
        this.snapshotRepository = snapshotRepository;
        this.transactionsColdRepository = transactionsColdRepository;
    }

    public Account getAccountByIban(String iban) {
        return accountRepository.findByIban(iban)
                .orElseThrow(() -> new RuntimeException("Contul nu există"));
    }

    public BigDecimal calculateInitialBalance(Long accountId, LocalDateTime startDate) {
        Optional<AccountBalanceSnapshot> lastSnapshot = snapshotRepository
                .findTopByAccountIdAndSnapshotDatetimeLessThanOrderBySnapshotDatetimeDesc(accountId, startDate);

        BigDecimal initialBalance;
        LocalDateTime snapshotTime;

        if (lastSnapshot.isPresent()) {
            AccountBalanceSnapshot snapshot = lastSnapshot.get();
            initialBalance = snapshot.getBalance();
            snapshotTime = snapshot.getSnapshotDatetime();
        } else {
            initialBalance = BigDecimal.ZERO;
            snapshotTime = LocalDateTime.MIN;
        }

        List<LedgerEntry> entriesBetween = ledgerEntryRepository
                .findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(
                        accountId, snapshotTime, startDate);

        for (LedgerEntry entry : entriesBetween) {
            initialBalance = initialBalance.add(entry.getAmount());
        }

        return initialBalance;
    }

    // Metoda veche rămâne (dacă o mai folosești)
    public List<LedgerEntry> getEntriesBetween(Long accountId, LocalDateTime start, LocalDateTime end) {
        return ledgerEntryRepository
                .findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(accountId, start, end);
    }

    // METODA NOUĂ: returnează List<StatementEntry> cu IBAN-ul celuilalt cont
    public List<StatementEntry> getStatementEntries(Long accountId, LocalDateTime start, LocalDateTime end) {
        List<LedgerEntry> ledgerEntries = ledgerEntryRepository
                .findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(accountId, start, end);

        return ledgerEntries.stream().map(entry -> {
            TransactionsCold tx = transactionsColdRepository.findById(entry.getTransactionId()).orElse(null);
            
            String description = "N/A";
            String otherIban = "N/A";
            
            if (tx != null) {
                String txType = tx.getTransactionType();
                
                switch (txType) {
                    case "DEP_CASH":
                    case "DEP_ATM":
                        description = "Depunere numerar";
                        break;
                    case "WDR_CASH":
                    case "WDR_ATM":
                        description = "Retragere numerar";
                        break;
                    case "TRF":
                        description = tx.getDescription() != null ? tx.getDescription() : "Transfer";
                        break;
                    default:
                        description = tx.getDescription() != null ? tx.getDescription() : "Tranzacție";
                        break;
                }
                
                Long otherAccountId = null;
                if ("DEBIT".equals(entry.getEntryType())) {
                    otherAccountId = tx.getTargetAccountId();
                } else {
                    otherAccountId = tx.getSourceAccountId();
                }
                
                if (otherAccountId != null) {
                    Account otherAccount = accountRepository.findById(otherAccountId).orElse(null);
                    if (otherAccount != null) {
                        otherIban = otherAccount.getIban();
                    }
                }
            }
            
            return new StatementEntry(
                entry.getCreatedAt(),
                description,
                otherIban,
                entry.getAmount(),
                entry.getEntryType()
            );
        }).collect(Collectors.toList());
    }
}