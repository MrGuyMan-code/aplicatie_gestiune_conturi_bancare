package com.bank.app.services;

import com.bank.app.dtos.TransferRequest;
import com.bank.app.dtos.TransferResponse;
import com.bank.app.entities.*;
import com.bank.app.repositories.*;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
public class TransferService {

    private final AccountRepository accountRepository;
    private final UserAppRepository userAppRepository;
    private final TransactionsColdRepository transactionsColdRepository;
    private final TransactionsHotRepository transactionsHotRepository;
    private final LedgerEntryRepository ledgerEntryRepository;

    public TransferService(AccountRepository accountRepository,
                           UserAppRepository userAppRepository,
                           TransactionsColdRepository transactionsColdRepository,
                           TransactionsHotRepository transactionsHotRepository,
                           LedgerEntryRepository ledgerEntryRepository) {
        this.accountRepository = accountRepository;
        this.userAppRepository = userAppRepository;
        this.transactionsColdRepository = transactionsColdRepository;
        this.transactionsHotRepository = transactionsHotRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
    }

    @Transactional
    public TransferResponse executeTransfer(TransferRequest request) {
        
    	// Verifică idempotența
    	if (request.idempotencyKey() != null && !request.idempotencyKey().isEmpty()) {
    	    Optional<TransactionsCold> existing = transactionsColdRepository.findByIdempotencyKey(request.idempotencyKey());
    	    if (existing.isPresent()) {
    	        return new TransferResponse("Transfer deja efectuat.", existing.get().getTransactionRef());
    	    }
    	}
    	
    	// 1. Validări de bază
        if (request.amount() == null || request.amount().compareTo(BigDecimal.ZERO) <= 0) {
            throw new RuntimeException("Suma trebuie să fie mai mare decât zero.");
        }
        if (request.description() == null || request.description().trim().isEmpty()) {
            throw new RuntimeException("Descrierea este obligatorie.");
        }

        // 2. Extragem email-ul utilizatorului logat
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilizatorul nu există."));

        // 3. Căutăm conturile
        Account sourceAccount = accountRepository.findByIban(request.sourceIban())
                .orElseThrow(() -> new RuntimeException("Contul sursă nu există."));
        Account targetAccount = accountRepository.findByIban(request.targetIban())
                .orElseThrow(() -> new RuntimeException("Contul destinație nu există."));

        // 4. Verificăm că sursa aparține clientului logat
        if (!sourceAccount.getClientId().equals(userApp.getClientId())) {
            throw new RuntimeException("Nu ai permisiunea să transferi din acest cont.");
        }

        // 5. Verificăm statusul conturilor
        if (!"ACTIVE".equals(sourceAccount.getStatus())) {
            throw new RuntimeException("Contul sursă nu este activ.");
        }
        if (!"ACTIVE".equals(targetAccount.getStatus())) {
            throw new RuntimeException("Contul destinație nu este activ.");
        }

        // 6. Verificăm monedele
        if (!sourceAccount.getCurrency().equals(targetAccount.getCurrency())) {
            throw new RuntimeException("Transferurile între valute diferite nu sunt permise.");
        }

        // 7. Verificăm fondurile
        if (sourceAccount.getBalance().compareTo(request.amount()) < 0) {
            throw new RuntimeException("Fonduri insuficiente.");
        }

        // 8. Verificăm ca sursa != destinație
        if (sourceAccount.getId().equals(targetAccount.getId())) {
            throw new RuntimeException("Contul sursă și cel destinație nu pot fi identice.");
        }

        // 9. Generăm un transaction_ref
        String transactionRef = "BANK-TRF-" + LocalDate.now() + "-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        // 10. Creăm tranzacția în transactions_cold
        TransactionsCold txCold = new TransactionsCold();
        txCold.setTransactionRef(transactionRef);
        txCold.setTransactionType("TRF");
        txCold.setAmount(request.amount());
        txCold.setCurrency(sourceAccount.getCurrency());
        txCold.setSourceAccountId(sourceAccount.getId());
        txCold.setTargetAccountId(targetAccount.getId());
        txCold.setDescription(request.description());
        txCold.setEntryDatetime(LocalDateTime.now());
        txCold.setValueDate(LocalDate.now());
        txCold.setIdempotencyKey(null);
        txCold.setCreatedAt(LocalDateTime.now());

        // 11. Creăm starea în transactions_hot și o legăm de Cold
        TransactionsHot txHot = new TransactionsHot();
        txHot.setStatus("COMPLETED");
        txHot.setPostingDatetime(LocalDateTime.now());
        txHot.setFailureReason(null);
        txHot.setReversedByTransactionId(null);
        txHot.setUpdatedAt(LocalDateTime.now());
        txHot.setTransactionsCold(txCold); // legătura
        txCold.setTransactionsHot(txHot);  // legătura inversă

        // 12. Salvăm tranzacția (cascada salvează și Hot)
        txCold = transactionsColdRepository.save(txCold); 
        // ACUM txCold.getId() NU mai e null!

        // 13. Inserăm cele două intrări în ledger
        // Debit pe contul sursă
        LedgerEntry debit = new LedgerEntry();
        debit.setTransactionId(txCold.getId()); // <--- Acum e ID valid
        debit.setAccountId(sourceAccount.getId());
        debit.setAmount(request.amount().negate());
        debit.setEntryType("DEBIT");
        debit.setCurrency(sourceAccount.getCurrency());
        debit.setCreatedAt(LocalDateTime.now());
        debit.setDeleted(false);
        ledgerEntryRepository.save(debit);

        // Credit pe contul destinație
        LedgerEntry credit = new LedgerEntry();
        credit.setTransactionId(txCold.getId()); // <--- Acum e ID valid
        credit.setAccountId(targetAccount.getId());
        credit.setAmount(request.amount());
        credit.setEntryType("CREDIT");
        credit.setCurrency(sourceAccount.getCurrency());
        credit.setCreatedAt(LocalDateTime.now());
        credit.setDeleted(false);
        ledgerEntryRepository.save(credit);

        // 14. Actualizăm soldurile cache
        sourceAccount.setBalance(sourceAccount.getBalance().subtract(request.amount()));
        targetAccount.setBalance(targetAccount.getBalance().add(request.amount()));
        accountRepository.save(sourceAccount);
        accountRepository.save(targetAccount);
        
        // 15. Returnăm răspunsul
        return new TransferResponse("Transfer efectuat cu succes.", transactionRef);
    }
}