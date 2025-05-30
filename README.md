# BLDC Controller

## Subject & Academic Year

This project was developed as part of the **"UE Simulation et Synthèse des Matérielles"** course at the **Université de Toulouse / Faculté des Sciences et de l'Ingénieur**, during the **2024–2025 academic year**.

## Authors

* LEGINYORA Iban
* CLUZEL Paul

## Project Description

This repository contains the implementation of a **BLDC (Brushless Direct Current) motor controller** using VHDL. The goal of this practical lab was to design a logic component capable of:

* Sequencing the three motor phases using six transistors,
* Integrating speed control via **PWM**,
* Managing **ramp-up** and **ramp-down** to ensure safe operation,
* Optionally supporting feedback through a Hall sensor or optical sensor.

The context of the lab focuses on controlling a BLDC motor retrieved from a hard drive, offering a safer and cost-effective platform for development and testing.

## Files Description

* `bldc_controller.vhdl`: Main VHDL component implementing the BLDC controller logic.
* `pwm_generator.vhdl`: Module responsible for generating the PWM signal.
* `testbench_bldc.vhdl`: Testbench for simulating and verifying the controller behavior.
* `README.md`: This documentation file.
* `TP8_VHDL.pdf`: Lab manual describing the objectives, theory, and instructions for the TP (Travaux Pratiques).

## Reference

This work is inspired by content from [Elektor Magazine – BLDC Beginner’s Guide](https://www.elektormagazine.fr/articles/contr%C3%B4le-des-moteurs-bldc-guide-du-d%C3%A9butant), as well as lectures and guidance provided by **Dr. François Thiebolt (IRIT)**.

