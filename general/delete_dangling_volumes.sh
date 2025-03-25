#!/bin/bash

# Get a list of all dangling volumes
dangling_volumes=$(docker volume ls -f dangling=true -q)

# Check if there are any dangling volumes
if [[ -n "$dangling_volumes" ]]; then
  echo "Found dangling volumes:"
  echo "$dangling_volumes"

  # Ask for confirmation
  read -p "Do you want to delete these dangling volumes? (y/n): " response

  if [[ "$response" == "y" || "$response" == "Y" ]]; then
    # Delete all dangling volumes
    for volume in $dangling_volumes; do
      docker volume rm "$volume"
      echo "Deleted volume: $volume"
    done
  else
    echo "Deletion canceled."
  fi
else
  echo "No dangling volumes found."
fi
