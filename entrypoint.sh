#!/bin/bash
# Install mecab, then build wheels
set -e

# install MeCab
# TODO specify the commit used here
git clone https://github.com/taku910/mecab.git
cd mecab/mecab
./configure --enable-utf8-only
make
make install

# Build the wheels
for PYVER in cp37-cp37m cp38-cp38; do
  # install cython first
  /opt/python/$PYVER/bin/pip install cython

  # build the wheels
  /opt/python/$PYVER/bin/pip wheel /github/workspace -w /github/workspace/wheels || { echo "Failed while buiding $PYVER wheel"; exit 1 }
done

# fix the wheels (bundles libs)
for wheel in /github/workspace/wheels/*.whl; do
  auditwheel repair "$wheel" --plat manylinux1_x86_64 -w /github/workspace/manylinux1-wheels
done

echo "Built wheels:"
ls /github/workspace/manylinux1-wheels
