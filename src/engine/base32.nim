# Base32 encoding/decoding following RFC 4648
# Used for TOTP secret encoding/decoding
import std/strutils

# `*` means exported (public)
# `const` is compile-time constant, while `let` is runtime constant
const Base32Alphabet* = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"

proc encodeBase32*(data: openArray[byte]): string =
  ## Encodes binary data to Base32 string
  ##
  ## Args:
  ##  data: Binary data as sequence of bytes
  ##
  ## Returns:
  ##  Base32 encoded string
  ##
  ## Examples:
  ##  encodeBase32([0x48.byte, 0x65, 0x6C, 0x6C, 0x6F]) → "JBSWY3DP"

  # Initialize variables
  var buffer: int = 0
  var bitsRemaining: int = 0

  # `result` is implicit in Nim procs that return values

  for b in data:
    # Add byte to buffer (shift left 8 bits)
    buffer = (buffer shl 8) or b.int # casts b to an integer
    bitsRemaining += 8

    # While we have at least 5 bits, process them
    while bitsRemaining >= 5:
      bitsRemaining -= 5
      # Extract 5-bit chunk
      let index = (buffer shr bitsRemaining) and 0x1F # 0x1F = 31
      result.add(Base32Alphabet[index])

  # Handle remaining bits if any
  if bitsRemaining > 0:
    # Shift remaining bits to top of 5-bit chunk
    let index = (buffer shl (5 - bitsRemaining)) and 0x1F
    result.add(Base32Alphabet[index])
    # RFC 4648 padding with `=`
    while result.len mod 8 != 0:
      result.add('=')

proc decodeBase32*(encoded: string): seq[byte] =
  ## Decodes Base32 string back to binary data
  ##
  ## Args:
  ##  encoded: Base32 encoded string
  ##
  ## Returns:
  ##  Binary data as sequence of bytes
  ##
  ## Raises:
  ##  ValueError: if input containes invalid Base32 char

  # Clean the input string
  var clean = ""

  for char in encoded:
    case char
    of 'A' .. 'Z', '2' .. '7':
      clean.add(char)
    of 'a' .. 'z':
      clean.add(char.toUpperAscii())
    of '=':
      break
    of {' ', '\t', '\n', '\r'}:
      discard
    else:
      # Invalid character
      raise newException(
        ValueError,
        "Invalid Base32 character: '" & $char & "' (ASCII) " & $char.ord & ")",
      )

  # DEcode the clean string
  var buffer: int = 0
  var bitsStored: int = 0

  for char in clean:
    let value = Base32Alphabet.find(char)

    # Safety check (should not be triggered with our validation implemented above)
    if value < 0:
      raise newException(ValueError, "Invalid Base32 character in clean string")

    # Add 5 bits to buffer
    buffer = (buffer shl 5) or value
    bitsStored += 5

    # When we have at least 8 bits, extract a byte
    if bitsStored >= 8:
      bitsStored -= 8
      # Extract top 8 bits from buffer
      let byteValue = byte((buffer shr bitsStored) and 0xFF)
      result.add(byteValue)
