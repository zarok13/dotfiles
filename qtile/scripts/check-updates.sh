#!/bin/bash

count=$(apt list --upgradable 2>/dev/null | grep -v Listing | wc -l)

printf " $count"
