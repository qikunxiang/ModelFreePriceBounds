# Model-free bounds for multi-asset options using option-implied information and their exact computation

+ By Ariel Neufeld, Antonis Papapantoleon and Qikun Xiang
+ Article link (arXiV): https://arxiv.org/abs/2006.14288
+ A supplementary document explaining how the market prices are repaired to remove arbitrage opportunities can be found in the depository with name Supplementary.pdf

# Description of files

+ Supplementary.pdf:  A supplementary document explaining how the arbitrage opportunities are removed from market data

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

+ exp/            contains the scripts to run the experiments (see later)

+ utils/          contains external libraries
    - utils/tight\_subplot/:             used for creating figures with narrow margins

# Instruction to run the experiments

## Configurations

+ All folders and subfolders must be added to the search path. 
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

+ Run exp/exp4/sanitize/exp\_DIA\_before\_sanitize\_gen.m to generate data files for identifying arbitrage opportunities. 
+ Run exp/exp4/sanitize/exp\_DIA\_before\_sanitize\_ecp.m to identify arbitrage opportunities. The result is contained in the output rst. One can see that arbitrage opportunities are present among the prices of options written on 5 of the 30 underlying stocks: CVX, IBM, MMM, VZ, and WMT. 
+ Run exp/exp4/sanitize/exp\_DIA\_sanitize.m to adjust the bid and ask prices to remove arbitrage opportunities and generate a new data file containing the modified prices. 
+ Run exp/exp4/sanitize/exp\_DIA\_after\_sanitize\_gen.m to generate data files for identifying arbitrage opportunities among the adjusted prices. 
+ Run exp/exp4/sanitize/exp\_DIA\_after\_sanitize\_ecp.m to identify arbitrage opportunities among the adjusted prices. The result is contained in the output rst. One can see that no arbitrage opportunity is identified since all entries of rst are 0. 
+ Run exp/exp4/exp\_DIA\_plot\_bidask.m to plot some samples of option prices. 
+ Run exp/exp4/exp\_DIA\_gen\_inc.m and exp/exp4/exp\_DIA\_gen\_sel.m to generate all data files used for computing the model-free price bounds. 
+ Run exp/exp4/exp\_DIA\_ecp\_V25.m, exp/exp4/exp\_DIA\_ecp\_V50.m, exp/exp4/exp\_DIA\_ecp\_V75.m, exp/exp4/exp\_DIA\_ecp\_V100.m, and exp/exp4/exp\_DIA\_ecp\_V100B.m in succession to generate output files for the first five cases. 
+ Run exp/exp4/exp\_DIA\_ecp\_V25prox.m and exp/exp4/exp\_DIA\_ecp\_V25proxB.m in succession to generate output files for the last two cases. 
+ Run exp/exp4/exp\_DIA\_print.m to print the results. 
