#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <qrencode.h>

// This function is the entry point for libFuzzer.
// It takes fuzzed input and runs a QR encoding operation.
int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  // Skip if input is too small or too large
  if (size < 5 || size > 4096) return 0;

  // Extract parameters from the first few bytes of input
  int version = data[0] % 41; // QR version: 1–40 (0 = automatic)
  QRecLevel level = (QRecLevel)(data[1] % 4); // Error correction level: L, M, Q, H
  int caseSensitive = data[2] % 2; // Case-sensitive flag
  int eightbit = data[3] % 2; // Whether to use 8-bit binary mode

  // Use the rest of the input as a string
  const uint8_t *payload = data + 4;
  size_t payload_size = size - 4;

  char *input = (char *)malloc(payload_size + 1);
  if (!input) return 0;

  memcpy(input, payload, payload_size);
  input[payload_size] = '\0'; // Null-terminate the input string

  QRcode *qrcode = NULL;

  // Choose encoding method
  if (eightbit) {
    qrcode = QRcode_encodeString8bit(input, version, level);
  } else {
    qrcode = QRcode_encodeString(input, version, level, QR_MODE_8, caseSensitive);
  }

  // Access QR data to help sanitizers catch bugs
  if (qrcode) {
    if (qrcode->data && qrcode->width > 0) {
      volatile unsigned char x = qrcode->data[0]; // Trigger memory read
      (void)x;
    }
    QRcode_free(qrcode); // Clean up
  }

  free(input); // Free input string
  return 0;
}
