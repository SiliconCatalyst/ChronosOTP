import unittest
import ../src/engine/base32
import std/[random, strutils]

suite "Base32 Encoding/Decoding Tests":
  test "RFC 4648 Test Vectors":
    ## Test vectors from RFC 4648 section 10
    check:
      # Empty string
      encodeBase32(newSeq[byte]()) == ""
      decodeBase32("") == newSeq[byte]()

    # "f"
    let fBytes = @[0x66.byte] # 'f'
    check encodeBase32(fBytes) == "MY======"
    check decodeBase32("MY======") == fBytes
    check decodeBase32("MY") == fBytes # Without padding

    # "fo"
    let foBytes = @[0x66.byte, 0x6F] # "fo"
    check encodeBase32(foBytes) == "MZXQ===="
    check decodeBase32("MZXQ====") == foBytes

    # "foo"
    let fooBytes = @[0x66.byte, 0x6F, 0x6F] # "foo"
    check encodeBase32(fooBytes) == "MZXW6==="
    check decodeBase32("MZXW6===") == fooBytes

    # "foob"
    let foobBytes = @[0x66.byte, 0x6F, 0x6F, 0x62] # "foob"
    check encodeBase32(foobBytes) == "MZXW6YQ="
    check decodeBase32("MZXW6YQ=") == foobBytes

    # "fooba"
    let foobaBytes = @[0x66.byte, 0x6F, 0x6F, 0x62, 0x61] # "fooba"
    check encodeBase32(foobaBytes) == "MZXW6YTB"
    check decodeBase32("MZXW6YTB") == foobaBytes

    # "foobar"
    let foobarBytes = @[0x66.byte, 0x6F, 0x6F, 0x62, 0x61, 0x72] # "foobar"
    check encodeBase32(foobarBytes) == "MZXW6YTBOI======"
    check decodeBase32("MZXW6YTBOI======") == foobarBytes

  test "Round-trip encoding/decoding":
    ## Test random data round-trip

    randomize()

    for length in [0, 1, 2, 5, 8, 10, 16, 20, 32]:
      var randomBytes = newSeq[byte](length)

      for i in 0 ..< length:
        randomBytes[i] = byte(rand(255))

      let encoded = encodeBase32(randomBytes)
      let decoded = decodeBase32(encoded)

      check decoded == randomBytes
      echo "  ✅ Round-trip passed for length ", length

  test "Case insensitivity":
    ## Base32 should be case-insensitive
    let bytes = @[0x48.byte, 0x65, 0x6C, 0x6C, 0x6F] # "Hello"
    let encodedUpper = "JBSWY3DP"

    check:
      decodeBase32("JBSWY3DP") == bytes
      decodeBase32("jbswy3dp") == bytes # Lowercase
      decodeBase32("JbSwY3dP") == bytes # Mixed case

    # Decode should normalize to uppercase in our implementation
    # (But we accept any case)

  test "Whitespace handling":
    ## Should ignore whitespace
    let bytes = @[0x48.byte, 0x65, 0x6C, 0x6C, 0x6F]

    check:
      decodeBase32("JBSW Y3DP") == bytes
      decodeBase32("JBSW\nY3DP") == bytes
      decodeBase32("  JBSWY3DP  ") == bytes
      decodeBase32("JBS\tWY3\nDP\r") == bytes

  test "Padding variations":
    ## Should handle different padding scenarios
    let bytes = @[0x66.byte, 0x6F, 0x6F, 0x62, 0x61] # "fooba"

    check:
      decodeBase32("MZXW6YTB") == bytes # No padding
      decodeBase32("MZXW6YTB=") == bytes # Extra padding
      decodeBase32("MZXW6YTB======") == bytes # Full block padding
      decodeBase32("MZXW6YTB\n======") == bytes # Padding with whitespace

  test "Invalid characters raise ValueError":
    ## Should reject non-Base32 characters
    expect ValueError:
      discard decodeBase32("JBSWY3D!") # '!' invalid
      discard decodeBase32("JBSWY3D0") # '0' invalid (not in alphabet)
      discard decodeBase32("JBSWY3D1") # '1' invalid
      discard decodeBase32("JBSWY3D8") # '8' invalid
      discard decodeBase32("JBSWY3D9") # '9' invalid

  test "TOTP-style secret generation length":
    ## TOTP secrets are typically 16, 26, or 32 chars
    let testLengths = [10, 16, 26, 32]

    for length in testLengths:
      # Create dummy bytes of appropriate length
      let bytes = newSeq[byte](length)
      let encoded = encodeBase32(bytes)

      # Check encoded length (each byte = 8 bits, each Base32 char = 5 bits)
      let expectedChars = (length * 8 + 4) div 5 # Ceiling division

      # Remove padding for check
      var encodedNoPad = encoded
      while encodedNoPad.len > 0 and encodedNoPad[^1] == '=':
        encodedNoPad.setLen(encodedNoPad.len - 1)

      check encodedNoPad.len == expectedChars
      echo "  ✅ TOTP length ", length, " bytes → ", encodedNoPad.len, " chars"

  test "Encode/decode with known TOTP secret":
    ## Test with actual TOTP secret example
    # Example from RFC 6238 Appendix B
    let secretBytes = @[
      0x31.byte, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33,
      0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30,
    ]

    let encoded = encodeBase32(secretBytes)

    # Note: This is what the secret would look like in a QR code
    check encoded == "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"

    let decoded = decodeBase32(encoded)
    check decoded == secretBytes

  test "Partial last byte handling":
    ## Edge case: input not multiple of 5 bits
    # 1 byte = 8 bits → 2 Base32 chars (10 bits) with 2 bits leftover
    let oneByte = @[0xFF.byte]
    let encoded = encodeBase32(oneByte)

    # First 5 bits: 0b11111 = 31 = '7'
    # Next 3 bits + 2 zero padding: 0b11100 = 28 = '4'
    # Plus padding
    check encoded == "74======"

    let decoded = decodeBase32(encoded)
    check decoded == oneByte

# Run all tests
when isMainModule:
  # Set up test output
  echo "Running Base32 tests..."
  echo "=".repeat(50)
