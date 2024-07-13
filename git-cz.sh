#!/bin/bash

# 检查当前目录是否为Git仓库
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "错误：当前目录不是一个Git仓库。"
    exit 1
fi

# 定义选项
options=(
"1. 🎉 feat: 新功能（feature）"
"2. 🐛 fix: 修补bug"
"3. 📚 docs: 文档（documentation）"
"4. 💡 style: 格式（不影响代码运行的变动）"
"5. 🚀 refactor: 重构（即不是新增功能，也不是修补bug的代码变动）"
"6. 💖 perf: 性能改进"
"7. 🚨 test: 增加测试"
"8. 🚸 chore: 构建过程或辅助工具的变动"
)

# 初始化选中项
selected=0

# 使用tput设置颜色（如果可用）
if command -v tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
    if [ $ncolors -ge 8 ]; then
        normal=$(tput sgr0)
        highlight=$(tput setaf 2) # 亮绿色
    fi
fi

# 如果没有颜色支持，则不设置高亮
: ${highlight:=$normal}


#function get_commit_type_and_message {
  # 主循环
  while true; do
      # 清除屏幕
      clear

      echo "请选择提交类型（使用回车键选择）:"

      # 显示选项
      for (( i=0; i<${#options[@]}; i++ )); do
          if [ $i -eq $selected ]; then
              echo -e "${highlight}${options[$i]}${normal}"
          else
              echo "${options[$i]}"
          fi
      done

      # 读取用户输入
      read -n 1 key
      case $key in
          j)
              ((selected++))
              if [ $selected -ge ${#options[@]} ]; then
                  selected=0
              fi
              ;;
          k)
              ((selected--))
              if [ $selected -lt 0 ]; then
                  selected=$(( ${#options[@]} - 1 ))
              fi
              ;;
           '')
              echo "选中了: ${options[$selected]}"
              case $selected in
                      0)
                          prefix="feat"
                          ;;
                      1)
                          prefix="fix"
                          ;;
                      2)
                          prefix="docs"
                          ;;
                      3)
                          prefix="style"
                          ;;
                      4)
                          prefix="refactor"
                          ;;
                      5)
                          prefix="perf"
                          ;;
                      6)
                          prefix="test"
                          ;;
                      7)
                          prefix="chore"
                          ;;
              esac

              echo "请输入$prefix 类型的提交信息:"
                read message
                commit_message="$prefix: $message"
                echo "信息组装：$commit_message"
                break
              ;;
          *)
              echo "无效的输入，按 j/k 上下移动，按 q 退出"
              ;;
      esac
  done
#}

# 执行Git提交
if [ -n "$commit_message" ]; then
    git commit -m "$commit_message"
    if [ $? -eq 0 ]; then
        echo "提交成功！"
    else
        echo "提交失败，请检查您的Git仓库状态或提交信息是否正确。"
    fi
else
    echo "未获取到有效的提交信息，提交被取消。"
fi