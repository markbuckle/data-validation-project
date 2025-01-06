## Project: Financial Transaction Data Processing Pipeline

### Overview:

Create a system that receives financial transaction data via SFTP, processes it,
validates it, and stores it in a database while monitoring for potential fraud
patterns. This will give you experience with all the required technologies in a
realistic context. Here's the project broken down into implementable stages:

### Steps:

<strong>1. SFTP Server Setup & Data Reception</strong>

<li>Set up an SFTP server using AWS Transfer Family</li>
<li>Create an S3 bucket to receive incoming files</li>
<li>Configure IAM roles and permissions for secure access</li>
<li>Create an S3 bucket to receive incoming files</li>
<li>Configure IAM roles and permissions for secure access</li>
<li>Create a Public SSH Key for User</li><br>

In your Ubuntu terminal:

```sh
ssh-keygen -m PEM -f sftp1user
```

<li>Connect to your SFTP server</li><br>

In your AWS console, go to Transfer Family -> Servers -> Server ID

Find the Server Endpoint name. Copy and paste it into the following bash
command:

```sh
sftp -i ~/.ssh/sftp1user sftp1user@s-e8ba9657e27146349.server.transfer.us-east-1.amazonaws.com
```

To test the connection, exit the server, create a random test file:

```sh
echo "Hello AWS Transfer Family!" > test.txt
```

Connect to the server again then run:

```sh
put test.txt
```

If successful, you should see something like: "Uploading test.txt to
/marks3bucketforftp/photo/test.txt"

Go to your AWS S3 bucket / folder and you should see the uploaded file(s) there.

<li>Cleaning Resources in AWS</li><br>

It's always a good practice to review your cloud resources to make sure you are
not being charged. Stop and Delete your server in AWS Transfer Family. Empty and
Delete your bucket in S3. Delete the role(s), policies and Users from IAM.<br>

Video tutorial for step 1: https://www.youtube.com/watch?v=bgP9rtAH_YQ

<strong>2. Data Processing Pipeline</strong>

<li>Create an EC2 instance running Linux</li><br>

Launch Instance Setup:

Go to EC2 Dashboard Click "Launch Instance" Give your instance a name (e.g.,
"Linux-Data-Processing-Server")

Choose an Amazon Machine Image (AMI):

Select "Amazon Linux 2023" (this is a good choice for learning as it's free tier
eligible) Stick with the default 64-bit (x86) architecture

Instance Type:

Choose "t2.micro" (free tier eligible) This is sufficient for learning and
development

Key Pair:

Click "Create new key pair" Name it (e.g., "data-processing-keypair") Select RSA
and .pem format Download the key pair file - you'll need this to connect to your
instance Store it securely as you can't download it again

Network Settings:

Create a new security group Allow SSH traffic from your IP Name the security
group (e.g., "data-processing-sg") Description: "Security group for data
processing EC2"

Configure Storage:

