# ChronosOTP: A Full-Stack Nim Authenticator

A proof-of-concept TOTP (Time-based One-Time Password) system written entirely in **Nim**. This project demonstrates Nim's versatility by using the **C backend** for a secure core engine and the **JavaScript backend** for a reactive web interface.

## Project Overview

The goal is to recreate the logic behind apps like Google Authenticator. The project is split into two main components:

1.  **The Core (C Backend):** A CLI tool that handles the "Shared Secret" generation and the heavy lifting of the HMAC-SHA1 hashing algorithm.
2.  **The Web UI (JS Backend):** A frontend that renders QR codes for "enrollment" and provides a real-time countdown for the 6-digit codes.

---

## Architecture

### 1. The Engine (`core.nim`)

- **Target:** C Backend (`nim c core.nim`)
- **Responsibilities:**
  - Implementing the **Base32** encoding/decoding (the standard format for TOTP secrets).
  - Performing the **HMAC-SHA1** hash.
  - Extracting the 6-digit code using dynamic truncation.
- **Key Libraries:** `std/sha1`, `std/times`.

### 2. The Web Frontend (`app.nim`)

- **Target:** JS Backend (`nim js app.nim`)
- **Responsibilities:**
  - Interfacing with the browser's DOM.
  - Generating a `otpauth://` URI to create a QR code.
  - Updating the UI every second to show the "time remaining" before the code rotates.
- **Key Libraries:** `std/dom`, `std/jsffi`.

---

## Logical Workflow

1.  **Setup:** A random 16-character Secret Key is generated.
2.  **Enrollment:** The key is encoded into a QR code. You can scan this with a "real" app (like Authy) to verify your Nim implementation is mathematically correct.
3.  **Verification:** \* The user enters the code they see on the screen.
    - The system compares `user_input` against `generated_code`.
    - If they match, access is granted.

---

## Project Structure

```bash
chronos_otp/
├── chronos_otp.nimble   # Package config
├── index.html           # Base layout
├── styles.css           # Styling
├── src/
│   ├── engine/          # C Backend (Logic)
│   │   ├── base32.nim   # Secret decoding
│   │   ├── hmac.nim     # Crypto logic
│   │   └── totp.nim     # Orchestrator (The Engine)
│   └── viewer/          # JS Backend (UI)
│       ├── dom_utils.nim # DOM manipulation
│       └── main_ui.nim   # Entry point for JS
```

---

## Getting Started

### Prerequisites

- Nim 2.0+
- A C compiler (GCC/Clang) for the core engine.
