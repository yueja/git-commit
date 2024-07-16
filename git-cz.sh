#!/bin/bash

# sudo cp git-cz /usr/local/bin/git-cz


# 引入readline库
#. /etc/profile.d/readline.sh

# 全部步骤，包含add 和 push
declare -i allStep=0

# 将位置参数添加到数组中
# 注意：从$1开始，直到最后一个参数
for arg in "$@"; do
  if [ "$arg" == "-a" ];then
    allStep=1
  fi
done

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
        highlightRed=$(tput setaf 1) # 红色
        highlightOrange=$(tput setaf 3) # 橙黄色
    fi
fi

# 如果没有颜色支持，则不设置高亮
: ${highlight:=$normal}

# 当前分支
current_branch=$(git branch --show-current)

enter=0
upward=0
down=0
left=0
right=0

scopeMessage=""

# 监听用户选择键盘上下输入左右输入和回车换行符
function listen_in_keyboard {
#  重置标志位
  upward=0
  down=0
  left=0
  right=0

  akey=(0 0 0)

  cESC=`echo -ne "\033"`

  while :
  do
      #这里要注意，这里有-n选项，后跟一个数字，指定输入的字符长度最大值，所以不管key变量的值有多少个字符，都是一个值一个值做循环， 有多少个值就循环多少次
      #输入键盘的上下左右键时，都有三个字符(ESC键算一个)，所以都是做三次循环，每做一次循环，akey的值都会发生改变
      read -n 1 key

      if [ -z "$key" ]; then
        # 换行符
        enter=1
        break
      fi

      if [[ ${key} == 'q' ]]; then
        # 退出
        exit 1
      fi

      akey[0]=${akey[1]}
      akey[1]=${akey[2]}
      akey[2]=${key}

      if [[ ${key} == ${cESC} && ${akey[1]} == ${cESC} ]]
      then
          echo "ESC键"
      elif [[ ${akey[0]} == ${cESC} && ${akey[1]} == "[" ]]
      then
          if [[ ${key} == "A" ]];then
#             echo "上键"
             upward=1
             break
          elif [[ ${key} == "B" ]];then
#             echo "向下"
             down=1
             break
          elif [[ ${key} == "D" ]];then
#             echo "向左"
             left=1
             break
          elif [[ ${key} == "C" ]];then
#             echo "向右"
             right=1
             break
          fi
      fi
  done
}

function get_commit_scope {
  echo "${highlightOrange}请输入影响范围（1:控制层Controller，2:业务层Biz，3:数据层Dao，4:其他）：${normal}"
  while true; do
    read scope
    if [ $scope -le 0 ] || [ $scope -gt 4 ];then
      echo "${highlightRed}输入错误，请重新输入${normal}"
    else
      case $scope in
        1)
          scopeMessage="Controller"
          ;;
        2)
          scopeMessage="Biz"
          ;;
        3)
          scopeMessage="Dao"
          ;;
        4)
          scopeMessage="Other"
          ;;
      esac
      break
    fi
  done
}


function get_commit_type_and_message {
# 主循环
  while true; do
      # 清除屏幕
      clear

      echo "${highlightOrange}当前正在提交的分支为：" $current_branch${normal}
      echo "${highlightOrange}请选择提交类型（使用回车键选择）:${normal}"

      # 显示选项
      for (( i=0; i<${#options[@]}; i++ )); do
          if [ $i -eq $selected ]; then
              echo -e "${highlight}${options[$i]}${normal}"
          else
              echo "${options[$i]}"
          fi
      done

      # 读取用户输入
      listen_in_keyboard

      if [ $enter -eq 1 ];then
        # 回车选中变更类型
        break
      elif [ $upward -eq 1 ] || [ $left -eq 1 ]; then
          ((selected--))
          if [ $selected -lt 0 ]; then
              selected=$(( ${#options[@]} - 1 ))
          fi
      elif [ $down -eq 1 ] || [ $right -eq 1 ]; then
          ((selected++))
          if [ $selected -ge ${#options[@]} ]; then
             selected=0
          fi
      else  echo "无效的输入，按 Ctrl + C 退出"
      fi
  done

  echo "本次变更为: ${highlight}${options[$selected]}${normal}"
  case $selected in
     0)
       prefix="🎉 feat"
       ;;
     1)
       prefix="🐛 fix"
       ;;
     2)
       prefix="📚 docs"
       ;;
      3)
       prefix="💡 style"
       ;;
      4)
       prefix="🚀 refactor"
       ;;
      5)
       prefix="💖 perf"
       ;;
      6)
       prefix="🚨 test"
       ;;
      7)
       prefix="🚸 chore"
       ;;
  esac

# scope信息
  get_commit_scope

  echo "${highlightOrange}请输入$prefix 类型的提交信息:${normal}"

  while true; do
    read message
    if [ ${#message} -lt 2 ]; then
       echo "${highlightRed}提交信息字数不能少于2个${normal}"
    else break
    fi
  done

  echo "${highlightOrange}请输入本次变更详细信息:${normal}"
  read describe



  commit_message="$prefix($scopeMessage): $message\n $describe"
  echo 1111,$commit_message

  # 执行Git提交
  if [ -n "$commit_message" ]; then
      git commit -m "$commit_message"
      if [ $? -eq 0 ]; then
          echo ${highlight}"commit 提交成功！分支名为："$current_branch${normal}
          return
      else
          echo ${highlightRed}"commit 提交失败，请检查您的Git仓库状态或提交信息是否正确。"${normal}
          return 1
      fi
  else
      echo ${highlightRed}"commit 提交失败，未获取到有效的提交信息，提交被取消。"${normal}
      return 1
  fi
}

# git add .
if [[ ${allStep} -eq 1 ]] ; then
  git add .
  echo "git add ."
fi

# git commit 调用主函数
get_commit_type_and_message
if [ $? -eq 0 ]; then
    # git push
    if [ ${allStep} -eq 1 ] ; then
      git push
      if [ $? -eq 0 ]; then
          echo ${highlight}"push 提交成功！分支名为："$current_branch${normal}
        else
          echo ${highlightRed}"push 提交失败，请检查您的Git仓库状态或提交信息是否正确。"${normal}
      fi
    fi
fi








