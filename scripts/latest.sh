#!/usr/bin/bash
src=$(pwd)
cd $src/f5-sca-securitystack
echo $(pwd)
git pull https://github.com/mikeoleary/f5-sca-securitystack.git mazza-bigip-tierx-apps
cd $src
echo "done"