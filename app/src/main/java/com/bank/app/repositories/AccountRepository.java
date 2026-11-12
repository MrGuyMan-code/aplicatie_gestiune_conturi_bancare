package com.bank.app.repositories;

import com.bank.app.entities.Account;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface AccountRepository extends JpaRepository<Account, Long> {
    List<Account> findByClientId(Long clientId);
    Optional<Account> findByIban(String iban);
}