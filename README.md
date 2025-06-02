# BLDC Controller

### Master 1 Informatique - UE Simulation et Synthèse des Matériels
### Université de Toulouse / Faculté des Sciences et de l'Ingénieur
### 2024–2025 Academic year

## Authors
* LEGINYORA Iban
* CLUZEL Paul

## Table of Contents
1. [Project Description](#project-description)
2. [Files Description](#files-description)
3. [Running Simulations with Makefile](#running-simulations-with-makefile)
4. [Reference](#reference)

## Project Description

This repository contains the implementation of a **BLDC (Brushless Direct Current) motor controller** using VHDL. The goal of this practical lab was to design a logic component capable of :

* Sequencing the three motor phases using six transistors,
* Integrating speed control via **PWM**,
* Managing **ramp-up** and **ramp-down** to ensure safe operation,
* Optionally supporting feedback through a Hall sensor or optical sensor.

The context of the lab focuses on controlling a BLDC motor retrieved from a hard drive, offering a safer and cost-effective platform for development and testing.

## Files Description

* [`bldc_controller.vhdl`](./src/bldc-controller.vhd): Main VHDL component implementing the BLDC controller logic.
* [`test_bldc-controller.vhdl`](./src/test_bldc-controller.vhd): Testbench for simulating and verifying the controller behavior.
* [`Subject.pdf`](./Subject.pdf): Lab manual describing the objectives, theory, and instructions for the lab work.
* [`FR_CR_bldc-controller.pdf`](./FR_CR_bldc-controller.pdf) : The report produced explains the techniques used and the results obtained.

## Running Simulations with Makefile

To simulate and verify the behavior of the **BLDC controller**, a `Makefile` is provided to automate the compilation, elaboration, and simulation steps using **GHDL** and **GTKWave**.

### Step-by-step instructions

1. **Analyze the VHDL files**
   This step checks and compiles all VHDL files (controller and testbench):

   ```bash
   make a
   ```

2. **Elaborate the testbench entity**
   This step builds the simulation model for the testbench entity:

   ```bash
   make e
   ```

3. **Run the simulation and generate the VCD waveform file**
   This command executes the testbench and produces a `.vcd` file for waveform analysis:

   ```bash
   make r
   ```

4. **Visualize the simulation results with GTKWave**
   After the simulation, you can inspect signal waveforms using GTKWave:

   ```bash
   make run
   ```

### Additional Commands

* Clean all generated files (VCD, GHDL artifacts):

  ```bash
  make clean-all
  ```

* Display the help information:

  ```bash
  make help
  ```

These commands provide a convenient way to compile and test the VHDL design without manually invoking each GHDL command.


## Reference

This work is inspired by content from [Elektor Magazine – BLDC Beginner’s Guide](https://www.elektormagazine.fr/articles/contr%C3%B4le-des-moteurs-bldc-guide-du-d%C3%A9butant), as well as lectures and guidance provided by **Dr. THIBEOLT François (IRIT)**.

