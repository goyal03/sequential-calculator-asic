# 16-bit Sequential Calculator

A complete RTL-to-GDS ASIC implementation of a sequential arithmetic calculator supporting addition, subtraction, multiplication, and division operations.

## Features

- **16-bit Data Width**: Supports operands from 0 to 65,535
- **Four Operations**: 
  - Addition (1 cycle)
  - Subtraction (1 cycle)
  - Multiplication (16 cycles, shift-and-add algorithm)
  - Division (16 cycles, restoring division algorithm)
- **FSM-based Control**: Clean state machine architecture
- **Error Handling**: Division by zero detection
- **Overflow Detection**: Multiplication overflow flag

## Design Architecture

The calculator uses a 3-state FSM:
- **IDLE**: Waiting for start signal
- **CALC**: Performing operation
- **DONE**: Result ready, waiting for acknowledgment

## Project Structure
```
calculator_project/
├── rtl/              # RTL design files
│   └── calculator.v
├── tb/               # Testbench files
│   └── calculator_tb.v
├── sim/              # Simulation outputs
├── synthesis/        # Synthesis scripts and outputs
│   └── synth.ys
└── README.md
```

## Tools Used

- **Simulation**: Icarus Verilog, GTKWave
- **Synthesis**: Yosys
- **Place & Route**: OpenLane
- **PDK**: SkyWater 130nm
- **Layout Viewer**: KLayout

## How to Run

### RTL Simulation
```bash
cd sim
iverilog -o calculator_sim ../rtl/calculator.v ../tb/calculator_tb.v
vvp calculator_sim
gtkwave calculator_tb.vcd
```

### Synthesis
```bash
cd synthesis
yosys synth.ys
```

### Post-Synthesis Simulation
```bash
cd sim
iverilog -o synth_sim ../synthesis/synth_calculator.v ../tb/calculator_tb.v /usr/share/yosys/simcells.v
vvp synth_sim
```

## Verification

The design includes 50+ comprehensive test cases covering:
- Basic arithmetic operations
- Edge cases (zero, maximum values)
- Division by zero
- Overflow conditions

All tests pass with 100% success rate.

## Results

- **Die Area**: 500µm × 500µm
- **Technology**: SkyWater 130nm
- **Status**: GDS generated, DRC/LVS clean

## Author
Harsh Agrawal