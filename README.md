# CFD-Bayesian-Optimization

A simple Bayesian optimization method in MATLAB, with an interface to interact with simulations in ANSYS Workbench. This allows designs that are appropriately parameterized in ANSYS Workbench to be optimized based on ANSYS CFX simulation results.

Both single-objective and multi-objective Bayesian optimization are implemented.

## Structure

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

## License

This work is released under the MIT license.

## Using this Repo

*(Please note that this section and the one below were written several years after my original work on this repo, plenty of time for me to forget most of the details. I would recommend using this repo only as a proof-of-concept. You will almost certainly come up with cleaner, more-reusable code if you start from scratch.)*

This repo was a bit of a hack job to automate simulating the performance of hydro turbines in ANSYS workbench (v17.1). I wanted to have an optimization algorithm choose the next turbine geometry to simulate and I didn't want to use one of ANSYS's built-in algorithms. I also wanted to have the simulations run around the clock without needing me to manually enter the optimization's next suggested geometry parameters into ANSYS WB and run the simulations.

The entry point to use this repo would be to create an instance of the [@MOSAO](https://github.com/rowan-walsh/CFD-Bayesian-Optimization/blob/master/%40MOSAO/MOSAO.m) class and then use its `initialize`, `run`, and `continue_run` methods. The code in the [`validate_options`](https://github.com/rowan-walsh/CFD-Bayesian-Optimization/blob/master/%40MOSAO/validate_options.m) private method can give you some idea as to what options are available for the optimization algorithm. The `functionHandle` parameter of the `MOSAO` constructor is important: this is the handle to the "black-box" function that the algorithm will attempt to optimize.

In my case I added the [@WBpackage](https://github.com/rowan-walsh/CFD-Bayesian-Optimization/blob/master/%40WBpackage/WBpackage.m) class to stand in as this "black-box" function by dispatching simulations in ANSYS workbench (see below). For example, after creating an instance of `WBpackage` called `WBpack`, it could be used for the `MOSAO` constructor's `functionHandle` parameter with the form `@(x) WBpack.simulate(x, 'seek')`. But really any other function with the right form could be optimized here.

## Generalizing from this Repo

Ideally this repo should generalize to any ANSYS workbench setup you have that uses the design points table to parameterize your simulations (some amount of input parameters drive the geometry and/or simulation, and some amount of output parameters to optimize are calculated from the simulation results). That being said, MATLAB is pretty clunky and if I was doing this work again today I would likely use Python; it looks like it has a few Bayesian optimization packages out now.

The most useful aspect of this repo now might be as a demonstration that it is **possible** to use a design-points-table-driven ANSYS workbench project as the "black box function" for an optimization algorithm. This was done with the [@WBinstance](https://github.com/rowan-walsh/CFD-Bayesian-Optimization/tree/master/%40WBinstance) class. It would build (line-by-line) an IronPython script to execute with an ANSYS workbench project, and then interpret any result files output by the script. The script was generated on the fly to do things like:

-  Save the data from previously-simulated design points in the WB project's design point table to a file and then retrieve the values so they could be used by the next iteration of the optimization algorithm.
- Add new design points to the WB project (based on the optimization algorithm's suggested next point to sample) and then have ANSYS WB run a simulation of the new point.
- Save and import any log messages from the simulation, to parse and check for any errors. This was important, because certain geometries suggested by the optimization were not physically possible (self-intersection, etc). The optimization algorithm needed to treat these points in the parameter space differently from points that gave valid results.
