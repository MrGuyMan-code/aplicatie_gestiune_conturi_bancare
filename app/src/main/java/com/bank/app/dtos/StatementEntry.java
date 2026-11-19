package com.bank.app.dtos;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record StatementEntry(
    LocalDateTime date,
    String description,
    String otherIban, // <--- Adăugat
    BigDecimal amount,
    String type // "DEBIT" sau "CREDIT"
) {}