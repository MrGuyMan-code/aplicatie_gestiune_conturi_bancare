package com.bank.app.repositories;

import com.bank.app.entities.TransactionsCold;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface TransactionsColdRepository extends JpaRepository<TransactionsCold, Long> {
    @Query(value = "SELECT * FROM transactions_cold WHERE idempotency_key = :idempotencyKey LIMIT 1",
            nativeQuery = true)
	Optional<TransactionsCold> findByIdempotencyKey(@Param("idempotencyKey") String idempotencyKey);
}