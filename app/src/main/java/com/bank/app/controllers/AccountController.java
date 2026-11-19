package com.bank.app.controllers;

import com.bank.app.dtos.AccountDto;
import com.bank.app.entities.Account;
import com.bank.app.entities.UserApp;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.UserAppRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    private final AccountRepository accountRepository;
    private final UserAppRepository userAppRepository;

    public AccountController(AccountRepository accountRepository, UserAppRepository userAppRepository) {
        this.accountRepository = accountRepository;
        this.userAppRepository = userAppRepository;
    }

    @GetMapping
    public ResponseEntity<List<AccountDto>> getMyAccounts() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilizatorul nu există."));

        List<Account> accounts = accountRepository.findByClientId(userApp.getClientId());

        List<AccountDto> accountDtos = accounts.stream()
                .map(acc -> new AccountDto(
                        acc.getIban(),
                        acc.getBalance().doubleValue(),
                        acc.getCurrency(),
                        acc.getAccountType()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(accountDtos);
    }
}