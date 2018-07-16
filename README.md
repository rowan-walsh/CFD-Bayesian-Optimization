
# CFD-Bayesian-Optimization

A simple Bayesian optimization method in MATLAB, with an interface to interact with simulations in ANSYS Workbench. This allows designs that are appropriately parameterized in ANSYS Workbench to be optimized based on ANSYS CFX simulation results.

Both single-objective and multi-objective Bayesian optimization are implemented.

### Summary

TBC

### License

This work is released under the MIT license.

### Structure

- *MOSAO*
  Bayesian optimization method

  - *Database*
    Database object used to collect results from all objective function calls during an optimization
    
- *WBpackage*
  Packages a *WBinstance* object so that it can be queried as a 'black box' for the *MOSAO* optimization

  - *WBinstance*
    MATLAB to ANSYS Workbench interface: geometry generation, mesh generation, and CFX simulations can be scripted to run in ANSYS Workbench, results are collected in the MATLAB *WBinstance* object
    
    - *WBdesignPointList*
      A MATLAB copy of the list of design points in a ANSYS Workbench file
     
- *FunctionSuite*
  Set of common optimization benchmarking functions
