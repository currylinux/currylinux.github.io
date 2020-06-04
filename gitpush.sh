#!/bin/bash
TAG=`date +%Y-%m-%d_%H-%M`
git add .
git commit -m "new change${TAG}"
git push