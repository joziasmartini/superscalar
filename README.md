# Analysis of Superscalarity in Quick Sort

This repository contains the experimental framework, source codes, and statistical logs concerning the quantitative and qualitative analysis of Instruction-Level Parallelism (ILP) and its impact on the *Quick Sort* algorithm. This study is grounded in cycle-accurate microarchitectural simulations using the **gem5** hardware simulator, contrasting a pure scalar processor against an Out-of-Order (O3) superscalar core.


## 📑 Project Overview

The primary objective of this research is to evaluate the practical and theoretical limits of superscalability when applied to divide-and-conquer sorting mechanisms (*Quick Sort*). The analysis concentrates on measuring the actual performance gains delivered by scaling the instruction issue width against inherent software bottlenecks, such as linear data dependencies and conditional branch instructions.

### Core Findings:
* **Execution Overhead Reduction:** An approximate **24.2%** decrease in simulated total CPU clock cycles.
* **IPC Advancement:** The average Instructions Per Cycle (IPC) progressed from **0.54** (scalar configuration) to **0.71** (superscalar configuration).
* **Microarchitectural Bottleneck:** Performance scaling did not behave linearly alongside a $4\times$ hardware resource layout extension. It was heavily bottlenecked by the algorithmic partition loop characteristics of Quick Sort, specifically dynamic conditional branching and short-term data hazards.


## 🗂️ Repository Structure

The project files are organized as follows:

```
├── Análise de Superescalabilidade no Algoritmo Quick Sort.pdf  # Full scientific paper (in Portuguese)
├── outorder.py                                                 # gem5 configuration script (O3 Architecture)
├── quick-sort.s                                                # Assembly RISC-V original source code
├── quick-sort.riscv                                            # Statically compiled RISC-V binary executable
├── stats_escalar.txt                                           # Raw metrics from the scalar simulation
└── stats_superescalar.txt                                      # Raw metrics from the superscalar simulation
```


## 🛠️ Experimental Methodology

The experimental framework was conducted via event-driven simulations leveraging the `gem5` core framework within a Linux host environment.

### Microarchitectural Specifications

| Parameter | Scalar Configuration | Superscalar Configuration |
| :--- | :--- | :--- |
| **CPU Model** | `SimpleProcessor` (In-Order) | `SimpleProcessor` (O3 - Out-of-Order) |
| **Pipeline Width (Fetch/Decode/Issue/Commit)** | 1 Instruction per Cycle | 4 Instructions per Cycle |
| **Clock Frequency** | 3 GHz | 3 GHz |
| **Cache Hierarchy** | Private L1I/L1D: 32 kB, L2: 256 kB | Private L1I/L1D: 32 kB, L2: 256 kB |
| **Main Memory** | Single Channel DDR3_1600 1GB | Single Channel DDR3_1600 1GB |
| **Instruction Set Architecture (ISA)** | RISC-V (64-bit) | RISC-V (64-bit) |


## 📊 Evaluation and Metrics

The following matrix presents the consolidated raw data retrieved from the experimental execution outputs (`stats_escalar.txt` and `stats_superescalar.txt`):

| Analyzed Metric | Scalar Configuration | Superscalar Configuration | Delta (%) |
| :--- | :--- | :--- | :--- |
| **Committed Instructions (`simInsts`)** | 131,585 | 131,585 | 0.00% |
| **Simulated CPU Clock Cycles (`numCycles`)** | 243,025 | 184,199 | -24.20% |
| **Instructions Per Cycle (IPC)** | 0.5414 | 0.7143 | +31.93% |
| **Predicted Conditional Branches** | 23,830 | 25,624 | +7.52% |
| **Branch Predictor Mispredictions** | 835 | 886 | +6.10% |

### Critical Analysis
Despite quadrupling the structural decode/issue pipeline capability ($4\times$), the effective IPC scaling saturated at a $\sim32\%$ margin. This phenomenon implies that the internal array partitioning routine within *Quick Sort* exhibits strict data-dependent runtime patterns (pivot-dependent comparisons). These characteristics generate inevitable instruction pipeline stalls and structural execution bubbles, reducing the active Out-of-Order window visibility from which independent instructions could be systematically extracted.


## 🚀 Execution Guide

### Prerequisites
Ensure your local system has the `gem5` simulator compiled alongside the RISC-V cross-compiler toolchain (`riscv64-unknown-elf-gcc`) if binary recompilation is required.

### 1. Source Assembly Compilation

The assembly source relies on static linking and allocation routines via standard libc calls:

```bash
riscv64-unknown-elf-gcc -static quick-sort.s -o quick-sort.riscv
```

### 2. Invoking the Simulation (O3 Superscalar Mode)

To launch the hardware environment modeling defined in outorder.py, execute:

```bash
gem5 outorder.py --binary ./quick-sort.riscv
```

The system will generate target files (stats.txt and config.ini) containing the parameters required to reproduce and audit the empirical conclusions of this study.

## ✒️ Authors
Jozias Martini Dequi – Federal University of Fronteira Sul (UFFS)

Caroline de Quadros Piazza – Federal University of Fronteira Sul (UFFS)

Marco Antonio Bernardeli da Veiga – Federal University of Fronteira Sul (UFFS)
