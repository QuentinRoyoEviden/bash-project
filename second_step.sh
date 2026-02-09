#!/bin/bash

file_ref="result"
file_new="new_result"

ls -l > "$file_new"

diff "$file_ref" "$file_new" > /home/qroyo/bash_project1/file_diff
