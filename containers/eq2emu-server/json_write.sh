#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <input_file> <output_file> <field_path> <new_value>"
  exit 1
fi

# Assign arguments to variables
input_file="$1"
output_file="$2"
field_path="$3"
new_value="$4"
tmp_file="$2".tmp

# Modify the specified field with the new value, handling both strings and numbers
jq --argjson value "$new_value" "$field_path = $value" "$input_file" > "$tmp_file" || \
jq --arg value "$new_value" "$field_path = \$value" "$input_file" > "$tmp_file"

mv "$tmp_file" "$output_file"

# Output a message indicating success
echo "Field '$field_path' has been updated with the value '$new_value' in '$output_file'."
