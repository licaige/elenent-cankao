#! /bin/sh

# 执行构建任务, 把目标文件同步到不同的 git 仓库中

mkdir temp_web
git config --global user.name "element-bot"
git config --global user.email "wallement@gmail.com"

if [ "$ROT_TOKEN" = "" ]; then
  echo "Bye~"
  exit 0
fi

# release 如果有打标签
if [ "$TRAVIS_TAG" ]; then
  # build lib
  npm run dist
  cd temp_web
  # 下载远程仓库
  git clone https://$ROT_TOKEN@github.com/ElementUI/lib.git && cd lib
  # 删除掉所有除 README.md 的文件
  rm -rf `find * ! -name README.md`
  # 复制最新的文件
  cp -rf ../../lib/** .
  # 提交所有更改
  git add -A .
  git commit -m "[build] $TRAVIS_TAG"
  # 添加标签
  git tag $TRAVIS_TAG
  git push origin master --tags
  cd ../..

  # build theme-chalk
  cd temp_web
  git clone https://$ROT_TOKEN@github.com/ElementUI/theme-chalk.git && cd theme-chalk
  rm -rf *
  cp -rf ../../packages/theme-chalk/** .
  git add -A .
  git commit -m "[build] $TRAVIS_TAG"
  git tag $TRAVIS_TAG
  git push origin master --tags
  cd ../..

  # 把文档项目添加到 gh-pages 分支
  # build site
  npm run deploy:build # 先执行构建
  cd temp_web
  git clone --depth 1 -b gh-pages --single-branch https://$ROT_TOKEN@github.com/ElemeFE/element.git && cd element
  # build sub folder
  echo $TRAVIS_TAG

  SUB_FOLDER='2.13'
  # 创建新的版本文件夹
  mkdir $SUB_FOLDER
  # 删除旧文件
  rm -rf *.js *.css *.map static
  rm -rf $SUB_FOLDER/**
  # 复制新的文件
  cp -rf ../../examples/element-ui/** .
  cp -rf ../../examples/element-ui/** $SUB_FOLDER/
  # 提交到 gh-pages 分支
  git add -A .
  git commit -m "$TRAVIS_COMMIT_MSG"
  git push origin gh-pages
  cd ../..

  # 结束任务
  echo "DONE, Bye~"
  exit 0
fi

# build dev site
npm run build:file && CI_ENV=/dev/$TRAVIS_BRANCH/ node_modules/.bin/cross-env NODE_ENV=production node_modules/.bin/webpack --config build/webpack.demo.js
cd temp_web
git clone https://$ROT_TOKEN@github.com/ElementUI/dev.git && cd dev
mkdir $TRAVIS_BRANCH
rm -rf $TRAVIS_BRANCH/**
cp -rf ../../examples/element-ui/** $TRAVIS_BRANCH/
git add -A .
git commit -m "$TRAVIS_COMMIT_MSG"
git push origin master
cd ../..

# push dev theme-chalk
cd temp_web
git clone -b $TRAVIS_BRANCH https://$ROT_TOKEN@github.com/ElementUI/theme-chalk.git && cd theme-chalk
rm -rf *
cp -rf ../../packages/theme-chalk/** .
git add -A .
git commit -m "$TRAVIS_COMMIT_MSG"
git push origin $TRAVIS_BRANCH
cd ../..
