package com.bank.app.services;

import com.bank.app.dtos.AtmRequest;
import com.bank.app.dtos.AtmResponse;
import com.bank.app.entities.*;
import com.bank.app.repositories.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class AtmService {

    private final AccountRepository accountRepository;
    private final UserAppRepository userAppRepository;
    private final TransactionsColdRepository transactionsColdRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public AtmService(AccountRepository accountRepository,
                      UserAppRepository userAppRepository,
                      TransactionsColdRepository transactionsColdRepository,
                      LedgerEntryRepository ledgerEntryRepository) {
        this.accountRepository = accountRepository;
        this.userAppRepository = userAppRepository;
        this.transactionsColdRepository = transactionsColdRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    // Caută contul intern ATM potrivit monedei
    private Account getAtmAccount(String currency) {
        List<Account> internalAccounts = accountRepository.findByAccountTypeAndCurrency("INTERNAL", currency);
        return internalAccounts.stream()
                .filter(acc -> acc.getIban().contains("ATM"))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("Contul intern ATM pentru " + currency + " nu există."));
    }

    @Transactional
    public AtmResponse deposit(AtmRequest request) {
        if (request.amount() == null || request.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Suma trebuie să fie mai mare decât zero.");
        }

        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilizatorul nu există."));

        Account clientAccount = accountRepository.findByIban(request.iban())
                .orElseThrow(() -> new RuntimeException("Contul clientului nu există."));
        if (!clientAccount.getClientId().equals(userApp.getClientId())) {
            throw new RuntimeException("Nu ai acces la acest cont.");
        }
        if (!"ACTIVE".equals(clientAccount.getStatus())) {
            throw new RuntimeException("Contul nu este activ.");
        }

        Account atmAccount = getAtmAccount(clientAccount.getCurrency());

        String ref = "ATM-DEP-" + LocalDate.now() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        TransactionsCold txCold = new TransactionsCold();
        txCold.setTransactionRef(ref);
        txCold.setTransactionType("DEP_ATM");
        txCold.setAmount(request.amount());
        txCold.setCurrency(clientAccount.getCurrency());
        txCold.setSourceAccountId(atmAccount.getId());
        txCold.setTargetAccountId(clientAccount.getId());
        txCold.setDescription("Depunere numerar la ATM");
        txCold.setEntryDatetime(LocalDateTime.now());
        txCold.setValueDate(LocalDate.now());
        txCold.setIdempotencyKey(null);
        txCold.setCreatedAt(LocalDateTime.now());

        TransactionsHot txHot = new TransactionsHot();
        txHot.setStatus("COMPLETED");
        txHot.setPostingDatetime(LocalDateTime.now());
        txHot.setUpdatedAt(LocalDateTime.now());
        txHot.setTransactionsCold(txCold);
        txCold.setTransactionsHot(txHot);

        txCold = transactionsColdRepository.save(txCold);

        LedgerEntry debit = new LedgerEntry();
        debit.setTransactionId(txCold.getId());
        debit.setAccountId(atmAccount.getId());
        debit.setAmount(request.amount().negate());
        debit.setEntryType("DEBIT");
        debit.setCurrency(clientAccount.getCurrency());
        debit.setCreatedAt(LocalDateTime.now());
        debit.setDeleted(false);
        ledgerEntryRepository.save(debit);

        LedgerEntry credit = new LedgerEntry();
        credit.setTransactionId(txCold.getId());
        credit.setAccountId(clientAccount.getId());
        credit.setAmount(request.amount());
        credit.setEntryType("CREDIT");
        credit.setCurrency(clientAccount.getCurrency());
        credit.setCreatedAt(LocalDateTime.now());
        credit.setDeleted(false);
        ledgerEntryRepository.save(credit);

        atmAccount.setBalance(atmAccount.getBalance().subtract(request.amount()));
        clientAccount.setBalance(clientAccount.getBalance().add(request.amount()));
        accountRepository.save(atmAccount);
        accountRepository.save(clientAccount);

        return new AtmResponse("Depunere efectuată cu succes.", ref);
    }

    @Transactional
    public AtmResponse withdraw(AtmRequest request) {
        if (request.amount() == null || request.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Suma trebuie să fie mai mare decât zero.");
        }

        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilizatorul nu există."));

        Account clientAccount = accountRepository.findByIban(request.iban())
                .orElseThrow(() -> new RuntimeException("Contul clientului nu există."));
        if (!clientAccount.getClientId().equals(userApp.getClientId())) {
            throw new RuntimeException("Nu ai acces la acest cont.");
        }
        if (!"ACTIVE".equals(clientAccount.getStatus())) {
            throw new RuntimeException("Contul nu este activ.");
        }
        if (clientAccount.getBalance().compareTo(request.amount()) < 0) {
            throw new RuntimeException("Fonduri insuficiente pentru retragere.");
        }

        Account atmAccount = getAtmAccount(clientAccount.getCurrency());

        String ref = "ATM-WDR-" + LocalDate.now() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        TransactionsCold txCold = new TransactionsCold();
        txCold.setTransactionRef(ref);
        txCold.setTransactionType("WDR_ATM");
        txCold.setAmount(request.amount());
        txCold.setCurrency(clientAccount.getCurrency());
        txCold.setSourceAccountId(clientAccount.getId());
        txCold.setTargetAccountId(atmAccount.getId());
        txCold.setDescription("Retragere numerar de la ATM");
        txCold.setEntryDatetime(LocalDateTime.now());
        txCold.setValueDate(LocalDate.now());
        txCold.setIdempotencyKey(null);
        txCold.setCreatedAt(LocalDateTime.now());

        TransactionsHot txHot = new TransactionsHot();
        txHot.setStatus("COMPLETED");
        txHot.setPostingDatetime(LocalDateTime.now());
        txHot.setUpdatedAt(LocalDateTime.now());
        txHot.setTransactionsCold(txCold);
        txCold.setTransactionsHot(txHot);

        txCold = transactionsColdRepository.save(txCold);

        LedgerEntry debit = new LedgerEntry();
        debit.setTransactionId(txCold.getId());
        debit.setAccountId(clientAccount.getId());
        debit.setAmount(request.amount().negate());
        debit.setEntryType("DEBIT");
        debit.setCurrency(clientAccount.getCurrency());
        debit.setCreatedAt(LocalDateTime.now());
        debit.setDeleted(false);
        ledgerEntryRepository.save(debit);

        LedgerEntry credit = new LedgerEntry();
        credit.setTransactionId(txCold.getId());
        credit.setAccountId(atmAccount.getId());
        credit.setAmount(request.amount());
        credit.setEntryType("CREDIT");
        credit.setCurrency(clientAccount.getCurrency());
        credit.setCreatedAt(LocalDateTime.now());
        credit.setDeleted(false);
        ledgerEntryRepository.save(credit);

        clientAccount.setBalance(clientAccount.getBalance().subtract(request.amount()));
        atmAccount.setBalance(atmAccount.getBalance().add(request.amount()));
        accountRepository.save(clientAccount);
        accountRepository.save(atmAccount);

        return new AtmResponse("Retragere efectuată cu succes.", ref);
    }
}