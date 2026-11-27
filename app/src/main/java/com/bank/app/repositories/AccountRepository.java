package com.bank.app.repositories;

import com.bank.app.entities.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Long> {
    @Query(value = "SELECT * FROM accounts WHERE client_id = :clientId", nativeQuery = true)
    List<Account> findByClientId(@Param("clientId") Long clientId);
    
    @Query(value = "SELECT * FROM accounts WHERE iban = :iban", nativeQuery = true)
    Optional<Account> findByIban(@Param("iban") String iban);
    
    @Query(value = "SELECT * FROM accounts WHERE account_type = :accountType AND currency = :currency", nativeQuery = true)
    List<Account> findByAccountTypeAndCurrency(@Param("accountType")  String accountType, @Param("currency") String currency);
}