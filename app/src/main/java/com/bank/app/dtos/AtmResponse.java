package com.bank.app.dtos;

public record AtmResponse(
    String message,
    String transactionRef
) {}