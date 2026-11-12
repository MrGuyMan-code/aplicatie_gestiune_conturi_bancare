package com.bank.app.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity
@Table(name = "ledger_entries")
public class LedgerEntry {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "transaction_id", nullable = false, unique = false)
    private Long transactionId;
    
    @Column(name = "account_id", nullable = false, unique = false)
    private Long accountId;
    
    @Column(name = "amount", nullable = false, unique = false)
    private BigDecimal amount;
    
    @Column(name = "entry_type", nullable = false, unique = false)
    private String entryType;
    
    @Column(name = "currency", nullable = false, unique = false )
    private String currency;
    
    @Column(name = "deleted", nullable = false, unique = false)
    private Boolean deleted;
    
    @Column(name = "created_at", nullable = false, unique = false)
    private LocalDateTime createdAt;
    
    public LedgerEntry() {
    	
    }
    
    public Long getId() {return id;}
    public void setId(Long id) {this.id = id;}
    
    public Long getTransactionId() {return transactionId;}
    public void setTransactionId(Long transactionId) {this.transactionId = transactionId;}
    
    public Long getAccountId() {return accountId;}
    public void setAccountId(Long accountId) {this.accountId = accountId;}
    
    public BigDecimal getAmount() {return amount;}
    public void setAmount(BigDecimal amount) {this.amount = amount;}
    
    public String getEntryType() {return entryType;}
    public void setEntryType(String entryType) {this.entryType = entryType;}
    
    public String getCurrency() {return currency;}
    public void setCurrency(String currency) {this.currency = currency;}
    
    public Boolean getDeleted() {return deleted;}
    public void setDeleted(Boolean deleted) {this.deleted = deleted;}
    
    public LocalDateTime getCreatedAt() {return createdAt;}
    public void setCreatedAt(LocalDateTime createdAt) {this.createdAt = createdAt;}
    
}


