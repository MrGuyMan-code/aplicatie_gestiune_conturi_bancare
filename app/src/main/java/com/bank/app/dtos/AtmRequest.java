package com.bank.app.dtos;

import java.math.BigDecimal;

public record AtmRequest(
    String iban,
    BigDecimal amount
) {}