#!/bin/bash
# setup jekyll site locally  
# Array of packages to check
#packages=(ruby ruby-bundler ruby-dev)
JEKYLL_VERSION="4.3.3"
# Function to check OS platform and install an array of packages
install_packages() {
    local packages=(ruby ruby-bundler ruby-dev) # Array of packages passed as arguments

    # Check if any packages are provided
    if [ ${#packages[@]} -eq 0 ]; then
        echo "Please provide package names."
        return 1
    fi

    # Check for Debian/Ubuntu or any APT-based distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            debian|ubuntu)
                echo "Detected $ID OS. Installing packages using apt-get..."
                 apt-get update
                for package in "${packages[@]}"; do
                  apt-get install -y "$package"
                done
                ;;
            rhel|centos|fedora)
                echo "Detected $ID OS. Installing packages using yum/dnf..."
                if command -v dnf &>/dev/null; then
                    for package in "${packages[@]}"; do
                      dnf install -y "$package"
                    done
                else
                    for package in "${packages[@]}"; do
                      yum install -y "$package"
                    done
                fi
                ;;
            *)
                echo "Unsupported Linux distribution: $ID"
                return 1
                ;;
        esac
    # Check for macOS
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Detected macOS. Installing packages using brew..."
        if ! command -v brew &>/dev/null; then
            echo "Homebrew is not installed. Please install Homebrew first."
            return 1
        fi
        for package in "${packages[@]}"; do
            brew install "$package"
        done
    else
        echo "Unsupported OS type."
        return 1
    fi
}

jekyll_install_and_build() {
    # Install bundle
    bundle install 
    # Check if the directory exists
    dir="vendor/"
    if [ -d "$dir" ]; then
        echo "Directory exists. Removing it..."
        rm -rf "$dir"
    else
        echo "vendor Directory does not exist."
    fi
    # Install bundler 
    gem install bundler --version "$JEKYLL_VERSION"
    #Add Jekyll
    #bundle add jekyll
    gem install jekyll
    gem install jekyll-pageinate
    gem install jekyll-sitemap
    gem install jekyll-seo-tag 
}
 
 
jekyll_build() { 
    bundle _$JEKYLL_VERSION_ install
    bundle config set --local path 'vendor/bundle' 
}


burn_local_dirs() {  
    # Define the directory path
    DIR="vendor/"

    # Check if the directory exists
    if [ -d "$DIR" ]; then
    # If it exists, delete the directory
    rm -rf "$DIR"
    echo "Directory $DIR has been deleted."
    else
    echo "Directory $DIR does not exist."
    fi

}

install_packages
#burn_local_dirs
jekyll_install_and_build
jekyll_build


# serve jekyll
bundle exec jekyll serve --watch --port 8000