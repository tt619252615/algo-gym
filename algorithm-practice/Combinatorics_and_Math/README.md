# 魔法学校智力测试 —— 网格路径计数

> **难度定位**：中等偏难 | **核心知识**：组合数学 · 坐标压缩 · 前缀乘积 · 模运算

---

## 一、读懂题目

### 1.1 场景描述

想象一所魔法学校，教室排列成一个 $n$ 行 $m$ 列的网格。

- 每一**行** $i$ 有一个"能量等级" $R[i]$
- 每一**列** $j$ 有一个"能量等级" $C[j]$

```
       列0    列1    列2    列3
      C=1    C=2    C=2    C=4
       │      │      │      │
行0 R=1  (0,0)  (0,1)  (0,2)  (0,3)
行1 R=1  (1,0)  (1,1)  (1,2)  (1,3)
行2 R=3  (2,0)  (2,1)  (2,2)  (2,3)
行3 R=5  (3,0)  (3,1)  (3,2)  (3,3)
```

### 1.2 移动规则

每一步，你只能做以下两种操作之一：

| 操作 | 条件 |
|------|------|
| **换行**：从行 $r$ 移到行 $r'$ | 必须 $R[r'] > R[r]$（能量严格升高） |
| **换列**：从列 $c$ 移到列 $c'$ | 必须 $C[c'] > C[c]$（能量严格升高） |

> **注意**：每步只能改变行**或**列，不能同时改变两者。

### 1.3 目标

给定起点 $(sr, sc)$ 和终点 $(tr, tc)$，问有多少条不同的路径？
答案对 $10^9 + 7$ 取模。

### 1.4 一个小例子

用上面的网格，从 $(0,0)$ 走到 $(2,2)$：

```
R[0]=1, R[2]=3  → 行能量需要升高 ✓（合法目标）
C[0]=1, C[2]=2  → 列能量需要升高 ✓（合法目标）
```

所有合法路径（R表示换行，C表示换列）：

```
路径1：换行(0→2)，换列(0→1)，换列(1→2)   ← 先升行，再升两次列
路径2：换列(0→1)，换行(0→2)，换列(1→2)
路径3：换列(0→1)，换列(1→2)，换行(0→2)   ← 先升两次列，再升行
...
```

---

## 二、暴力思路（理解问题本质）

最直接的想法：DFS/BFS 从起点出发，枚举所有下一步，累计路径数。

```
                 (0,0) R=1,C=1
                /              \
         换行到R=3           换列到C=2
           (2,0)               (0,1)或(0,2)
            ...                   ...
```

**问题**：格子数可达 $10^5 \times 10^5$，路径数天文数字，暴力必然超时。

---

## 三、关键突破：行列独立性

### 3.1 发现规律

仔细观察：**换行时列不变，换列时行不变**。

这意味着行的移动序列和列的移动序列**完全互不干扰**，可以分开考虑！

```
把一条完整路径拆开来看：

完整路径：  (0,0) → 换行 → (2,0) → 换列 → (2,1) → 换列 → (2,2)

行的变化：   0  ────────→  2  ──────────────────────────  2
列的变化：   0  ─────────────────────→  1  ─────────→  2
```

**行序列**：$0 \to 2$（走了1步）
**列序列**：$0 \to 1 \to 2$（走了2步）

这两个序列**完全独立**地决定各自的选择，最后再把步骤"穿插"在一起。

### 3.2 拆分公式

$$\text{答案} = \underbrace{\text{ways\_r}}_{\text{行的走法数}} \times \underbrace{\text{ways\_c}}_{\text{列的走法数}} \times \underbrace{\binom{\text{step\_r}+\text{step\_c}}{\text{step\_r}}}_{\text{穿插方案数}}$$

接下来分别解释这三项。

---

## 四、计算单维度走法数

以**行维度**为例（列完全对称）。

### 4.1 什么是"行的走法"

从行 $sr$ 走到行 $tr$，中间必须经过若干行，且行权值**严格递增**。

> 重要约束：不能跳过权值等级。如果 $R$ 的唯一值为 $[1, 2, 3]$，从等级0走到等级2，**必须经过等级1**。

为什么？因为题目要求的是严格递增，且路径需要计数，中间所有等级都必须被"跨越"到。

### 4.2 坐标压缩：把权值变成等级

$R$ 数组可能有重复值，先去重排序，得到"等级"：

```
原始 R = [3, 1, 1, 2, 2, 3]

去重排序 → unique = [1, 2, 3]
等级映射 → rank:  1→0,  2→1,  3→2

原始索引：  0    1    2    3    4    5
行的权值：  3    1    1    2    2    3
行的等级：  2    0    0    1    1    2
           └─2个等级2─┘  └─2个等级1─┘  └─2个等级0─┘

counts = [2, 2, 2]   ← 每个等级有多少行
          ↑  ↑  ↑
         等0 等1 等2
```

