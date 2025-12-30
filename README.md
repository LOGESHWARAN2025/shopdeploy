# 🚀 ShopDeploy – Cloud-Native Full-Stack Deployment on AWS

ShopDeploy is a production-style cloud-native project demonstrating how to deploy
a full-stack application using modern AWS services.

---

## 🏗️ Architecture Overview

Frontend (S3 Static Website)  
⬇  
Application Load Balancer (ALB)  
⬇  
ECS Fargate (Dockerized Node.js API)  
⬇  
Amazon RDS (MySQL)

---

## 🧩 Tech Stack

### Backend
- Node.js + Express
- MySQL (mysql2)
- Docker

### Frontend
- Static HTML / CSS / JS
- Hosted on Amazon S3

### Infrastructure
- AWS ECS (Fargate)
- Application Load Balancer
- Amazon RDS (MySQL)
- Amazon ECR
- Terraform (IaC)
- GitHub Actions (CI/CD)

---

## 📐 Architecture Diagram

```mermaid
flowchart TD
    User -->|HTTPS| S3[S3 Frontend]
    S3 -->|API Request| ALB[Application Load Balancer]
    ALB --> ECS[ECS Fargate Tasks]
    ECS --> RDS[(MySQL RDS)]
