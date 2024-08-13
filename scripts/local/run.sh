#!/bin/bash

SOURCE="${BASH_SOURCE[0]}"
echo $SOURCE

DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

ENV=`basename $DIR`
echo $ENV

# Go out to root of git folder
cd ../../
# Set test ENV
COMPONENT=`echo $JOB_NAME | sed -e 's/-build-pipeline//g' -e 's/truemoney-cicd-truemoney-//g' -e 's/\///g' -e 's/truemoney-cicd//g'`
echo $COMPONENT
RESULT_FOLDER="results/"$ENV

if command -v python3 &>/dev/null; then
    virtualenv ~/${COMPONENT}-robot-env --no-download -p python3
else
    virtualenv ~/${COMPONENT}-robot-env --no-download
fi

source ~/${COMPONENT}-robot-env/bin/activate
pip install -r requirements.txt -i https://robot:ZuVeZSg6hZYyd98R@pypi.tmn-dev.com/robot/dev --trusted-host pypi.tmn-dev.com


mkdir -p $RESULT_FOLDER
cd $RESULT_FOLDER

rm -rf *.html *.xml *.jpg
date
if command -v python3 &>/dev/null; then
    python3 -m robot.run -L TRACE -v env:$ENV -e not_ready -e not_active -e not_test -e smoke_test -i regression ../../testcases/
else
    python -m robot.run -L TRACE -v env:$ENV -e not_ready -e not_active -e not_test -e smoke_test -i regression ../../testcases/
fi
date

# For do not let Jenkins mark failed from shell script.
exit 0