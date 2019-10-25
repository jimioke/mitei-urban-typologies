README.txt


DESCRIPTION OF R SCRIPTS
<mplus-prep.r>
Scales and formats data to run in Mplus, with or without mean imputation

OUTPUTS:
	.dat files to run in MPlus

<cluster-analyses.r>
Performs clustering and plots dendrogram

<fit-metrics.r>
Compute LSI (loading simplicity index) for varying factor solutions

<fscore-analyses.r>
Computes factor scores using mean-imputed data
Computes missingness rate
Plots factor loadings
Computes loading statistics

INPUTS:
	'efa/variable_order_mplus.csv' (variable order)
	'data/urbandata2019-64var-citynames-countries.csv' (city names)
	'efa/mean-imputation-<num-fac>f-loadings-missing-sig.csv'
	'urbandata2019-64var-id-sorted-updated.dat'
	'urbandata2019-64var-id-sorted-updated-missing.dat'
	
OUTPUTS: 
	'fscores-mean-imputed.csv'
	'loadings-64-variables-9-factors.pdf' (loading plot)


<iterate.r>
Iteratively inmputes missing data with typology averages
The iteration loop sources the following scripts in order: 
	(i)   <fscore-analyses.r>
	(ii)  <cluster-analyses.r>
	(iii) <typology-mean-iteration.r>


<typology-profiles.r>
Computes typology averages of the 64 indicators used in the clustering
Computes typology averages of the 9 factors
Generates radar/spider plots for each or all of the typologies

RUNNING THE EXPLORATORY FACTOR ANALYSIS IN MPLUS
1) Run the mplus-prep.r script
2) In the same folder, call MPlus on the 'urban2019-var65-f3-f12-geomin-fiml.inp' to estimate results from 3- to 12-factor models
3) In the folder mplus, call MPlus on the 'urban2019-var64-f9-geomin-fiml.inp' to run the 9-factor-only case
4) The output files produced are saved with the same but with extension '.out'
5) These outputs are processed into

NOTES: 
- The results from Step (2) are manually processed into the Excel files:
	- 'missing-loadings-f3-f12.xlsx' (loading matrix for all 10 factor solutions, each in a different sheet, without any indication of signficance)
	- 'missing-loadings-f3-f12-sig.xlsx' (loading matrix for all 10 factor solutions with signficant loadings indicated by *)
	- 'missing-loadings-f3-f12-sig-2.xlsx' (loading matrix for all 10 solutions with all insgificant loadings set to zero)
	- 'missing-structure-f3-12.xlsx' (structure matrices of all the 10 factor solutions)
	
- The results from Step (3) are manually processed into the CSV files: 'efa/9f-loadings-missing.csv' and 'efa/9f-loadings-missing-sig.csv'
In the latter file, the statistically insigifnicant loadings are set to zero.

- In Step (3): after running fit-metrics.r and fscore-analyses.r, we choose the 9-factor solution.
To obtain a better solution since we only have one model, we use 4 integration points instead of 3 in the f3-f12.
Thus, the final loadings obtained are slightly different than those seen in the f3-f12 case.

============================================================================================================================================

Order in which to run scripts:
1. mplus-prep.r; then run Mplus externally using the .inp file in the Mplus folder
2. fit-metrics.r: to compute LSI
3. iterate.r: iteratively impute cluster means into dataset, compute scores and perform cluster analyses
4. typology-profiles.r: obtain cluster averages and generate spider plots (Fig4)

To obtain the map and plot other variables by typology, run:
5. map/clustermap.py (Fig5)
