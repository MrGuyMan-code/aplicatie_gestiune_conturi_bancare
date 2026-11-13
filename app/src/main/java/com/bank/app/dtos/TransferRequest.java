package com.bank.app.dtos;

import java.math.BigDecimal;

public record TransferRequest(
    String sourceIban,
    String targetIban,
    BigDecimal amount,
    String description
) {}