Default 8GB is fine for learning purposes Use gp3 volume type (it's the default)

Launch:

Review all settings Click "Launch Instance"

Once Launched:

Wait for the "Instance State" to show "Running" Check "Status Checks" - wait for
"2/2 checks passed"

Connect to Your Instance:

Select your instance Click "Connect".

First, let's verify your key file exists in the current directory:

```sh
ls data-processing-keypair.pem
```

Then, copy it to your .ssh directory:

```sh
cp data-processing-keypair.pem ~/.ssh/

ssh -i "data-processing-keypair.pem" ec2-user@your-instance-public-dns
```

Set the correct permissions if asked for:

```sh
chmod 600 ~/.ssh/data-processing-keypair.pem
```

Now try connecting:

```sh
ssh -i ~/.ssh/data-processing-keypair.pem ec2-user@ec2-3-81-122-235.compute-1.amazonaws.com
```

If this works, you're now successfully connected to your EC2 instance running
Amazon Linux 2023. This is where you'll be able to set up your data processing
scripts to handle the files that come in through your SFTP server.

<li>Write a bash script using grep/sed/awk to monitor the S3 bucket for new files, validate file formats, clean and standardize data, and generate processing logs</li><br>

With the EC2 connection alive, do the following steps in your Ubuntu terminal:

Create a directory for your scripts (while still connected to EC2):

```sh
mkdir -p ~/scripts
```

Change to that directory:

```sh
cd ~/scripts
```

Create the script file using nano editor

```sh
nano monitor_s3.sh
```

Write the code for your script and then save (ctrl + X), press Y to confirm
save, and enter to confirm the filename.

Make your file executable:

```sh
chmod +x monitor_s3.sh
```

Create necessary directories:

```sh
mkdir -p ~/temp_files
mkdir -p ~/logs
```

Run the script:

```sh
./monitor_s3.sh
```

You can verify the files made it to the processed folder with:

```sh
aws s3 ls s3://marks3bucketforftp/processed/photo/
```

Note that the first script:

1. created the processed/photo/ directory in your S3 bucket (that's the ETag
   output at the start)

2. For headshot.jpg:

<li>Downloaded from original location</li>
<li>Uploaded to processed folder</li>
<li>Cleaned up temp file</li>

3. For test.txt:

<li>Downloaded from original location</li>
<li>Uploaded to processed folder</li>
<li>Cleaned up temp file</li>

The second script:

<li>Monitors your S3 bucket every minute</li>
<li>Downloads new files </li>
<li>Validates the file format</li>
<li>Cleans and standardizes the data using awk</li>
<li>Generates detailed logs</li>
<li>Keeps track of processed files Uploads cleaned files back to S3</li>

You might want to customize:

<li>The validation function (validate_file) based on your expected file format </li>
<li>The cleaning function (clean_data) based on your data standardization needs </li>
<li>The sleep interval (currently 60 seconds)</li>
<li>The log format and location</li>
<li>The error handling</li>

If you're having problems with aws configure, you likely need to configure the
AWS credentials on your EC2 instance to allow it to access your S3 bucket.
However, instead of using aws configure, the best practice for EC2 instances is
to use an IAM Role. To set this up:

First, let's pause our script (Ctrl+C if it's still running) We need to create
an IAM Role and attach it to your EC2 instance:

Go to AWS Console Navigate to IAM Click "Roles" Click "Create role" Select "AWS
service" and "EC2" as the use case Add these permissions:

AmazonS3ReadOnlyAccess (for reading from your SFTP/S3 bucket) Add a custom
policy to write to your specific S3 bucket

Give the role a name like "EC2-S3-Processing-Role"

Attach the role to your EC2 instance:

Go to EC2 Dashboard Select your instance Click "Actions" Select "Security" →
"Modify IAM role" Choose the role we just created Click "Update IAM role"

### file visibility

Note that since we created monitor_s3.sh on your EC2 instance in the
/home/ec2-user/scripts directory, it's not automatically in your local VSCode or
other IDE folder.

You'll need to copy it from EC2 to your local machine. You can use the
<strong>scp (secure copy)</strong> command to copy from EC2 to your local
machine.

Open a new terminal in your local environment (not the EC2 connection) and run:

```sh
scp -i ~/.ssh/data-processing-keypair.pem ec2-user@ec2-3-81-122-235.compute-1.amazonaws.com:/home/ec2-user/scripts/monitor_s3.sh /mnt/c/Users/Marks-Desktop/Coding/data-validation-project
```

<strong>3. Data Storage & Transformation</strong>

<li>Set up an RDS instance with PostgreSQL</li>

- Go to AWS Console → RDS
- Click "Create database"
- Choose "Standard create"
- Select "PostgreSQL"
- For "Templates" choose "Free tier"
- Under "Settings":
  - DB instance identifier: transaction-monitoring-db
  - Master username: postgres
  - Master password: [create a secure password]
- Under "Instance configuration":
  - Select db.t3.micro (free tier eligible)
- Under "Storage":
  - Keep defaults for free tier (20 GB)
- Under "Connectivity":
  - VPC: Default VPC
  - Create new security group
  - Public access: Yes (for development)
- Click "Create database"

First, copy the SQL files to your EC2 instance:

