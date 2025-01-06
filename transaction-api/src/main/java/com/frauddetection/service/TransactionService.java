package com.frauddetection.service;

import com.frauddetection.model.Transaction;
import org.springframework.stereotype.Service;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.model.PutItemRequest;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;
import java.util.HashMap;
import java.util.Map;

@Service
public class TransactionService {
    private final AmazonDynamoDB dynamoDBClient;

    public TransactionService(AmazonDynamoDB dynamoDBClient) {
        this.dynamoDBClient = dynamoDBClient;
    }

    public Transaction processTransaction(Transaction transaction) {
        // Convert to DynamoDB format
        Map<String, AttributeValue> item = new HashMap<>();
        item.put("transactionId", new AttributeValue(transaction.getTransactionId()));
        item.put("amount", new AttributeValue(transaction.getAmount().toString()));
        item.put("customerName", new AttributeValue(transaction.getCustomerName()));
        item.put("merchantName", new AttributeValue(transaction.getMerchantName()));
        item.put("location", new AttributeValue(transaction.getLocation()));

        // Store in DynamoDB
        PutItemRequest putItemRequest = new PutItemRequest()
                .withTableName("transactions")
                .withItem(item);
        dynamoDBClient.putItem(putItemRequest);

        return transaction;
    }
}