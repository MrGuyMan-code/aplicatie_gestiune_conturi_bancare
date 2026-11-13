package com.bank.app.entities;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions_cold")
public class TransactionsCold {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "transaction_ref", nullable = false, unique = true)
    private String transactionRef;

    @Column(name = "transaction_type", nullable = false)
    private String transactionType;

    @Column(name = "amount", nullable = false)
    private BigDecimal amount;

    @Column(name = "currency", nullable = false)
    private String currency;

    @Column(name = "source_account_id")
    private Long sourceAccountId;

    @Column(name = "target_account_id")
    private Long targetAccountId;

    @Column(name = "description")
    private String description;

    @Column(name = "entry_datetime", nullable = false)
    private LocalDateTime entryDatetime;

    @Column(name = "value_date", nullable = false)
    private LocalDate valueDate;

    @Column(name = "idempotency_key", unique = true)
    private String idempotencyKey;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    // Relația 1:1 către Hot
    // mappedBy = "transactionsCold" => câmpul din TransactionsHot care deține FK-ul
    @OneToOne(mappedBy = "transactionsCold", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private TransactionsHot transactionsHot;
    
    public TransactionsCold() {
    }

    // Getters și Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getTransactionRef() { return transactionRef; }
    public void setTransactionRef(String transactionRef) { this.transactionRef = transactionRef; }

    public String getTransactionType() { return transactionType; }
    public void setTransactionType(String transactionType) { this.transactionType = transactionType; }

    public BigDecimal getAmount() { return amount; }
    public void setAmount(BigDecimal amount) { this.amount = amount; }

    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }

    public Long getSourceAccountId() { return sourceAccountId; }
    public void setSourceAccountId(Long sourceAccountId) { this.sourceAccountId = sourceAccountId; }

    public Long getTargetAccountId() { return targetAccountId; }
    public void setTargetAccountId(Long targetAccountId) { this.targetAccountId = targetAccountId; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDateTime getEntryDatetime() { return entryDatetime; }
    public void setEntryDatetime(LocalDateTime entryDatetime) { this.entryDatetime = entryDatetime; }

    public LocalDate getValueDate() { return valueDate; }
    public void setValueDate(LocalDate valueDate) { this.valueDate = valueDate; }

    public String getIdempotencyKey() { return idempotencyKey; }
    public void setIdempotencyKey(String idempotencyKey) { this.idempotencyKey = idempotencyKey; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    // Getter și setter pentru relația 1:1 cu TransactionsHot
    public TransactionsHot getTransactionsHot() {
        return transactionsHot;
    }

    public void setTransactionsHot(TransactionsHot transactionsHot) {
        this.transactionsHot = transactionsHot;
    }
}