package com.bank.app.security;

import com.bank.app.entities.UserApp;
import com.bank.app.repositories.UserAppRepository;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    private final UserAppRepository userAppRepository;

    public CustomUserDetailsService(UserAppRepository userAppRepository) {
        this.userAppRepository = userAppRepository;
    }

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        UserApp userApp = userAppRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("User not found with email: " + email));

        return new User(
                userApp.getEmail(),
                userApp.getPasswordHash(),
                Collections.emptyList() // Momentan nu avem roluri (ex: ROLE_USER, ROLE_ADMIN)
        );
    }
}
