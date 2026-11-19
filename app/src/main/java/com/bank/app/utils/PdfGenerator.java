package com.bank.app.utils;

import com.bank.app.entities.Account;
import com.bank.app.dtos.StatementEntry;
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
                              List<StatementEntry> entries) throws Exception {
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
        PdfPTable table = new PdfPTable(5);
        table.setWidthPercentage(100);
        table.addCell("Data");
        table.addCell("Descriere");
        table.addCell("Cont");
        table.addCell("Suma");
        table.addCell("Tip");

        for (StatementEntry entry : entries) {
        	table.addCell(entry.date().toLocalDate().toString());
            table.addCell(entry.description());
            table.addCell(entry.otherIban());
            table.addCell(entry.amount().toString());
            table.addCell(entry.type());
        }
        document.add(table);

        document.add(new Paragraph(" "));
        document.add(new Paragraph("Sold final: " + finalBalance + " " + account.getCurrency()));

        document.close();
        return out.toByteArray();
    }
}