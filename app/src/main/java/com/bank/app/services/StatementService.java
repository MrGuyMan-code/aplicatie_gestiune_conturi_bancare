package com.bank.app.services;

import com.bank.app.entities.Account;
import com.bank.app.entities.AccountBalanceSnapshot;
import com.bank.app.entities.LedgerEntry;
import com.bank.app.repositories.AccountBalanceSnapshotRepository;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.LedgerEntryRepository;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class StatementService {

    private final AccountRepository accountRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final AccountBalanceSnapshotRepository snapshotRepository;

    public StatementService(AccountRepository accountRepository,
                            LedgerEntryRepository ledgerEntryRepository,
                            AccountBalanceSnapshotRepository snapshotRepository) {
        this.accountRepository = accountRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
        this.snapshotRepository = snapshotRepository;
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

    public List<LedgerEntry> getEntriesBetween(Long accountId, LocalDateTime start, LocalDateTime end) {
        return ledgerEntryRepository
                .findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(accountId, start, end);
    }
}