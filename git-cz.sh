#!/bin/bash

# 检查当前目录是否为Git仓库
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "错误：当前目录不是一个Git仓库。"
    exit 1
fi

# 定义一个函数来显示提交类型选项并获取用户输入
function get_commit_type_and_message {
    echo "请选择提交类型（使用数字选择）:"
    echo "1. 🎉 feat: 新功能（feature）"
    echo "2. 🐛 fix: 修补bug"
    echo "3. 📚 docs: 文档（documentation）"
    echo "4. 💡 style: 格式（不影响代码运行的变动）"
    echo "5. 🚀 refactor: 重构（即不是新增功能，也不是修补bug的代码变动）"
    echo "6. 💖 perf: 性能改进"
    echo "7. 🚨 test: 增加测试"
    echo "8. 🚸 chore: 构建过程或辅助工具的变动"
    echo "请输入你的选择（例如：1）: "
    read choice

    # 验证用户输入
    if ! [[ $choice =~ ^[1-8]$ ]]; then
        echo "无效的选择，请重新运行脚本。"
        exit 1
    fi

    # 根据用户的选择，提示输入相应的提交信息
    case $choice in
        1)
            prefix="feat:"
            ;;
        2)
            prefix="fix:"
            ;;
        3)
            prefix="docs:"
            ;;
        4)
            prefix="style:"
            ;;
        5)
            prefix="refactor:"
            ;;
        6)
            prefix="perf:"
            ;;
        7)
            prefix="test:"
            ;;
        8)
            prefix="chore:"
            ;;
    esac

    echo "请输入$prefix类型的提交信息（以'$prefix'开头）:"
    read commit_message

    # 验证提交信息是否以正确的前缀开头
    if [[ ! $commit_message == $prefix* ]]; then
        echo "错误：提交信息应以'$prefix'开头。"
        exit 1
    fi

    # 返回到脚本的调用者，并传递提交信息
    echo "$commit_message"
}

# 调用函数并捕获提交信息
commit_message=$(get_commit_type_and_message)

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