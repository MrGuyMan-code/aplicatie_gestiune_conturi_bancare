package com.bank.app.repositories;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bank.app.entities.LedgerEntry;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;



public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, Long> {
    List<LedgerEntry> findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(
            Long accountId, LocalDateTime start, LocalDateTime end);
    
    Page<LedgerEntry> findByAccountId(Long accountId, Pageable pageable);
}
