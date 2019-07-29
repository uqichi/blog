#!/bin/bash

echo -e "\033[0;32mPulling updates from GitHub...\033[0m"

# Go To Public folder
cd public
# Pull changes from git.
git pull origin master

# Come Back up to the Project Root
cd ..

# Go To Theme folder
cd themes/hermit
# Pull changes from git.
git pull origin master

# Come Back up to the Project Root
cd ..

# Pull changes from git
git pull origin master
