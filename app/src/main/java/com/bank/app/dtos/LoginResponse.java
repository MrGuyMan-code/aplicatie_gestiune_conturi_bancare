package com.bank.app.dtos;

import java.util.List;

public record LoginResponse(String token, List<AccountDto> accounts) {}