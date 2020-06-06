#!/usr/bin/env bash

# Echo each command
set -x

# Exit on error.
set -e

if [[ "${TRAVIS_OS_NAME}" == "osx" ]]; then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh -O miniconda.sh;
else
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
fi
export deps_dir=$HOME/local
export PATH="$HOME/miniconda/bin:$PATH"
bash miniconda.sh -b -p $HOME/miniconda
conda config --add channels conda-forge
conda config --set channel_priority strict

conda_pkgs="cmake"

conda create -q -p $deps_dir -y
source activate $deps_dir
conda install $conda_pkgs -y

set +e
set +x