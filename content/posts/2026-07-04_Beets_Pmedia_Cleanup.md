---
author: cjd
title: Purging "PMEDIA" spam from my music library with Beets and Mutagen
date: "2026-07-04T19:15:00+10:00"
tags:
  - general
  - homelab
  - music
  - scripts
url: /blog/2026/07/beets-pmedia-cleanup
showToc: false
---

I have been cleaning up my music collection, which I have ripped from CDs over the years, finally getting around to tagging them properly. I used MusicBrainz Picard to tag my music, but what I didn't know is that it was adding a bunch of tags which contain 'PMEDIA' (even in places like the composer field, which makes no sense).

Seeing this as annoying, I needed a way to clean up my tags to remove this unwanted metadata. Since I have imported the music via [beets.io](https://beets.io/), I was able to use that to help fix up the metadata. However, I ran into several albums in my library where the "PMEDIA" watermark kept reappearing, even after Beets reported that the fields had been successfully cleaned and synced.

Here is why that was happening, and the deep-clean script I wrote using **Beets** and **Mutagen** to wipe the spam out of my library permanently.

---


### The Blind Spots: APEv2 and ID3v1 Tags

I spent some time inspecting the affected MP3s using python's `mutagen` engine and raw binary greps, and I discovered a couple of massive tagging blind spots:

1.  **Non-standard APEv2 tags**: Some encoders or downloaders inject APEv2 tags into MP3 files. While ID3v2 is the standard tagging format for MP3, APEv2 tags are non-standard. Crucially, many popular players (such as Foobar2000, VLC, and some mobile players) prioritize APEv2 tags over ID3v2 tags. Even if your ID3v2 tags are perfectly clean, if a hidden APEv2 tag exists on the file, the player will display its values instead.
2.  **Legacy ID3v1 tags**: These are the old, 128-byte tags at the very end of MP3 files. They can also hold outdated, watermarked values.
3.  **Untracked MediaFile properties**: Beets' standard database schema tracks primary tags (artist, album, title, etc.), but leaves advanced or custom fields (like `conductor`, `releasecountry`, `subtitle`, `mood`, `work`, and `copyright`) to be read from disk dynamically. This means a standard beets search or clean-up query won't always see these fields without deep inspection.

To solve this, I wrote a comprehensive bash wrapper around a Python script that uses the native Beets runtime and the Mutagen parsing engine to deeply scan files, delete non-standard APEv2 and legacy ID3v1 tags entirely, clean standard/flexible fields, and then commit those clean files back to the Beets SQLite database.

---

### The Script: `clean_pmedia.sh`

This script is located in my music directory (`/tank/Music/clean_pmedia.sh`). It loads my Beets SQLite library database, retrieves matching tracks, resolves files on disk (even handling formatting or spacing differences), and performs a complete three-tier cleanup.

```bash
#!/usr/bin/env bash

# Exit immediately if any command fails
set -euo pipefail

# Bash wrapper for beets 'PMEDIA' tag cleanup.
# It uses beets' own python runtime and mediafile/mutagen engine to deeply scan 
# and clean standard fields, non-db mediafile fields (conductor, copyright, etc.) 
# and raw mutagen tags on disk, keeping the beets database perfectly in sync.

# Export PYTHONPATH to find beets and mediafile libraries
export PYTHONPATH="/usr/share/beets"

# Verify python3 is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: python3 is not installed." >&2
    exit 1
fi

# Run the python script engine
python3 - "$@" << 'EOF'
import argparse
import os
import re
import sys
import beets.library
import mediafile
import mutagen
from mutagen.apev2 import APEv2
from mutagen.id3 import ID3

# Redirect sys.stdin to the controlling terminal /dev/tty so that input() can 
# read user keyboard input, even when the python script itself is piped via a heredoc.
try:
    sys.stdin = open('/dev/tty')
except Exception:
    # Fallback if there is no controlling terminal (e.g., non-interactive or cron)
    pass

def normalize_spaces(s):
    """Normalize multiple spaces into a single space for robust file matching."""
    return re.sub(r'\s+', ' ', s.strip())

def find_actual_path(db_path_bytes, item=None):
    """
    Resolve the actual filesystem path for a beets DB entry.
    If the exact DB path does not exist, check:
    1. Spacing formatting (e.g. double spaces vs single spaces).
    2. Fuzzy match based on track title (e.g., if files were renamed on disk to titles).
    """
    if os.path.exists(db_path_bytes):
        return db_path_bytes

    try:
        db_path_str = db_path_bytes.decode('utf-8', 'ignore')
    except Exception:
        return None

    dir_name = os.path.dirname(db_path_str)
    base_name = os.path.basename(db_path_str)

    if not os.path.exists(dir_name):
        return None

    # Method 1: Normalized spacing match
    norm_target = normalize_spaces(base_name)
    try:
        for f in os.listdir(dir_name):
            if normalize_spaces(f) == norm_target:
                actual_path = os.path.join(dir_name, f)
                return actual_path.encode('utf-8')
    except Exception:
        pass

    # Method 2: Fuzzy title-based match
    if item:
        try:
            target_title_norm = normalize_spaces(item.title).lower()
            for f in os.listdir(dir_name):
                f_name_without_ext, _ = os.path.splitext(f)
                if normalize_spaces(f_name_without_ext).lower() == target_title_norm:
                    actual_path = os.path.join(dir_name, f)
                    return actual_path.encode('utf-8')
        except Exception:
            pass

    return None

def main():
    parser = argparse.ArgumentParser(description="Clean PMEDIA tags from beets tracks.")
    parser.add_argument('-d', '--dry-run', action='store_true', help="Show changes without applying them.")
    parser.add_argument('-y', '--yes', action='store_true', help="Auto-confirm all changes.")
    parser.add_argument('-v', '--verbose', action='store_true', help="Print verbose scan logs.")
    parser.add_argument('query', nargs='*', help="Beets query or file/dir path to restrict the scan.")
    args = parser.parse_args()

    # Load beets library database
    lib_path = os.path.expanduser('~/.config/beets/library.db')
    if not os.path.exists(lib_path):
        print(f"Error: Beets library database not found at {lib_path}")
        sys.exit(1)

    lib = beets.library.Library(lib_path)
    
    # Regex pattern to match PMEDIA or P.M.E.D.I.A with or without case/spaces/dots
    pmedia_pattern = re.compile(r'p\.?m\.?e\.?d\.?i\.?a', re.IGNORECASE)

    # All standard metadata text fields to inspect on beets Item & MediaFile.
    standard_text_fields = [
        'title', 'artist', 'artists', 'album', 'genre', 'genres', 'lyricist',
        'composer', 'composer_sort', 'arranger', 'grouping', 'lyrics',
        'comments', 'copyright', 'albumartist', 'albumartists', 'label',
        'artist_sort', 'albumartist_sort', 'asin', 'catalognum', 'barcode',
        'isrc', 'disctitle', 'encoder', 'script', 'language', 'country',
        'albumstatus', 'media', 'albumdisambig', 'conductor', 'subtitle',
        'work', 'url', 'comment', 'mood', 'releasecountry'
    ]

    print("Retrieving library tracks...")

    # Load items based on positional queries/paths if provided
    items = []
    if args.query:
        for q in args.query:
            if os.path.exists(q):
                abs_q = os.path.abspath(q)
                if os.path.isdir(abs_q):
                    # Directory path: scan all library tracks under this directory
                    for item in lib.items():
                        act_p = find_actual_path(item.path, item)
                        if act_p:
                            abs_item_path = os.path.abspath(act_p.decode('utf-8', 'ignore'))
                            if abs_item_path.startswith(abs_q):
                                items.append(item)
                else:
                    # Specific file path: scan this specific track
                    for item in lib.items():
                        act_p = find_actual_path(item.path, item)
                        if act_p:
                            abs_item_path = os.path.abspath(act_p.decode('utf-8', 'ignore'))
                            if abs_item_path == abs_q:
                                items.append(item)
            else:
                # String query
                items.extend(list(lib.items(q)))

        # Deduplicate items by ID
        seen_ids = set()
        dedup_items = []
        for item in items:
            if item.id not in seen_ids:
                seen_ids.add(item.id)
                dedup_items.append(item)
        items = dedup_items
    else:
        items = list(lib.items())

    total_scanned = len(items)
    total_modified = 0
    print(f"Scanning {total_scanned} track(s) for 'PMEDIA' (includes P.M.E.D.I.A)...")

    for idx, item in enumerate(items, 1):
        # 1. Resolve actual path on disk
        actual_path = find_actual_path(item.path, item)
        if not actual_path:
            if args.verbose:
                print(f"[{idx}/{total_scanned}] Skipping missing file: {item.path.decode('utf-8', 'ignore')}")
            continue

        path_decoded = actual_path.decode('utf-8', 'ignore')
        if args.verbose:
            print(f"[{idx}/{total_scanned}] Scanning: {item.artist} - {item.title}")

        try:
            mf = mediafile.MediaFile(actual_path)
        except Exception as e:
            if args.verbose:
                print(f"  Error reading file metadata for {path_decoded}: {e}")
            continue

        # Detect fields with PMEDIA on all three levels
        db_fields_to_clear = []   # beets SQL DB fields
        mf_fields_to_clear = []   # MediaFile tag properties
        raw_tags_to_delete = []   # Mutagen frames

        # 1. Check beets DB Item fields (standard & flexible attributes)
        for key, val in item.items():
            if isinstance(val, str) and pmedia_pattern.search(val):
                db_fields_to_clear.append((key, val))

        # 2. Check standard properties on the MediaFile object
        for field in standard_text_fields:
            try:
                val = getattr(mf, field, None)
                if val:
                    val_str = str(val)
                    if pmedia_pattern.search(val_str):
                        mf_fields_to_clear.append((field, val_str))
            except Exception:
                pass

        # 3. Check raw mutagen tags for any hidden or customized fields
        if mf.mgfile and mf.mgfile.tags:
            for key in list(mf.mgfile.tags.keys()):
                # Skip binary art and cover tags
                if key.upper().startswith('APIC') or key.upper().startswith('COVR'):
                    continue
                try:
                    val = mf.mgfile.tags[key]
                    val_str = str(val)
                    if pmedia_pattern.search(key) or pmedia_pattern.search(val_str):
                        raw_tags_to_delete.append((key, val_str))
                except Exception:
                    pass

        # 4. Check for non-standard APEv2 tags or legacy ID3v1 tags (common source of hidden metadata)
        has_apev2 = False
        has_id3v1 = False
        is_mp3 = path_decoded.lower().endswith('.mp3')
        if is_mp3:
            try:
                # Attempt to load APEv2; if it succeeds, APEv2 tag is present
                APEv2(actual_path)
                has_apev2 = True
            except Exception:
                pass

            try:
                # Fast check for legacy ID3v1 tag at the end of the MP3 file
                with open(actual_path, 'rb') as fh:
                    fh.seek(-128, 2)
                    tag_header = fh.read(3)
                    if tag_header == b'TAG':
                        has_id3v1 = True
            except Exception:
                pass

        # If any matches were found (or if we need to sync a broken DB path)
        path_mismatch = (actual_path != item.path)
        if db_fields_to_clear or mf_fields_to_clear or raw_tags_to_delete or has_apev2 or has_id3v1 or (path_mismatch and args.verbose):
            print(f"\nTrack: {item.artist} - {item.title}")
            print(f"File:  {path_decoded}")
            
            if path_mismatch:
                print(f"  [Sync Path] DB path has different spacing/naming. Will be corrected to actual disk path.")

            # Print matching fields
            for field, val in db_fields_to_clear:
                print(f"  [Beets DB Field] {field}: '{val}' -> (will be cleared)")

            for field, val in mf_fields_to_clear:
                print(f"  [Tag Field]      {field}: '{val}' -> (will be cleared)")
                
            for key, val in raw_tags_to_delete:
                print(f"  [Raw Tag Frame]  {key}: '{val}' -> (will be deleted)")

            if has_apev2:
                print(f"  [Non-standard Tags] Found APEv2 tag frame (contains PMEDIA/metadata spam) -> (will be deleted entirely)")
            if has_id3v1:
                print(f"  [Legacy Tags]       Found ID3v1 tag (can contain PMEDIA/metadata spam) -> (will be deleted)")

            if args.dry_run:
                print("  [DRY RUN] No changes applied.")
                continue

            # Confirm changes
            confirm = True
            if not args.yes:
                try:
                    ans = input("  Apply cleanup to this track? [y/N]: ").strip().lower()
                    confirm = ans in ['y', 'yes']
                except (KeyboardInterrupt, EOFError):
                    print("\nAborted.")
                    sys.exit(0)

            if confirm:
                # 1. Sync path if needed
                if path_mismatch:
                    item.path = actual_path
                    item.store()

                # 2. Clear beets database fields
                for field, _ in db_fields_to_clear:
                    try:
                        if field in item and field not in item._fields:
                            # Delete flexible attribute
                            del item[field]
                        else:
                            # Clear standard field
                            item[field] = ''
                    except Exception:
                        pass

                # 3. Clear standard tag fields
                for field, _ in mf_fields_to_clear:
                    try:
                        setattr(mf, field, None)
                    except Exception:
                        try:
                            setattr(mf, field, '')
                        except Exception:
                            pass

                # 4. Delete raw mutagen tags
                if mf.mgfile and mf.mgfile.tags:
                    for key, _ in raw_tags_to_delete:
                        try:
                            del mf.mgfile.tags[key]
                        except Exception:
                            pass

                # 5. Delete non-standard APEv2 tags
                if has_apev2:
                    try:
                        ape = APEv2(actual_path)
                        ape.delete()
                        print("  Successfully deleted APEv2 tags!")
                    except Exception as e:
                        print(f"    Error deleting APEv2 tags: {e}")

                # 6. Delete legacy ID3v1 tags
                if has_id3v1:
                    try:
                        id3 = ID3(actual_path)
                        id3.delete(delete_v1=True, delete_v2=False)
                        print("  Successfully deleted ID3v1 tags!")
                    except Exception as e:
                        print(f"    Error deleting ID3v1 tags: {e}")

                # 7. Save changes back to the actual file
                try:
                    mf.save()
                except Exception as e:
                    print(f"    Error saving media file tags to disk: {e}")
                    continue

                # 8. Reload file metadata and update beets SQLite library database
                try:
                    item.read() # Reload database standard metadata from the cleaned file
                    item.store() # Save state in beets SQLite database
                    print("  Successfully cleaned file tags and updated database!")
                    total_modified += 1
                except Exception as e:
                    print(f"    Error updating beets database: {e}")

    print(f"\nScan complete. Scanned: {total_scanned} track(s), Modified: {total_modified} track(s).")

if __name__ == '__main__':
    main()
EOF
```

---

### How It Works Under the Hood

The script's workflow can be broken down into three key phases:

1.  **Target Selection**: If passed a file or folder path as an argument, it dynamically checks which database items belong under that path (using a smart spacer normalization function to handle any subtle renaming or double-space discrepancies on disk). Otherwise, it scans the entire library.
2.  **Multitier Discovery**:
    *   **Beets SQL level**: Inspects both standard and flexible database attributes.
    *   **MediaFile level**: Checks standard ID3 properties (such as conductor, lyricist, subtitles, and releasecountry) which standard ID3v2 tools often skip.
    *   **Mutagen level**: Checks all raw tag frames (excluding binary album art).
    *   **APE/ID3v1 levels**: Checks specifically for non-standard APEv2 tags and legacy ID3v1 footers.
3.  **Clean and Resync**: If matches are found, it wipes them out on all levels. Crucially, deleting APEv2 tags is done safely via `APEv2.delete()`, and ID3v1 is removed cleanly using `ID3.delete(delete_v1=True, delete_v2=False)`—leaving standard, high-quality, sanitized ID3v2.4 tags completely intact. Finally, `item.read()` reloads the file state into the Beets SQLite database to guarantee total consistency.

---

### Command Line Usage

To run a safe, non-destructive **dry-run** over a specific album directory:

```bash
./clean_pmedia.sh --dry-run "/path/to/music/album"
```

To automatically **execute** the cleanup and auto-confirm all changes across the library:

```bash
./clean_pmedia.sh -y
```

Now, my music player of choice serves up perfectly clean metadata without a single advertising watermark or spam signature in sight. Best of all, my local media files and central Beets database are kept perfectly in sync!
