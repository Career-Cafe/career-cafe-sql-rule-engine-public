# SQL Rule Engine (Node.js)

A high-performance Node.js REST API for evaluating, normalizing, and verifying SQL queries against a PostgreSQL database. This service takes SQL queries, analyzes their AST using `node-sql-parser`, enforces syntax rules, and safely runs the query to verify accuracy against a predefined set of problems.

## 🚀 Features
- **SQL Normalization**: Automatically standardizes SQL queries using AST parsing.
- **Rule Engine**: Validates queries against best-practice rules (e.g., no blocked keywords, enforcing SELECT only).
- **Automated Evaluation**: Safely runs queries against isolated schemas (like `ecommerce`).
- **Smart Hashing**: Hashes expected query outputs securely for fast comparison.
- **Caching Mechanism**: Utilizes Redis for rapid, repeated evaluations of identical queries.
- **Fully Type-Safe**: Written in TypeScript using Express, Drizzle ORM, and Zod.

## 📚 Documentation
For complete step-by-step instructions on setting up this project from scratch, see the [Setup Guide](SETUP_GUIDE.md).

## 🛠️ Quick Start

### 1. Requirements
- Node.js (v20+ recommended)
- `pnpm` (Package Manager)
- PostgreSQL (Local or remote)
- Redis

### 2. Environment Setup
Create a `.env` file from the sample and fill in your connection strings:
```bash
cp .env.sample .env
```

### 3. Install & Seed
```bash
# Install dependencies
pnpm install

# Push the schema to your database
pnpm run db:push

# Seed the problems, expected results, and the database schemas
pnpm run db:seed
```

### 4. Start the Server
```bash
pnpm run dev
```
Server runs on `http://localhost:8000`. Test the API via `GET /api/health`.

## 📜 Scripts
- `pnpm run dev` - Start dev server with nodemon and tsx
- `pnpm run build` - Compile TypeScript to `./dist`
- `pnpm run db:seed` - Seeds database schemas, problems, and expected hashes
- `pnpm run db:push` - Synchronize Drizzle schema to the database
- `pnpm run db:studio` - Open Drizzle Studio to view database contents in the browser