```sh
scp -i ~/.ssh/data-processing-keypair.pem ./sql/* ec2-user@ec2-3-81-122-235.compute-1.amazonaws.com:/home/ec2-user/sql/
```

Connect to EC2:

```sh
ssh -i ~/.ssh/data-processing-keypair.pem ec2-user@ec2-3-81-122-235.compute-1.amazonaws.com
```

To install PostgreSQL client on your EC2 instance:

```sh
sudo yum install -y postgresql15
```

On EC2, execute the SQL files against RDS:

```sh
psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres -d postgres -f ~/sql/01_create_tables.sql
psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres -d postgres -f ~/sql/02_create_indexes.sql
```

To view your database tables and data, you can:

A) Direct PostgreSQL Connection via Command Line from your EC2 instance:

```sh
psql -h your-rds-endpoint.region.rds.amazonaws.com -U postgres -d postgres
psql -h transaction-monitoring-db.c98ei0y8k77n.us-east-1.rds.amazonaws.com -U postgres -d postgres
```

Once connected, you can:

- \dt # List all tables
- SELECT * FROM customers; # View data in a table
- \d customers # Describe table structure

B) Use a Database GUI Tool (recommended for easier visualization):

- pgAdmin (most popular for PostgreSQL)
- DBeaver (supports multiple databases)
- DataGrip by JetBrains

In my case I used pgAdmin. Once pgAdmin4 is installed:

- open it and right click on "servers" in the left panel.
- Select "Register" → "Server"
- In the "General" tab. Name: transaction-monitoring-db (or any name you prefer)

In the "Connection" tab, enter:

- Host name/address:
  transaction-monitoring-db.c98ei0y8k77n.us-east-1.rds.amazonaws.com (your RDS
  endpoint)
- Port: 5432
- Maintenance database: postgres
- Username: postgres
- Password: (the password you set when creating the RDS instance)

<li>Create tables for storing transaction data</li>

- Click the "query" button in the Object Explorer toolbar

- Copy and paste this SQL to insert sample data:

```sql
-- Insert customers again
INSERT INTO customers (name, email) VALUES
('John Smith', 'john.smith@email.com'),
('Sarah Johnson', 'sarah.j@email.com'),
('Michael Brown', 'mbrown@email.com'),
('Lisa Davis', 'lisa.davis@email.com'),
('James Wilson', 'jwilson@email.com');

INSERT INTO transactions (customer_id, amount, transaction_type, transaction_date, status, ip_address, device_id) VALUES
(1, 1500.00, 'PURCHASE', CURRENT_TIMESTAMP - INTERVAL '1 day', 'COMPLETED', '192.168.1.1', 'device_123'),
(2, 750.50, 'TRANSFER', CURRENT_TIMESTAMP - INTERVAL '2 days', 'COMPLETED', '192.168.1.2', 'device_456'),
(3, 2000.00, 'WITHDRAWAL', CURRENT_TIMESTAMP - INTERVAL '3 days', 'COMPLETED', '192.168.1.3', 'device_789'),
(1, 500.00, 'DEPOSIT', CURRENT_TIMESTAMP - INTERVAL '4 days', 'COMPLETED', '192.168.1.1', 'device_123'),
(4, 3000.00, 'PURCHASE', CURRENT_TIMESTAMP - INTERVAL '5 days', 'COMPLETED', '192.168.1.4', 'device_101');

INSERT INTO transaction_details (transaction_id, merchant_name, merchant_category, location) VALUES
(1, 'Amazon', 'Online Retail', 'Online'),
(2, 'Bank Transfer', 'Financial', 'ATM-NYC-001'),
(3, 'Chase ATM', 'Financial', 'ATM-LA-002'),
(4, 'Bank Deposit', 'Financial', 'BRANCH-NY-001'),
(5, 'Best Buy', 'Electronics', 'Store-SF-003');
```

Any time you need to verify the data was input correctly:

```sql
SELECT * FROM customers;
```

Or more specifically with commands like:

