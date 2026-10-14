# 任务跟踪：GitHub

本仓库的任务与规格存放于 seasonZhu/RxStudy 的 GitHub Issues。
使用 gh CLI 操作，显式指定 --repo seasonZhu/RxStudy。

## 常用操作

- 创建：gh issue create --repo seasonZhu/RxStudy --title "标题" --body-file <正文文件>
- 读取：gh issue view <编号> --repo seasonZhu/RxStudy --json number,title,body,labels,comments
- 列表：gh issue list --repo seasonZhu/RxStudy --state open --json number,title,body,labels
- 评论：gh issue comment <编号> --repo seasonZhu/RxStudy --body-file <正文文件>
- 标签：gh issue edit <编号> --repo seasonZhu/RxStudy --add-label "标签"
  移除标签使用 --remove-label。
- 关闭：gh issue close <编号> --repo seasonZhu/RxStudy

多行正文写入临时文件，通过 --body-file 提交。

## 发布与读取约定

技能要求“发布到任务跟踪系统”时，创建 GitHub Issue。
技能要求“获取相关任务”时，读取对应 Issue。

## 拉取请求分诊

PRs as a request surface: no.

GitHub Issue 与 PR 共用编号；存在歧义时先判断资源类型。

## 子任务与依赖

优先使用当前 gh 版本支持的 GitHub 子任务功能。
不支持时，在子任务正文顶部写“Part of #<父任务编号>”，
并在父任务正文维护任务清单。

阻塞关系优先使用 GitHub 原生 Issue 依赖。
API 所需 issue_id 使用任务的数据库 ID，不使用任务编号或 node_id。
不可用时，在正文顶部写“Blocked by: #<编号>”。
所有阻塞任务关闭后，任务才可执行。

## wayfinder 约定

- 地图：使用 wayfinder:map 标签的 Issue，记录笔记、已有决策与待解问题。
- 子任务：关联地图，使用 wayfinder:research、wayfinder:prototype、
  wayfinder:grilling 或 wayfinder:task 标签。
- 选择：按地图顺序选择未分配且没有未关闭阻塞项的开放子任务。
- 认领：将任务分配给当前开发者。
- 完成：评论结果、关闭子任务，并将结果链接补充到地图的已有决策中。
