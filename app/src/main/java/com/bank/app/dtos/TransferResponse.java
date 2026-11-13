package com.bank.app.dtos;

public record TransferResponse(
    String message,
    String transactionRef
) {}