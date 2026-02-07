# 🎧 SpotifyDB – Phase 4: Advanced Database Engineering (MySQL)

## 📌 Overview
**Phase 4** represents the most advanced layer of the SpotifyDB project.  
This phase focuses on **database engineering, administration, and performance concepts** commonly used in **production systems**.

It demonstrates hands-on experience with:
- Views & abstractions
- Stored Procedures & Cursors
- Window Functions (Analytics SQL)
- Transactions (TCL)
- Access Control (DCL)
- Triggers & Data Integrity

This phase positions the project at **intermediate–advanced backend / data engineer level**.

---

## 📂 Project Structure



---

## 🧠 Learning Objectives
This phase proves the ability to:

- Encapsulate logic using **views & procedures**
- Enforce **data integrity via triggers**
- Use **transaction control** for safety
- Apply **role-based access control**
- Perform **analytical queries using window functions**
- Handle **procedural SQL** using cursors & loops

---

## 👁️ SECTION 1: Views (20)
Views provide **readable, reusable, and secure abstractions** over complex joins.

### View Categories
- User analytics (activity, devices, subscriptions)
- Artist & album summaries
- Playlist & track statistics
- Revenue & advertiser insights
- Popularity rankings

### Examples
- `v_active_users`
- `v_album_track_stats`
- `v_user_recent_activity`
- `v_track_popularity_rank`
- `v_advertiser_spend`

✅ Demonstrates **logical modeling + reporting SQL**

---

## 🔁 SECTION 2: Cursors (Procedural SQL)
Cursors are implemented **inside stored procedures**, as required by MySQL.

### What’s Demonstrated
- Cursor declaration & lifecycle
- Row-by-row iteration
- Loop handling with handlers
- Logging via audit tables

### Example Use Cases
- Iterating users & artists
- Calculating per-entity aggregates
- Writing audit records
- Simulating background jobs

📌 Shows understanding of **procedural database logic**

---

## ⚙️ SECTION 3: Stored Procedures (20)
Stored procedures encapsulate **business logic directly inside the database**.

### Covered Operations
- User subscription flow
- Payments & refunds
- Playlist creation & updates
- Track & podcast management
- Ticket booking
- Bulk operations
- Data cleanup jobs

### Highlights
- Parameterized procedures
- Conditional logic
- Loops & calculations
- Safe updates & inserts

💡 Interview signal: *“I know when logic belongs in DB vs app layer”*

---

## 📊 SECTION 4: Window Functions (20)
Uses **MySQL 8+ analytical SQL features**.

### Functions Used
- `RANK`, `DENSE_RANK`, `ROW_NUMBER`
- `NTILE`
- `LAG`, `LEAD`
- `PERCENT_RANK`, `CUME_DIST`
- Running totals & sliding windows

### Business Analytics Examples
- Track popularity ranking
- Artist quartiles by listeners
- Playlist growth analysis
- Cumulative streams & plays
- Lifetime value calculations

📈 Shows **data analyst + BI-ready SQL skills**

---

## 🔐 SECTION 5: DCL & TCL (20)
Demonstrates **database security and transaction control**.

### DCL (Security)
- Users & roles
- Grant / revoke permissions
- Procedure-level access
- View-level security

### TCL (Transactions)
- `START TRANSACTION`
- `SAVEPOINT`
- `ROLLBACK`
- `COMMIT`
- Table locks
- Autocommit control

🔒 Shows **production-safe database handling**

---

## 🚨 SECTION 6: Triggers (20)
Triggers enforce **data validation, auditing, and automation**.

### Trigger Types
- BEFORE INSERT / UPDATE / DELETE
- AFTER INSERT / UPDATE / DELETE

### Real-World Use Cases
- Prevent invalid data
- Auto-update aggregates
- Maintain consistency
- Write audit logs
- Enforce business rules

### Examples
- Prevent deleting verified artists
- Block negative pricing
- Sync subscriptions after payment
- Track playlist integrity

🧠 Demonstrates **deep understanding of DB constraints**

---

## 🛠️ Technologies
- **MySQL 8+**
- SQL (DDL, DML, DCL, TCL)
- Window functions
- Stored procedures
- Triggers
- Roles & permissions

---

## 💼 Ideal For
- Backend Developer roles
- Data Engineer roles
- SQL / MySQL interviews
- Academic capstone projects
- GitHub portfolio

---

## 👤 Author
**Mahak Sharma**  
Skills:  
SQL (Advanced), MySQL, Power BI, Advanced Excel, Frontend Development, AI Fundamentals

---

## ⭐ Final Note
Phase-4 transforms SpotifyDB into a **full database system**, not just a query project.

Combined with:
- Phase-2 (Schema)
- Phase-3 (Advanced SQL)

👉 This becomes a **complete, interview-ready SQL portfolio**.