### 4.3 中间层的选择

从等级 $rs$（行 $sr$ 的等级）走到等级 $rt$（行 $tr$ 的等级）：

```
等级 0         等级 1         等级 2
(R=1)          (R=2)          (R=3)
  行1 ────────→  行3  ────────→  行0
  行2 ────────↗  行4  ────────↗  行5

 起点固定          可以选           终点固定
（题目给定）     行3 或 行4        （题目给定）
```

- **起点**：固定为 $sr$，不需要选择
- **中间层**（等级 $rs+1$ 到 $rt-1$）：每层可以选该层的任意一行，共 $\text{counts}[i]$ 种选法
- **终点**：固定为 $tr$，不需要选择

$$\text{ways\_r} = \prod_{i=rs+1}^{rt-1} \text{counts}[i]$$

| 情况 | ways\_r | step\_r |
|------|---------|---------|
| $sr = tr$（不动） | 1 | 0 |
| 相邻等级（$rt - rs = 1$） | 1 | 1 |
| 跨越多个等级 | 中间各等级的 counts 连乘 | $rt - rs$ |

---

## 五、前缀乘积：让区间连乘变成 O(1)

每次查询都从 $rs+1$ 连乘到 $rt-1$ 会很慢，用**前缀乘积**优化：

### 5.1 构建前缀乘积

```
counts       =  [ 2,   2,   3,   1  ]
                  ↓    ↓    ↓    ↓
prefix_prod  =  [ 1,   2,   4,  12,  12 ]
               [0]  [1]  [2]  [3]  [4]
                ↑
              哨兵（初始值1）
```

定义：`prefix_prod[i] = counts[0] × counts[1] × ... × counts[i-1]`

### 5.2 O(1) 查询区间连乘

要求 $\text{counts}[rs+1] \times \cdots \times \text{counts}[rt-1]$：

```
         ← 这段 →
counts:  [2,  2,  3,  1]
prefix:  [1,  2,  4, 12, 12]
              ↑           ↑
           prefix[rs+1]  prefix[rt]

区间连乘 = prefix[rt] / prefix[rs+1]
```

**模意义下的除法**：

普通除法在模运算中不能直接用，需要用**费马小定理**求"模逆元"：

$$a^{-1} \equiv a^{p-2} \pmod{p} \quad (p \text{ 为质数})$$

$$\frac{\text{prefix}[rt]}{\text{prefix}[rs+1]} \equiv \text{prefix}[rt] \times \text{prefix}[rs+1]^{p-2} \pmod{p}$$

---

## 六、穿插方案数：组合数 C(n,r)

行走 `step_r` 步，列走 `step_c` 步，总共 `step_r + step_c` 步。
在这些步骤的位置中，选哪几步走行，其余走列：

```
假设 step_r=2, step_c=2，共4步，选2步走行：

第1步  第2步  第3步  第4步     方案
  行    行    列    列         [R,R,C,C]
  行    列    行    列         [R,C,R,C]
  行    列    列    行         [R,C,C,R]
  列    行    行    列         [C,R,R,C]
  列    行    列    行         [C,R,C,R]
  列    列    行    行         [C,C,R,R]

共 C(4,2) = 6 种
```

$$\binom{n}{r} = \frac{n!}{r!(n-r)!}$$

### 6.1 预处理阶乘，实现 O(1) 求组合数

直接每次算阶乘太慢，提前算好：

```python
# 预处理
fact[0] = 1
fact[i] = fact[i-1] * i % MOD        # 阶乘

# 逆阶乘（从末尾往前推）
inv_fact[MAX] = pow(fact[MAX], MOD-2, MOD)   # 费马小定理
inv_fact[i]   = inv_fact[i+1] * (i+1) % MOD  # 递推

# O(1) 查询
C(n, r) = fact[n] * inv_fact[r] * inv_fact[n-r] % MOD
```

---

## 七、合法性检查

在计算之前，先快速判断路径是否存在：

```python
# 如果行发生变化，但目标行能量 <= 起始行能量 → 不可能到达
if sr != tr and R[sr] >= R[tr]:
    return 0

# 如果列发生变化，但目标列能量 <= 起始列能量 → 不可能到达
if sc != tc and C[sc] >= C[tc]:
    return 0
```

---

## 八、完整流程总览

```
输入：n行m列，R[]行权值，C[]列权值，T个查询

┌─────────────────── 预处理（仅一次）─────────────────────┐
│                                                        │
│  1. 预处理阶乘表 fact[] 和 inv_fact[]                   │
│                                                        │
│  2. 行维度处理：                                        │
│     R[] → 去重排序 → 计算 counts_R → 计算 prefix_R     │
│                                                        │
│  3. 列维度处理：                                        │
│     C[] → 去重排序 → 计算 counts_C → 计算 prefix_C     │
│                                                        │
└────────────────────────────────────────────────────────┘

对每个查询 (sr, sc) → (tr, tc)：

  Step 1: 合法性检查
          R[sr] < R[tr] 且 C[sc] < C[tc]（若行/列有变化）

  Step 2: 行维度
          rs = rank_R[R[sr]], rt = rank_R[R[tr]]
          step_r = rt - rs
          ways_r = prefix_R[rt] / prefix_R[rs+1]  （模意义除法）

  Step 3: 列维度
          同理得 step_c, ways_c

  Step 4: 合并
          ans = ways_r × ways_c × C(step_r + step_c, step_r)  mod (10^9+7)
```

