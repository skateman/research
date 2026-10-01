"""Render an existing PDF and publish a manifest only after all pages succeed."""

import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
from datetime import datetime, timezone


def render_pages(pdf_file: str, dpi: int, pages_only: bool) -> dict:
    pdf = Path(pdf_file).resolve(strict=True)
    pages = Path("output/pages")
    pages.mkdir(parents=True, exist_ok=True)
    manifest = pages / "pages.json"
    manifest.unlink(missing_ok=True)
    info = subprocess.run(
        ["pdfinfo", str(pdf)], check=True, stdout=subprocess.PIPE, text=True
    ).stdout
    match = re.search(r"^Pages:\s+([1-9][0-9]*)\s*$", info, re.MULTILINE)
    if match is None:
        raise ValueError("pdfinfo did not report a positive page count")
    count = int(match.group(1))

    with tempfile.TemporaryDirectory(prefix=".render-pages-", dir="output") as staging:
        subprocess.run(
            ["pdftoppm", "-png", "-r", str(dpi), str(pdf), str(Path(staging) / "page")],
            check=True,
        )
        images = sorted(Path(staging).glob("page-*.png"))
        numbers = [
            int(image.stem.removeprefix("page-"))
            for image in images
            if re.fullmatch(r"page-[0-9]+\.png", image.name) and image.stat().st_size
        ]
        if len(images) != count or sorted(numbers) != list(range(1, count + 1)):
            raise ValueError(f"Expected {count} nonempty page images, got {len(numbers)}")
        for old in pages.glob("page-*.png"):
            if re.fullmatch(r"page-[0-9]+\.png", old.name):
                old.unlink()
        for image in images:
            image.replace(pages / image.name)

    size = pdf.stat().st_size
    with pdf.open("rb") as stream:
        checksum = hashlib.file_digest(stream, "sha256").hexdigest()
    metadata = {
        "pdf_file": pdf_file,
        "pdf_size": f"{size} bytes",
        "pdf_size_bytes": size,
        "pdf_sha256": checksum,
        "page_count": count,
        "rendered_images": count,
        "dpi": dpi,
        "pages_directory": "output/pages/",
        "pages_only": pages_only,
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }
    temporary_manifest = pages / ".pages.json.tmp"
    temporary_manifest.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    temporary_manifest.replace(manifest)
    print(f"Rendered {count} pages at {dpi} DPI")
    return metadata


if __name__ == "__main__":
    render_pages(sys.argv[1], int(sys.argv[2]), sys.argv[3] == "true")
