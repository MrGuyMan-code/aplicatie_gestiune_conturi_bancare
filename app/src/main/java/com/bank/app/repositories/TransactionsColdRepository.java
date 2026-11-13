package com.bank.app.repositories;

import com.bank.app.entities.TransactionsCold;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionsColdRepository extends JpaRepository<TransactionsCold, Long> {
}