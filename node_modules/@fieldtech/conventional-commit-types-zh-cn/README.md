# conventional-commit-types-zh-cn

[![npm](https://img.shields.io/npm/v/@fieldtech/conventional-commit-types-zh-cn.svg?maxAge=2592000)](https://www.npmjs.com/package/@fieldtech/conventional-commit-types-zh-cn)
[![Build Status](https://img.shields.io/travis/FieldTech/conventional-commit-types-zh-cn.svg?maxAge=2592000)](https://travis-ci.org/FieldTech/conventional-commit-types-zh-cn)

提交注释类型列表。

## 说明

提供了如下几种注释类型，供开发者通过交互式命令行选择。

类型 | 类型说明 | 描述
:----------- | :----------- | :-----------
feat   |     Features   |      新功能
change    |   Changes  |      需求变更
fix   |     Bug Fixes    |      缺陷修复
test   |     Tests    |      新增或修改测试代码
design | Design | 新增或修改设计代码及文档
docs  |     Documentation |      文档变更
style |     Styles     |      代码格式调整，未涉及功能修改（如对齐、补全分号）
refactor  |     Code Refactoring     |     代码重构，未涉及功能或缺陷修复
perf   |     Performance Improvements    |      性能优化
build   |     Builds  |     构建工具或依赖管理调整
ci   |    Continuous Integrations    |     自动化构建脚本变更
chore   |     Chores    |     其它非代码或测试的变更
revert   |     Reverts    |     恢复到上一次版本



## 用途

作为 [simple-conventional-changelog](https://github.com/FieldTech/simple-conventional-changelog) 的中文默认提交类型，结合 [commitizen/cz-cli](https://github.com/commitizen/cz-cli) 中使用。
