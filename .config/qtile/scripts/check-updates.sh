#!/bin/bash

count=$(checkupdates | wc -l)

printf " $count"
