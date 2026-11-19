package com.bank.app.dtos;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record TransactionDto(
    LocalDateTime date,
    String description,
    BigDecimal amount,
    String type,
    String transactionRef,
    String otherIban
) {}