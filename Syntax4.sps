* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum mindfulness
  /HISTOGRAM
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=pain BY sex age STAI_trait pain_cat cortisol_saliva mindfulness
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

RECODE sex ('male'=0) ('female'=1) INTO sex_dummy.
EXECUTE.

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | COVTYPE(VC).