---

## 九、代码逐行解读

```python
class Solution:
    _fact = [1] * MAX_N
    _inv_fact = [1] * MAX_N
    _precomputed = False
```
> 把阶乘表设为**类变量**，多次调用 `Solution` 时不重复预处理。

---

```python
    @classmethod
    def _precompute(cls):
        if cls._precomputed:
            return
        for i in range(1, MAX_N):
            cls._fact[i] = cls._fact[i - 1] * i % MOD
        cls._inv_fact[MAX_N - 1] = pow(cls._fact[MAX_N - 1], MOD - 2, MOD)
        for i in range(MAX_N - 2, -1, -1):
            cls._inv_fact[i] = cls._inv_fact[i + 1] * (i + 1) % MOD
        cls._precomputed = True
```
> 先正向算阶乘，再**从末尾反推**逆阶乘（利用递推关系 $\text{inv\_fact}[i] = \text{inv\_fact}[i+1] \times (i+1)$）。

---

```python
    def _build_dim(self, arr):
        unique = sorted(set(arr))          # 去重排序，得到所有等级
        rank = {v: i for i, v in enumerate(unique)}  # 值 → 等级编号
        counts = [0] * len(unique)
        for v in arr:
            counts[rank[v]] += 1           # 统计每个等级的行（列）数
        prefix_prod = [1] * (len(unique) + 1)
        for i, c in enumerate(counts):
            prefix_prod[i + 1] = prefix_prod[i] * c % MOD  # 前缀乘积
        return rank, prefix_prod
```
> 一次遍历完成坐标压缩和前缀积构建。

---

```python
    def _get_ways(self, sv, tv, rank, pref):
        if sv == tv:   return 1, 0    # 不动，1种走法，0步
        if sv > tv:    return 0, 0    # 能量下降，不可达
        rs, rt = rank[sv], rank[tv]
        steps = rt - rs
        if steps == 1: return 1, 1    # 相邻等级，中间无选择
        # 区间连乘：pref[rt] / pref[rs+1]
        ways = pref[rt] * pow(pref[rs + 1], MOD - 2, MOD) % MOD
        return ways, steps
```
> 返回 `(走法数, 步数)` 二元组，供上层合并使用。

---

```python
        for sr, sc, tr, tc in queries:
            if (sr != tr and R[sr] >= R[tr]) or (sc != tc and C[sc] >= C[tc]):
                results.append(0); continue

            ways_r, step_r = self._get_ways(R[sr], R[tr], rank_R, pref_R)
            ways_c, step_c = self._get_ways(C[sc], C[tc], rank_C, pref_C)

            ans = ways_r * ways_c % MOD * self._nCr(step_r + step_c, step_r) % MOD
            results.append(ans)
```
> 三项直接相乘即为最终答案。

---

## 十、复杂度分析

| 阶段 | 时间复杂度 | 说明 |
|------|-----------|------|
| 阶乘预处理 | $O(MAX\_N)$ | 只做一次 |
| 维度压缩 | $O(n \log n + m \log m)$ | 排序去重 |
| 单次查询 | $O(\log MOD)$ | 一次 `pow` 求逆元 |
| $T$ 次查询 | $O(T \log MOD)$ | |
| **总体** | $O(MAX\_N + (n+m)\log n + T\log MOD)$ | |

---

## 十一、常见疑问

**Q：为什么不能跳过中间等级？**
A：因为题目规定每步只能换行或换列，且必须严格递增。如果当前行等级为0，目标为2，你必须先经过等级1的某行，否则无法"跨越"过去。

**Q：prefix_prod 的 `[rs+1]` 和 `[rt]` 索引是怎么来的？**
A：`prefix_prod[i] = counts[0..i-1]` 的乘积。中间层是 `counts[rs+1..rt-1]`，对应：
```
counts[rs+1..rt-1] = prefix_prod[rt] / prefix_prod[rs+1]
```

**Q：为什么起点和终点不乘 counts？**
A：起点是 `(sr, sc)` ——具体的某一格，已经固定了，不需要选；终点同理。只有中间路过的等级，才有"选哪行"的自由。

**Q：C(step\_r + step\_c, step\_r) 的含义？**
A：你要走 `step_r + step_c` 步，需要从中选 `step_r` 个位置走行步（剩下的走列步），即排列组合中的"组合数"。
