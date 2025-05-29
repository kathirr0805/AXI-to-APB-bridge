# AXI3 Interconnect (AXI to APB Bridge)

This project implements an AXI3-compliant interconnect module in Verilog, designed to bridge AXI3 master interfaces to APB-compatible slave interfaces. It serves as a fundamental component in system-on-chip (SoC) designs where high-performance AXI masters need to communicate with simpler, low-power APB peripherals.

## 📁 Project Structure

```bash
├── axi3_interconnect.v         # Main AXI3 interconnect design (supports multiple masters/slaves)
├── axi3_interconnect_tb.v      # Testbench for functional simulation
├── axi3_interconnect_tb_behav.wcfg  # Vivado waveform configuration
├── schematic.pdf               # RTL schematic visualization
```

## 🧠 Key Features

- Supports **AXI3 write channel** transactions (`AW`, `W`, `B`)
- Two AXI master interfaces (M0 and M1)
- Two APB slave interfaces (S0 and S1)
- Implements handshaking signals for:
  - Address Write (`AWVALID`, `AWREADY`)
  - Write Data (`WVALID`, `WREADY`)
  - Write Response (`BVALID`, `BREADY`)
- Register-based pipelining for timing optimization
- Synchronous reset and clock domains

- ## Access Project Files

All project simulation files, including Verilog source code : https://edaplayground.com/x/AJxU

## ⚙️ Interface Description

### AXI3 Master Inputs
- `M*_AWADDR[31:0]`, `M*_AWVALID`, `M*_AWBURST`, `M*_AWLEN`, `M*_AWSIZE`
- `M*_WDATA[31:0]`, `M*_WVALID`, `M*_WSTRB`, `M*_WLAST`
- `M*_BREADY`

### APB Slave Outputs
- `S*_AWREADY`, `S*_WREADY`, `S*_BVALID`, `S*_BRESP`

### Global Signals
- `ACLK`: System clock
- `ARESETn`: Active-low synchronous reset

## 🔍 Schematic Overview

The design includes multiple control modules for each slave interface (`S0`, `S1`) such as:
- `AWREADY`, `WREADY`, and `BVALID` logic blocks
- Asynchronous and synchronous registers (`RTL_REG_ASYNC`)
- MUXes and AND gates to handle channel logic

Refer to `schematic.pdf` for the full RTL block-level representation.

## 🧪 Simulation

Use `axi3_interconnect_tb.v` as the testbench to simulate:
- Concurrent write accesses from both masters
- Proper handshaking and acknowledgment behavior from both slaves

### Simulation Tools:
- Xilinx Vivado
- ModelSim
- Icarus Verilog (IVerilog)

## ✅ Test Scenarios Covered

- Single master, single slave write
- Multiple masters writing to different slaves
- Handshaking timing verification
- Reset behavior and corner case testing

## 📌 Future Improvements

- Add support for AXI read channel (`AR`, `R`)
- Extend to support more slaves via arbitration
- Integrate with an APB slave peripheral
- Introduce AXI-lite support for simpler IP integration

## 📜 License

This project is open-source and intended for academic and educational use. Attribution appreciated.

## ✍️ Author

**Kathir S**  
Department of Electronics and Communication Engineering  
Anna University, Coimbatore  
Email: itz.kathir2005@gmail.com  
LinkedIn: [linkedin.com/in/kathir2005](https://linkedin.com/in/kathir2005)
