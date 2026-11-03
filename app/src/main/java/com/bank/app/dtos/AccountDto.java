package com.bank.app.dtos;

public record AccountDto(String iban, Double balance, String currency, String type) {}