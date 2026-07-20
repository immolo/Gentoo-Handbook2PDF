#!/bin/sh
# Copyright Ian Jordan <immoloism@gmail.com> 2026

# Script to download the Gentoo Handbook and convert to PDF.

DATE=$(date +%Y-%m-%d)
OUTDIR="$HOME/gentoo-handbook-snapshots"
KEEP=1   # number of snapshots to keep per arch; change if you want more history

# Add or remove arches here. Must match Gentoo's Handbook: URL naming.
ARCHES="Alpha AMD64 HPPA MIPS PPC PPC64 SPARC X86"

mkdir -p "$OUTDIR"

FAILED=0
for ARCH in $ARCHES; do
    RENDER_URL="https://wiki.gentoo.org/wiki/Handbook:${ARCH}/Full/Installation"
    OUTFILE="$OUTDIR/gentoo-handbook-${ARCH}-$DATE.pdf"

    if weasyprint -q "$RENDER_URL" "$OUTFILE"; then
        echo "Saved snapshot: $OUTFILE"
    else
        echo "Failed to generate snapshot for $ARCH ($DATE)" >&2
        FAILED=$((FAILED + 1))
        continue
    fi

    # Prune old snapshots for this arch, keeping only the $KEEP newest
    ls -1t "$OUTDIR"/gentoo-handbook-"${ARCH}"-*.pdf 2>/dev/null \
        | tail -n +$((KEEP + 1)) \
        | while read -r OLDFILE; do
            echo "Removing old snapshot: $OLDFILE"
            rm -f "$OLDFILE"
        done
done

if [ "$FAILED" -gt 0 ]; then
    echo "$FAILED arch(es) failed" >&2
    exit 1
fi
