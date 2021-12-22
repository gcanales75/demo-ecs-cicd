#!/bin/bash

sed -i -e 's/BUILD_ID/$CODEBUILD_BUILD_ID/g' website/index.html