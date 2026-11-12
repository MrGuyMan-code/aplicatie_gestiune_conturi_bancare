package com.bank.app.repositories;

import java.time.LocalDateTime;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.bank.app.entities.AccountBalanceSnapshot;

public interface AccountBalanceSnapshotRepository extends JpaRepository<AccountBalanceSnapshot, Long> {
    Optional<AccountBalanceSnapshot> findTopByAccountIdAndSnapshotDatetimeLessThanOrderBySnapshotDatetimeDesc(
            Long accountId, LocalDateTime date);
}
