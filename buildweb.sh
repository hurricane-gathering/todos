#!/bin/bash

cd /Users/apple/Documents/workfiles/projects/flutter/todo
flutter build web --no-tree-shake-icons
# 检查上一个命令的执行状态
if [ $? -eq 0 ]; then
  echo "构建成功"
else
  echo "错误"
fi
cp -r /Users/apple/Documents/workfiles/projects/flutter/todo/build/web/* /opt/homebrew/var/www/

# 检查上一个命令的执行状态
if [ $? -eq 0 ]; then
  echo "部署成功"
else
  echo "错误"
fi