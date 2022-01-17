# Model-free bounds for multi-asset options using option-implied information and their exact computation

+ By Ariel Neufeld, Antonis Papapantoleon, and Qikun Xiang
+ Article link (arXiv): https://arxiv.org/abs/2006.14288

# Description of files

+ func/main/      contains the core functions  
    - portcreate.m:                    function to create a portfolio structure from the specification of tranded and non-traded derivatives  
    - portsubset.m:                    function to create a portfolio structure as a subset of another portfolio structure
    - port2cpwl.m:                     function to convert a portfolio structure and the corresponding weights into a continuous piece-wise affine (linear) function
    - cpwleval.m:                      function to evaluate a continuous piece-wise affine function at a particular input point
    - cpwl2concmin.m:                  function to convert the minimization of a continous piece-wise affine function to a constrainted concave minimization problem
    - concmin2gurobi.m:                function to convert a constrained continuous piece-wise affine concave minimization problem into an MILP problem specified as a Gurobi problem structure
    - portlimcons.m:                   function to generate all radial constraints for the ECP algorithm
    - portpointcons.m:                 function to generate feasibility constraints at a collection of input points for the ECP algorithm and the ACCP algorithm
    - replportcons.m:                  utility function to transform the structure of constraints
    - weightcollapse.m:                utility function to transform the weights specified by the positive and negative parts into a single vector
    - weightexpand.m:                  utility function to transform the weights specified by a single vector into its positive and negative parts
    - weightmodify.m:                  utility function to transform two arbitrary non-negative vectors into weights specified by the positive and negative parts
    - optionpricesanitize.m:			  function to modify bid and ask prices of options to remove arbitrage opportunities

+ func/LSIP/      contains the implementation of the ECP algorithm and the ACCP algorithm
    - lsipecpalgo\_gurobi.m:            the implementation of the ECP algorithm
    - lsipaccpalgo\_gurobi.m:           the implementation of the ACCP algorithm
    - polytopecenterempty_gurobi.m:    the subroutine to determine whether a polytope is empty and its Chebyshev center

+ func/sim/       contains functions related to simulating option prices for the experiments
    - lognorm_partialexp.m:               a subroutine used to compute the price of vanilla call and put options under a (truncated) log-normal distribution
    - simoptprice.m:                   used for computing the prices of all options via analytic expressions and Monte Carlo integration
    - roundprice.m:                    used for rounding the bid and ask prices 
    - nonreplprice.m:                  a utility function used for structuring the prices

+ exp/            contains the scripts to run the experiments (see below)

+ data/			 contains the data file as well as a preprocessing script to generate a .mat file used in the real data experiment
	 - data/Data\_clean\_bid\_ask\_only.xlsx: Excel spreadsheet containing market prices of call and put options retrieved from https://www.marketwatch.com on 6 April, 2021
	 - data/data\_preprocess.m: a script that reads from data/Data\_clean\_bid\_ask\_only.xlsx and stores all data into a .mat file for the real data experiment

+ utils/          contains external libraries
    - utils/tight\_subplot/:             used for creating figures with narrow margins

# Instruction to run the experiments

## Configurations

+ All folders and subfolders must be added to the MATLAB search path. 
+ Gurobi optimization must be installed on the machine and relevant files must be added to the search path. 


## Experiment 1

+ Run exp/exp1/exp1\_gen.m to generate the data file.
+ Run exp/exp1/exp1\_ecp\_all.m to generate output files from the ECP algorithm.
+ Run exp/exp1/exp1\_accp\_all.m to generate output files from the ACCP algorithm.
+ Run exp/exp1/exp1\_examine.m to compare the output of two algorithms. 
+ Run exp/exp1/exp1\_plot.m to plot the results.


## Experiment 2

+ Run exp/exp2/exp2\_gen.m to generate the data file.
+ Run exp/exp2/exp2\_ecp\_VBS.m and exp/exp2/exp2\_ecp\_VBSR.m to generate output files from the ECP algorithm.
+ Run exp/exp2/exp2\_accp\_VBS.m and exp/exp2/exp2\_accp\_VBSR.m to generate output files from the ACCP algorithm.
+ Run exp/exp2/exp2\_examine.m to compare the output of two algorithms.
+ Run exp/exp2/exp2\_plot.m to plot the results.


## Experiment 3

+ Run exp/exp3/exp3\_gen.m to generate the data file.
+ Run exp/exp3/accp/exp3\_accp\_step1.m to compute the model-free price bounds of the call-on-min option and the put-on-min option. The model-free price bounds of the call-on-min option are [0.000, 0.859], and the model-free price bounds of the put-on-min option are [2.218, 3.222]. 
+ Run exp/exp3/accp/exp3\_accp\_step2.m and view the output.


## Experiment 4

### Step 0: generate the .mat input file.
+ Run data/data\_preprocess.m to generate a file exp/exp4/DIA.mat, which will be used in subsequent steps of the experiment.

### Step 1: examine the option prices to identify arbitrage opportunities. 
+ Run exp/exp4/sanitize/exp\_DIA\_before\_sanitize\_gen.m to generate data files for identifying arbitrage opportunities. 
+ Run exp/exp4/sanitize/exp\_DIA\_before\_sanitize\_ecp.m to identify arbitrage opportunities. The result is contained in the output rst. One can see that arbitrage opportunities are present among the prices of options written on 5 of the 30 underlying stocks: CVX, IBM, MMM, VZ, and WMT. 

### Step 2: remove outliers and adjust the options prices to remove arbitrage opportunities.
+ Run exp/exp4/sanitize/exp\_DIA\_sanitize.m to adjust the bid and ask prices to remove arbitrage opportunities and generate a new data file containing the modified prices. This script also removes the call and put options written on CVX with strikes below $50 since their prices are anomalous. Please refer to Figure EC.1 in the paper. 
+ Run exp/exp4/exp\_DIA\_plot\_bidask.m to plot some samples of option prices. This script also counts the number of option prices modified as a result of exp/exp4/sanitize/exp\_DIA\_sanitize.m.

### Step 3: re-examine the option prices to confirm that all arbitrage opportunities have been removed.
+ Run exp/exp4/sanitize/exp\_DIA\_after\_sanitize\_gen.m to generate data files for identifying arbitrage opportunities among the adjusted prices. 
+ Run exp/exp4/sanitize/exp\_DIA\_after\_sanitize\_ecp.m to identify arbitrage opportunities among the adjusted prices. The result is contained in the output rst. One can see that no arbitrage opportunity is identified since all entries of rst are 0 (up to small numerical errors).  

### Step 4: use the option prices to compute model-free price bounds for two basket call options.
+ Run exp/exp4/exp\_DIA\_gen1.m and exp/exp4/exp\_DIA\_gen2.m to generate data files used for computing the model-free price bounds for two basket call options. 
+ Run exp/exp4/exp\_DIA2\_ecp\_V25.m, exp/exp4/exp\_DIA2\_ecp\_V50.m, exp/exp4/exp\_DIA2\_ecp\_V100.m, and exp/exp4/exp\_DIA2\_ecp\_V100B.m in succession to generate output files containing the model-free price bounds for the second basket call option. 
+ Run exp/exp4/exp\_DIA1\_ecp\_V25.m, exp/exp4/exp\_DIA1\_ecp\_V50.m, exp/exp4/exp\_DIA1\_ecp\_V100.m, and exp/exp4/exp\_DIA1\_ecp\_V100B.m in succession to generate output files containing the model-free price bounds for the first basket call option. 
+ Run exp/exp4/exp\_DIA\_plot\_results.m to plot the results. 
