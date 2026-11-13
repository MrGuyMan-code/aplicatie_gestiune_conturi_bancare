package com.bank.app.controllers;

import com.bank.app.dtos.TransferRequest;
import com.bank.app.dtos.TransferResponse;
import com.bank.app.services.TransferService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/transfer")
public class TransferController {

    private final TransferService transferService;

    public TransferController(TransferService transferService) {
        this.transferService = transferService;
    }

    @PostMapping
    public ResponseEntity<?> transfer(@RequestBody TransferRequest request) {
        try {
            TransferResponse response = transferService.executeTransfer(request);
            return ResponseEntity.ok(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}