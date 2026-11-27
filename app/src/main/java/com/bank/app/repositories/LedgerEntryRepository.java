package com.bank.app.repositories;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.bank.app.entities.LedgerEntry;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;



public interface LedgerEntryRepository extends JpaRepository<LedgerEntry, Long> {
    @Query(value = "SELECT * FROM ledger_entries " +
            "WHERE account_id = :accountId " +
            "AND created_at BETWEEN :start AND :end " +
            "ORDER BY created_at ASC", nativeQuery = true)
	List<LedgerEntry> findByAccountIdAndCreatedAtBetweenOrderByCreatedAtAsc(
			 @Param("accountId") Long accountId, @Param("start") LocalDateTime start, @Param("end") LocalDateTime end);
    
    @Query(value = "SELECT * FROM ledger_entries WHERE account_id = :accountId",
            countQuery = "SELECT COUNT(*) FROM ledger_entries WHERE account_id = :accountId",
            nativeQuery = true)
    Page<LedgerEntry> findByAccountId(@Param("accountId") Long accountId, Pageable pageable);
}
