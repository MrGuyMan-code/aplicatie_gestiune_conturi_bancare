package com.bank.app.repositories;

import com.bank.app.entities.UserApp;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface UserAppRepository extends JpaRepository<UserApp, Long> {
	@Query(value = "SELECT * FROM users_app WHERE email = :email LIMIT 1", nativeQuery = true)
    Optional<UserApp> findByEmail(@Param("email") String email);
}
