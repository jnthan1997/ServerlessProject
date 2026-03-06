


# ServerlessProject

### Project Architecture

```mermaid
graph TD
    subgraph Public_Internet [Public Internet]
        User((User Browser))
    end

    subgraph AWS_Edge [AWS Edge Locations]
        WAF[AWS WAF <br/><i>Rate Limiting & Security</i>]
        CF[CloudFront CDN]
        S3_Static[(S3 Bucket <br/><i>Static Assets</i>)]
    end

    subgraph AWS_VPC [AWS VPC - Private Region]
        Lambda[AWS Lambda <br/><i>Express.js Logic</i>]
        SM[Secrets Manager]
        RDS[(RDS MySQL <br/><i>Transactions</i>)]
    end

    subgraph Monitoring_Chaos [Monitoring & Chaos]
        Gremlin[Gremlin EC2 Agent]
        CW[CloudWatch Alarms]
        Budgets[AWS Budgets/SNS]
    end

    %% Connections
    User --> WAF
    WAF --> CF
    CF -- GET Assets --> S3_Static
    CF -- API Requests --> Lambda
    Lambda -- Fetch Secret --> SM
    Lambda -- Query --> RDS
    Gremlin -- Inject Chaos --> WAF
    CW -- Monitor --> Lambda
    Budgets -- Alert --> User


Serverless Crypto Sentinel 🛡️💰

A production-grade, serverless web application for simulated cryptocurrency management, built with a "Security-First" and "Resiliency-Always" mindset.
🚀 Overview

This project goes beyond a simple CRUD application. It is a full-stack serverless ecosystem designed to handle the volatility of crypto data and the unpredictability of cloud traffic. By integrating Chaos Engineering via Gremlin and Automated Governance, the application is built to stay performant and cost-effective under pressure.
🛠️ Tech Stack
Layer	Technologies
Frontend	Handlebars (HBS), CSS3, Vanilla JavaScript
Backend	Node.js, Express.js, Serverless-HTTP
Compute	AWS Lambda
Database	AWS RDS (MySQL) with Connection Pooling
Infrastructure	Terraform (IaC), AWS CloudFront, S3
Security	AWS WAF, Secrets Manager, JWT (Auth)
Resiliency	Gremlin (Chaos Engineering), CloudWatch Alarms
🛡️ Key Security Features

    Web Application Firewall (WAF): Configured with IP-based Rate Limiting (100 requests per 5 min) and AWS Managed Rules to prevent SQL Injection and XSS.

    Secret Management: Zero hardcoded credentials; database passwords are fetched at runtime via AWS Secrets Manager.

    Encapsulated Networking: The RDS instance lives in a private subnet, accessible only by the Lambda function within a secure VPC.

⛈️ Chaos Engineering: "Testing for Failure"

To ensure high availability, I used Gremlin as a Chaos Agent on an EC2 instance to run several experiments:

    Latency Injection: Added 2000ms delay to database queries to verify UI responsiveness and frontend timeout handling.

    Blackhole Attack: Severed the connection to the external Price API to test "Graceful Degradation" (showing cached data vs. crashing).

    WAF Stress Test: Simulated a bot attack to confirm that the Rate Limiter successfully blocks malicious IPs without affecting legitimate users.

📊 Cost & Governance

    AWS Budgets: Configured to send SNS alerts the moment forecasted monthly spend exceeds $10.

    Weekly Reports: A scheduled Lambda function queries AWS Cost Explorer and generates a JSON summary stored in S3 for dashboard visualization.

⚙️ Setup & Deployment

    Infrastructure: ```bash
    terraform init
    terraform apply -var="db_password=YOUR_SECURE_PASS"

    Lambda Deployment:
    Bash

    zip -r function.zip .
    aws lambda update-function-code --function-name CryptoBackend --zip-file fileb://function.zip

📈 Future Roadmap

    [ ] Implement RDS Proxy to handle larger connection spikes.

    [ ] Add a Redis/ElastiCache layer for ultra-fast price lookups.

    [ ] Develop a Multi-Region Failover strategy using Route 53 Health Checks.