```sql
SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM transactions ORDER BY transaction_id;
SELECT * FROM transaction_details ORDER BY detail_id;
```

Ensure you use the correct table name above.

<li>Write SQL queries for data insertion and validation</li>

Next we'll try some more complex queries:

- Show all transactions with customer names and merchant details:

```sql
SELECT 
    c.name as customer_name,
    t.amount,
    t.transaction_type,
    td.merchant_name,
    td.location
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN transaction_details td ON t.transaction_id = td.transaction_id
ORDER BY t.transaction_date DESC;
```

- Find total transaction amount by merchant category:

```sql
SELECT 
    td.merchant_category,
    COUNT(*) as transaction_count,
    SUM(t.amount) as total_amount
FROM transactions t
JOIN transaction_details td ON t.transaction_id = td.transaction_id
GROUP BY td.merchant_category;
```

- Find customers with multiple queries:

```sql
SELECT 
    c.name,
    COUNT(*) as transaction_count,
    SUM(t.amount) as total_spent
FROM customers c
JOIN transactions t ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(*) > 1;
```

<li>Implement basic fraud detection queries</li>

- Multiple transactions from the same customer using the same device ID within a
  short time period:

```sql
SELECT 
    c.name,
    t.transaction_date,
    t.amount,
    t.device_id,
    t.transaction_type,
    td.merchant_name
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN transaction_details td ON t.transaction_id = td.transaction_id
WHERE t.customer_id IN (
    SELECT customer_id
    FROM transactions
    GROUP BY customer_id, device_id, DATE(transaction_date)
    HAVING COUNT(*) > 1
)
ORDER BY t.customer_id, t.transaction_date;
```

- Transactions above average amount (potential unusual spending):

```sql
WITH avg_amount AS (
    SELECT AVG(amount) as mean_amount, STDDEV(amount) as std_amount
    FROM transactions
)
SELECT 
    c.name,
    t.amount,
    t.transaction_type,
    td.merchant_name,
    td.location,
    t.transaction_date
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
JOIN transaction_details td ON t.transaction_id = td.transaction_id
CROSS JOIN avg_amount
WHERE t.amount > (mean_amount + 2 * std_amount);
```

- Multiple locations in a short timeframe (impossible travel):

```sql
SELECT 
    c.name,
    t1.transaction_date as first_transaction_time,
    td1.location as first_location,
    t2.transaction_date as second_transaction_time,
    td2.location as second_location,
    t1.amount as first_amount,
    t2.amount as second_amount
FROM transactions t1
JOIN transactions t2 ON t1.customer_id = t2.customer_id
JOIN transaction_details td1 ON t1.transaction_id = td1.transaction_id
JOIN transaction_details td2 ON t2.transaction_id = td2.transaction_id
JOIN customers c ON t1.customer_id = c.customer_id
WHERE t1.transaction_id < t2.transaction_id
    AND td1.location != td2.location
    AND t2.transaction_date - t1.transaction_date < INTERVAL '1 day';
```

- Frequent small transactions (potential card testing):

```sql
SELECT 
    c.name,
    COUNT(*) as transaction_count,
    AVG(t.amount) as avg_amount,
    MIN(t.transaction_date) as first_transaction,
    MAX(t.transaction_date) as last_transaction
FROM transactions t
JOIN customers c ON t.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(*) > 2 AND AVG(t.amount) < (SELECT AVG(amount) FROM transactions);
```

<strong>4. API & Integration Layer</strong>

Create a simple REST API using your preferred OOP language that:

<li>Accepts JSON payloads</li>
<li>Validates incoming data against XML schemas</li>
<li>Transforms data between different formats</li>
<li>Stores data in DynamoDB for rapid access</li>

There are numerous options for using an API framework including vanilla Python,
Flask, Django, Express.js (Node.js), Nest.js (Node.js), Spring Boot (Java),etc.

In our case we're going to use Spring Boot and Gradle.

Note that:

Gradle is used to:

<li>Manage dependencies</li>
<li>Build the project</li>
<li>Run tests</li>
<li>Package the application</li>

For API integration, we will use Gradle with Spring Boot.
