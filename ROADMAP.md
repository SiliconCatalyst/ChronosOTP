# ChronosOTP Development Roadmap

## Phase 1: Core TOTP Engine (C Backend)

```
src/engine/
├── base32.nim            # Base32 encoding/decoding (RFC 4648)
├── hmac.nim              # HMAC-SHA1 implementation
├── totp.nim              # TOTP logic orchestrator
└── secret_generator.nim  # Random secret generation
```

**Tests:**

```
tests/
├── test_base32.nim       # Test Base32 encode/decode roundtrip
├── test_hmac.nim         # Test HMAC-SHA1 against known vectors
├── test_totp.nim         # Test TOTP generation with known secrets
└── test_integration.nim  # End-to-end engine test
```

## Phase 2: HTTP Server (Backend API)

```
src/engine/
└── server.nim           # Jester HTTP server with REST API
```

**API Endpoints:**

- `GET /` → Serve index.html
- `GET /api/health` → Server status
- `POST /api/generate` → Generate new secret
- `POST /api/verify` → Verify TOTP code
- `GET /api/code/:secret` → Get current code for secret

**Tests:**

```
tests/
└── test_server.nim       # HTTP API tests
```

## Phase 3: Web Frontend (JS Backend)

```
src/viewer/
├── dom_utils.nim         # DOM manipulation helpers
├── main_ui.nim           # Main UI logic (compiles to JS)
├── qr_generator.nim      # QR code generation (otpauth://)
└── countdown_timer.nim   # 30-second countdown display
```

**Static Assets:**

```
src/
├── index.html            # Main HTML template
└── styles.css            # CSS styling
```

**Tests:**

```
tests/
└── test_viewer.nim       # Frontend logic tests (compile to JS)
```

## Phase 4: Build System & Integration

```
ChronosOTP/
├── ChronosOTP.nimble     # Package config with nimble tasks
├── build.nim             # Complex build automation
├── clean.nim             # Clean build artifacts
└── Makefile              # Alternative build system (optional)
```

## Phase 5: Production & Polish

```
src/
├── config.nim            # Configuration management
└── logging.nim           # Structured logging
```

**Documentation:**

```
docs/
├── API.md                # API documentation
├── ARCHITECTURE.md       # System architecture
└── DEVELOPMENT.md        # Development guide
```

## Phase 6: Advanced Features (Optional)

```
src/engine/
├── backup_codes.nim      # Generate backup codes
├── rate_limiter.nim      # API rate limiting
└── persistent_store.nim  # Secret storage (encrypted)
```

## Build Order Summary:

1. **Engine** → Test crypto works
2. **Server** → Test API works
3. **Frontend** → Test UI works
4. **Build System** → Automate everything
5. **Integration** → Test full system
6. **Polish** → Add config, logging, docs

## Verification Steps:

1. Engine generates correct TOTP codes
2. Server responds to API requests
3. Frontend displays QR codes and countdown
4. Full system: Scan QR in Authy → Codes match
5. Build system creates runnable package
