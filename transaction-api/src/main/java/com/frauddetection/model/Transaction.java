package com.frauddetection.model;

import lombok.Data;
import javax.validation.constraints.NotNull;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Transaction {
    @NotNull
    private String transactionId;

    @NotNull
    private BigDecimal amount;

    @NotNull
    private String customerName;

    @NotNull
    private LocalDateTime transactionDate;

    @NotNull
    private String merchantName;

    @NotNull
    private String location;
}