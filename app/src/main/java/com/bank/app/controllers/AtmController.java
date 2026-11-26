package com.bank.app.controllers;

import com.bank.app.dtos.AtmRequest;
import com.bank.app.dtos.AtmResponse;
import com.bank.app.services.AtmService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/atm")
public class AtmController {

    private final AtmService atmService;

    public AtmController(AtmService atmService) {
        this.atmService = atmService;
    }

    @PostMapping("/deposit")
    public ResponseEntity<?> deposit(@RequestBody AtmRequest request) {
        try {
            return ResponseEntity.ok(atmService.deposit(request));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/withdraw")
    public ResponseEntity<?> withdraw(@RequestBody AtmRequest request) {
        try {
            return ResponseEntity.ok(atmService.withdraw(request));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}