#!/bin/bash

file_ref="new_result1"
file_new="result"

result=$(diff "$file_ref" "$file_new")

echo "------------------------------------------------"
echo $result
echo "------------------------------------------------"
