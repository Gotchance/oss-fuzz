#include <tiffio.h>
#include <stdint.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
  if (size < 4) return 0;

  // 入力を一時ファイルに保存
  const char *in_file = "/tmp/fuzz_input.tif";
  FILE *fp = fopen(in_file, "wb");
  if (!fp) return 0;
  fwrite(data, 1, size, fp);
  fclose(fp);

  // TIFF ファイルとして開く
  TIFF *tif = TIFFOpen(in_file, "r");
  if (tif) {
    // TIFFのディレクトリを読む（脆弱性が発生しやすい処理）
    TIFFReadDirectory(tif);

    // 必要に応じて他の処理もここに追加できます

    TIFFClose(tif);
  }

  return 0;
}
