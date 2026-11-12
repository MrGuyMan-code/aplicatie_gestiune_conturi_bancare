package com.bank.app.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "account_balance_snapshots")
public class AccountBalanceSnapshot {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "account_id", nullable = false, unique = false)
    private Long accountId;
    
    @Column(name = "snapshot_datetime", nullable = false, unique = false)
    private LocalDateTime snapshotDatetime;
    
    @Column(name = "snapshot_type", nullable = false, unique = false)
    private String snapshotType;
    
    @Column(name = "balance", nullable = false, unique = false)
    private BigDecimal balance;
    
    @Column(name = "currency", nullable = false, unique = false)
    private String currency;  
    
    @Column(name = "last_ledger_entry_id", nullable = true, unique = false)
    private Long lastLedgerEntryId;
    
    @Column(name = "last_ledger_created_at", nullable = true, unique = false)
    private LocalDateTime lastLedgerCreatedAt;
    
    @Column(name = "created_at", nullable = true, unique = false)
    private LocalDateTime createdAt;    
    
    public AccountBalanceSnapshot()
    {
    	
    }
    
    public Long getId() {return id;}
    public void setId(Long id) {this.id = id;}
    
    public Long getAccountId() {return accountId;}
    public void setAccountId(Long accountId) {this.accountId = accountId;}
    
    public LocalDateTime getSnapshotDatetime() {return snapshotDatetime;}
    public void setSnapshotDatetime(LocalDateTime snapshotDatetime) {this.snapshotDatetime = snapshotDatetime;}
    
    public String getSnapshotType() {return snapshotType;}
    public void setSnapshotType(String snapshotType) {this.snapshotType = snapshotType;}
    
    public BigDecimal getBalance() {return balance;}
    public void setBalance(BigDecimal balance) {this.balance = balance;}
    
    public String getCurrency() {return currency;}
    public void setCurrency(String currency) {this.currency = currency;}
    
    public Long getLastLedgerEntryId() {return lastLedgerEntryId;}
    public void setLastLedgerEntryId(Long lastLedgerEntryId) {this.lastLedgerEntryId = lastLedgerEntryId;}
    
    public LocalDateTime getLastLedgerCreatedAt() {return lastLedgerCreatedAt;}
    public void setLastLedgerCreatedAt(LocalDateTime lastLedgerCreatedAt) {this.lastLedgerCreatedAt = lastLedgerCreatedAt;}
    
    public LocalDateTime getCreatedAt() {return createdAt;}
    public void setCreatedAt(LocalDateTime createdAt) {this.createdAt = createdAt;}
}
