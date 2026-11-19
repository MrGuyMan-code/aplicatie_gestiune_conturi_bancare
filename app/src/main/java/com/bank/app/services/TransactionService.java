package com.bank.app.services;

import com.bank.app.dtos.TransactionDto;
import com.bank.app.entities.Account;
import com.bank.app.entities.LedgerEntry;
import com.bank.app.entities.TransactionsCold;
import com.bank.app.entities.UserApp;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.LedgerEntryRepository;
import com.bank.app.repositories.TransactionsColdRepository;
import com.bank.app.repositories.UserAppRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class TransactionService {

    private final AccountRepository accountRepository;
    private final UserAppRepository userAppRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final TransactionsColdRepository transactionsColdRepository;

    public TransactionService(AccountRepository accountRepository,
                              UserAppRepository userAppRepository,
                              LedgerEntryRepository ledgerEntryRepository,
                              TransactionsColdRepository transactionsColdRepository) {
        this.accountRepository = accountRepository;
        this.userAppRepository = userAppRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
        this.transactionsColdRepository = transactionsColdRepository;
    }

    public Page<TransactionDto> getTransactions(String iban, int page, int size) {
        // 1. Verificăm utilizatorul logat
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilizatorul nu există."));

        // 2. Căutăm contul și verificăm că aparține clientului
        Account account = accountRepository.findByIban(iban)
                .orElseThrow(() -> new RuntimeException("Contul nu există."));
        if (!account.getClientId().equals(userApp.getClientId())) {
            throw new RuntimeException("Nu ai acces la acest cont.");
        }

        // 3. Paginare: pagina 0, sortare descendentă după created_at
        PageRequest pageRequest = PageRequest.of(page, size, Sort.by("createdAt").descending());

        // 4. Luăm intrările din ledger
        Page<LedgerEntry> ledgerPage = ledgerEntryRepository.findByAccountId(account.getId(), pageRequest);

        // 5. Mapăm fiecare LedgerEntry la TransactionDto, luând descrierea din transactions_cold
        return ledgerPage.map(entry -> {
            TransactionsCold tx = transactionsColdRepository.findById(entry.getTransactionId()).orElse(null);
            String description = tx != null ? tx.getDescription() : "N/A";
            String ref = tx != null ? tx.getTransactionRef() : "N/A";
            return new TransactionDto(
                entry.getCreatedAt(),
                description,
                entry.getAmount(),
                entry.getEntryType(),
                ref
            );
        });
    }
}