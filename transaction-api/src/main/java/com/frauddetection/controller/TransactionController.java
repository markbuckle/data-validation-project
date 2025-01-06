package com.frauddetection.controller;

import com.frauddetection.model.Transaction;
import com.frauddetection.service.TransactionService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import javax.validation.Valid;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {
    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @PostMapping(
            consumes = {MediaType.APPLICATION_JSON_VALUE, MediaType.APPLICATION_XML_VALUE},
            produces = {MediaType.APPLICATION_JSON_VALUE}
    )
    public ResponseEntity<Transaction> createTransaction(
            @Valid @RequestBody Transaction transaction
    ) {
        Transaction processedTransaction = transactionService.processTransaction(transaction);
        return ResponseEntity.ok(processedTransaction);
    }
}