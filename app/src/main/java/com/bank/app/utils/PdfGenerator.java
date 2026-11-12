package com.bank.app.utils;

import com.bank.app.entities.Account;
import com.bank.app.entities.LedgerEntry;
import com.lowagie.text.Document;
import com.lowagie.text.FontFactory;
import com.lowagie.text.Paragraph;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import org.springframework.stereotype.Component;

import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Component
public class PdfGenerator {

    public byte[] generatePdf(Account account, LocalDate start, LocalDate end,
                              BigDecimal initialBalance, BigDecimal finalBalance,
                              List<LedgerEntry> entries) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        Document document = new Document();
        PdfWriter.getInstance(document, out);
        document.open();

        // Antet
        document.add(new Paragraph("EXTRAS DE CONT", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18)));
        document.add(new Paragraph("IBAN: " + account.getIban()));
        document.add(new Paragraph("Perioada: " + start + " - " + end));
        document.add(new Paragraph(" "));
        document.add(new Paragraph("Sold initial: " + initialBalance + " " + account.getCurrency()));
        document.add(new Paragraph(" "));

        // Tabel cu tranzacții
        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.addCell("Data");
        table.addCell("Descriere");
        table.addCell("Suma");
        table.addCell("Tip");

        for (LedgerEntry entry : entries) {
            table.addCell(entry.getCreatedAt().toLocalDate().toString());
            table.addCell("Tranzactie"); // Momentan generic
            table.addCell(entry.getAmount().toString());
            table.addCell(entry.getEntryType());
        }
        document.add(table);

        document.add(new Paragraph(" "));
        document.add(new Paragraph("Sold final: " + finalBalance + " " + account.getCurrency()));

        document.close();
        return out.toByteArray();
    }
}