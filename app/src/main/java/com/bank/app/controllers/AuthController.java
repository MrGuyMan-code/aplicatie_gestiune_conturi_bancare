package com.bank.app.controllers;

import com.bank.app.dtos.*;
import com.bank.app.entities.UserApp;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.UserAppRepository;
import com.bank.app.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final UserAppRepository userAppRepository;
    private final AccountRepository accountRepository;

    public AuthController(AuthenticationManager authenticationManager,
                          JwtService jwtService,
                          UserAppRepository userAppRepository,
                          AccountRepository accountRepository) {
        this.authenticationManager = authenticationManager;
        this.jwtService = jwtService;
        this.userAppRepository = userAppRepository;
        this.accountRepository = accountRepository;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        try {
            // 1. Spring Security verifică email-ul și parola (cu BCrypt)
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.email(), request.password())
            );

            // 2. Dacă am ajuns aici, credențialele sunt corecte. Generăm token-ul.
            String token = jwtService.generateToken(request.email());

            // 3. Căutăm userul pentru a-i lua client_id
            UserApp userApp = userAppRepository.findByEmail(request.email()).orElseThrow();

            // 4. Luăm conturile clientului
            List<AccountDto> accounts = accountRepository.findByClientId(userApp.getClientId())
                    .stream()
                    .map(acc -> new AccountDto(
                            acc.getIban(),
                            acc.getBalance().doubleValue(),
                            acc.getCurrency(),
                            acc.getAccountType()
                    ))
                    .collect(Collectors.toList());

            // 5. Returnăm token-ul și conturile
            return ResponseEntity.ok(new LoginResponse(token, accounts));

        } catch (Exception e) {
            return ResponseEntity.status(401).body("Email sau parolă incorectă!");
        }
    }
}