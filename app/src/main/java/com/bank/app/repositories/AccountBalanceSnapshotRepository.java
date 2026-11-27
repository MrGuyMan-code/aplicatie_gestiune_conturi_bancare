package com.bank.app.repositories;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.bank.app.entities.AccountBalanceSnapshot;

public interface AccountBalanceSnapshotRepository extends JpaRepository<AccountBalanceSnapshot, Long> {
    @Query(value = "SELECT * FROM account_balance_snapshots " +
            "WHERE account_id = :accountId " +
            "AND snapshot_datetime < :date " +
            "ORDER BY snapshot_datetime DESC " +
            "LIMIT 1", nativeQuery = true)
	Optional<AccountBalanceSnapshot> findTopByAccountIdAndSnapshotDatetimeLessThanOrderBySnapshotDatetimeDesc(
			@Param("accountId") Long accountId, @Param("date") LocalDateTime date);
}
