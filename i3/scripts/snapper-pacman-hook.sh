#!/bin/bash
# Creates a snapper snapshots for pacman transactions


DESCRIPTION="PACMAN::[$1]"

snapper -c root create --type pre --description "$DESCRIPTION" --cleanup-algorithm number --read-only
