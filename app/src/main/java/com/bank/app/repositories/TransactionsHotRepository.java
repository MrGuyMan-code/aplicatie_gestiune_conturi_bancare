package com.bank.app.repositories;

import com.bank.app.entities.TransactionsHot;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TransactionsHotRepository extends JpaRepository<TransactionsHot, Long> {
}