# data-validation-project

## Project: Financial Transaction Data Processing Pipeline

### Overview:

Create a system that receives financial transaction data via SFTP, processes it,
validates it, and stores it in a database while monitoring for potential fraud
patterns. This will give you experience with all the required technologies in a
realistic context. Here's the project broken down into implementable stages:

1. <strong>SFTP Server Setup & Data Reception</strong>

<li>Set up an SFTP server using AWS Transfer Family Create an S3 bucket to receive
incoming files Configure IAM roles and permissions for secure access</li>
<li>Create an S3 bucket to receive incoming files</li>
<li>Configure IAM roles and permissions for secure access</li>
<li>Create a Public SSH Key for User</li>

In your Ubuntu terminal:

```sh
ssh-keygen -m PEM -f sftp1user
```

<li>Connect to your SFTP server</li>

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

<li>Cleaning Resources in AWS</li>
It's always a good practice to review your cloud resources to make sure you are not being charged.
Stop and Delete your server in AWS Transfer Family. Empty and Delete your bucket in S3. Delete the role(s), policies and Users from IAM.

Video tutorial for step 1: https://www.youtube.com/watch?v=bgP9rtAH_YQ
