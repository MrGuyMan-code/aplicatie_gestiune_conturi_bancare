package com.bank.app.controllers;

import com.bank.app.entities.Account;
import com.lowagie.text.Document;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfWriter;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

import com.bank.app.entities.LedgerEntry;
import com.bank.app.services.StatementService;
import com.bank.app.utils.PdfGenerator;

@RestController
@RequestMapping("/api/statement")
public class StatementController {
	
	private final StatementService statementService;
    private final PdfGenerator pdfGenerator;
    
    public StatementController(StatementService statementService, PdfGenerator pdfGenerator) {
        this.statementService = statementService;
        this.pdfGenerator = pdfGenerator;
    }

    @GetMapping("/test")
    public ResponseEntity<byte[]> testPdf() {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();
            Document document = new Document();
            PdfWriter.getInstance(document, out);
            document.open();
            document.add(new Paragraph("Test PDF - Functioneaza!"));
            document.close();

            byte[] pdfBytes = out.toByteArray();

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "test.pdf");

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(pdfBytes);

        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
    
    @GetMapping
    public ResponseEntity<byte[]> generateStatement(
            @RequestParam("iban") String iban,
            @RequestParam("start") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate start,
            @RequestParam("end") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate end) {
        try {
            Account account = statementService.getAccountByIban(iban);

            LocalDateTime startDateTime = start.atStartOfDay();
            LocalDateTime endDateTime = end.atTime(23, 59, 59);

            BigDecimal initialBalance = statementService.calculateInitialBalance(account.getId(), startDateTime);
            List<LedgerEntry> entries = statementService.getEntriesBetween(account.getId(), startDateTime, endDateTime);

            BigDecimal finalBalance = initialBalance;
            for (LedgerEntry entry : entries) {
                finalBalance = finalBalance.add(entry.getAmount());
            }

            byte[] pdfBytes = pdfGenerator.generatePdf(account, start, end, initialBalance, finalBalance, entries);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_PDF);
            headers.setContentDispositionFormData("attachment", "extras_" + iban + ".pdf");

            return ResponseEntity.ok().headers(headers).body(pdfBytes);

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.internalServerError().build();
        }
    }
}