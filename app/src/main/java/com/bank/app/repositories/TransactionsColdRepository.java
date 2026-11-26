package com.bank.app.repositories;

import com.bank.app.entities.TransactionsCold;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionsColdRepository extends JpaRepository<TransactionsCold, Long> {
	
	Optional<TransactionsCold> findByIdempotencyKey(String idempotencyKey);
}