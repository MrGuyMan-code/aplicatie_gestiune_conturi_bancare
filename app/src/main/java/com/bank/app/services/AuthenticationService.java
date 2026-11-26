package com.bank.app.services;

import com.bank.app.dtos.AccountDto;
import com.bank.app.dtos.LoginRequest;
import com.bank.app.dtos.LoginResponse;
import com.bank.app.entities.Account;
import com.bank.app.entities.UserApp;
import com.bank.app.repositories.AccountRepository;
import com.bank.app.repositories.UserAppRepository;
import com.bank.app.security.JwtService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class AuthenticationService {

    private final UserAppRepository userAppRepository;
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthenticationService(UserAppRepository userAppRepository,
                                 AccountRepository accountRepository,
                                 PasswordEncoder passwordEncoder,
                                 JwtService jwtService) {
        this.userAppRepository = userAppRepository;
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    public LoginResponse login(String email, String password) {
        // 1. Caută utilizatorul
        UserApp user = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Email sau parolă incorectă."));

        // 2. Verifică blocarea
        if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(LocalDateTime.now())) {
            Duration remaining = Duration.between(LocalDateTime.now(), user.getLockedUntil());
            long minutes = remaining.toMinutes();
            long seconds = remaining.toSecondsPart();
            throw new RuntimeException(String.format(
                "Ești trimis la cafea timp de %d minute și %d secunde.", minutes, seconds));
        }

        // 3. Verifică parola
        if (!passwordEncoder.matches(password, user.getPasswordHash())) {
            int failed = user.getFailedLoginCount() + 1;
            user.setFailedLoginCount(failed);
            if (failed >= 3) {
                user.setLockedUntil(LocalDateTime.now().plusMinutes(5));
                user.setFailedLoginCount(0); // resetăm contorul
                userAppRepository.save(user);
                throw new RuntimeException("Ai introdus parola greșită de 3 ori. Ești trimis la cafea timp de 5 minute.");
            }
            userAppRepository.save(user);
            throw new RuntimeException("Email sau parolă incorectă.");
        }

        // 4. Parolă corectă: resetăm contorul, actualizăm lastLogin, generăm token
        user.setFailedLoginCount(0);
        user.setLastLoginAt(LocalDateTime.now());
        userAppRepository.save(user);

        String token = jwtService.generateToken(email);
        List<Account> accounts = accountRepository.findByClientId(user.getClientId());
        List<AccountDto> accountDtos = accounts.stream()
                .map(acc -> new AccountDto(
                        acc.getIban(),
                        acc.getBalance().doubleValue(),
                        acc.getCurrency(),
                        acc.getAccountType()))
                .collect(Collectors.toList());

        return new LoginResponse(token, accountDtos);
    }
}