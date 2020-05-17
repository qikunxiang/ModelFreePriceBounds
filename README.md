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

+ func/LSIP/      contains the implementation of the ECP algorithm and the ACCP algorithm
    - lsipecpalgo_gurobi.m:            the implementation of the ECP algorithm
    - lsipaccpalgo_gurobi.m:           the implementation of the ACCP algorithm
    - polytopecenterempty_gurobi.m:    the subroutine to determine whether a polytope is empty and its Chebyshev center

+ func/sim/       contains functions related to simulating option prices for the experiments
    - lognormoptprice.m:               the subroutine to compute the price of vanilla call and put options under a log-normal distribution
    - simoptprice.m:                   used for computing the prices of all options via analytic expressions and Monte Carlo integration
    - roundprice.m:                    used for rounding the bid and ask prices 
    - nonreplprice.m:                  a utility function used for structuring the prices

+ exp/            contains the scripts to run the experiments (see later)

+ utils/          contains external libraries
    - utils/tight_subplot/:             used for creating figures with narrow margins

# Instruction to run the experiments

## Configurations

+ All folders and subfolders must be added to the search path. 
+ Gurobi optimization must be installed on the machine and relevant files must be added to the search path. 


## Experiment 1

+ First, run exp/exp1/robust_exp1_gen.m to generate the data file.
+ Then, run exp/exp1/accp/robust_exp1_accp_all.m and exp/exp1/ecp/robust_exp1_ecp_all.m to generate output files.
+ Finally, run exp/exp1/robust_exp1_examine.m to compare the output, run exp/exp1/accp/robust_exp1_accp_plot.m and exp/exp1/ecp/robust_exp1_ecp_plot.m to plot the output.


## Experiment 2

+ First, run exp/exp2/robust_exp2_gen.m to generate the data file.
+ Then, run exp/exp2/accp/robust_exp2_accp_all.m and exp/exp2/ecp/robust_exp2_ecp_all.m to generate output files.
+ Finally, run exp/exp2/robust_exp2_examine.m to compare the output, run exp/exp2/accp/robust_exp2_accp_plot.m and exp/exp2/ecp/robust_exp2_ecp_plot.m to plot the output.


## Experiment 3

+ First, run exp/exp3/robust_exp3_gen.m to generate the data file.
+ Then, run exp/exp3/accp/robust_exp3_accp.m and exp/exp3/ecp/robust_exp3_ecp.m to generate output files.
+ Finally, run exp/exp3/robust_exp3_examine.m to compare the output, run exp/exp3/accp/robust_exp3_accp_plot.m and exp/exp3/ecp/robust_exp3_ecp_plot.m to plot the output.


## Experiment 4

+ First, run exp/exp4/robust_exp4_gen.m to generate the data file.
+ Then, run exp/exp1/ecp/robust_exp4_ecp.m to generate the output file.
+ Finally, run exp/exp4/ecp/robust_exp4_ecp_plot.m to plot the output.


## Experiment 5

+ First, run exp/exp5/robust_exp5_gen.m to generate the data file (must run Experiment 2 first).
+ Then, run exp/exp5/accp/robust_exp5_accp1.m and exp/exp5/accp/robust_exp5_accp1.m to generate output files.
