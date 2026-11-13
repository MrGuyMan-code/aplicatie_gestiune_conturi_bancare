package com.bank.app.entities;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "transactions_hot")
public class TransactionsHot {

    @Id
    @Column(name = "transaction_id")
    private Long transactionId;

    @Column(name = "status", nullable = false)
    private String status;

    @Column(name = "posting_datetime")
    private LocalDateTime postingDatetime;

    @Column(name = "failure_reason")
    private String failureReason;

    @Column(name = "reversed_by_transaction_id")
    private Long reversedByTransactionId;

    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;

    // Relația 1:1 către Cold
    // @MapsId înseamnă: PK-ul acestei entități este și FK către entitatea părinte
    @OneToOne(fetch = FetchType.LAZY)
    @MapsId
    @JoinColumn(name = "transaction_id")
    private TransactionsCold transactionsCold;
    
    public TransactionsHot() {
    }

    // Getters și Setters
    public Long getTransactionId() { return transactionId; }
    public void setTransactionId(Long transactionId) { this.transactionId = transactionId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getPostingDatetime() { return postingDatetime; }
    public void setPostingDatetime(LocalDateTime postingDatetime) { this.postingDatetime = postingDatetime; }

    public String getFailureReason() { return failureReason; }
    public void setFailureReason(String failureReason) { this.failureReason = failureReason; }

    public Long getReversedByTransactionId() { return reversedByTransactionId; }
    public void setReversedByTransactionId(Long reversedByTransactionId) { this.reversedByTransactionId = reversedByTransactionId; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    // Getter și setter pentru relația 1:1 cu TransactionsCold
    public TransactionsCold getTransactionsCold() {
        return transactionsCold;
    }

    public void setTransactionsCold(TransactionsCold transactionsCold) {
        this.transactionsCold = transactionsCold;
    }
}
