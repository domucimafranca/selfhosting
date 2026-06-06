#!/usr/bin/env python3

import re
import sys
from pathlib import Path

from ebooklib import epub


def get_first_metadata_value(book, namespace, key):
    """
    Return the first metadata value for a given namespace/key.
    """
    values = book.metadata.get(namespace, {}).get(key)
    if values:
        return values[0][0]
    return None


def sanitize_filename(text):
    """
    Remove or replace characters that are problematic in filenames.
    """
    text = str(text).strip()

    # Replace common filename-invalid characters
    text = re.sub(r'[<>:"/\\|?*]', "-", text)

    # Collapse whitespace
    text = re.sub(r"\s+", " ", text)

    # Remove trailing dots/spaces
    text = text.rstrip(". ")

    return text


def build_new_filename(epub_path):
    book = epub.read_epub(str(epub_path))

    dc_ns = "http://purl.org/dc/elements/1.1/"

    publisher = get_first_metadata_value(book, dc_ns, "publisher")
    author = get_first_metadata_value(book, dc_ns, "creator")
    title = get_first_metadata_value(book, dc_ns, "title")

    # Title is the only required field
    if not title:
        raise ValueError("Missing required metadata field: title")

    parts = []

    if publisher:
        parts.append(sanitize_filename(publisher))

    if author:
        parts.append(sanitize_filename(author))

    parts.append(sanitize_filename(title))

    return " - ".join(parts) + ".epub"

def rename_epub(epub_file):
    epub_path = Path(epub_file)

    if not epub_path.exists():
        raise FileNotFoundError(epub_path)

    new_name = build_new_filename(epub_path)
    new_path = epub_path.with_name(new_name)

    if new_path.exists():
        raise FileExistsError(
            f"Target file already exists: {new_path}"
        )

    epub_path.rename(new_path)

    print(f"Renamed:")
    print(f"  From: {epub_path.name}")
    print(f"  To:   {new_path.name}")


def main():
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <book.epub>")
        sys.exit(1)

    rename_epub(sys.argv[1])


if __name__ == "__main__":
    main()
