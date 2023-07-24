import os

# List of packages to be installed
packages = [
    "libssl-dev",
    "libfontconfig1-dev",
    "libcurl4-openssl-dev",
    "libharfbuzz-dev",
    "libfribidi-dev",
    "libfreetype6-dev",
    "libpng-dev",
    "libtiff5-dev",
    "libjpeg-dev"
]

# Loop over the packages and install each one
for package in packages:
    print(f"Installing {package}...")
    os.system(f"apt-get install -y {package}")

print("All packages installed.")
