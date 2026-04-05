#!/bin/sh
set -e

# 从环境变量读取 CRON 表达式，默认每 6 小时执行一次
CRON_SCHEDULE="${CRON_SCHEDULE:-0 */6 * * *}"

# 创建 crontab 文件
echo "${CRON_SCHEDULE} /home/appuser/weather-cli" > /tmp/crontab.txt

# 安装 crontab
crontab /tmp/crontab.txt

# 启动 cron 服务 (前台运行)
exec crond -f
