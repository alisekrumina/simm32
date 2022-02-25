* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
DESCRIPTIVES VARIABLES=pain age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=pain sex age STAI_trait pain_cat cortisol_serum mindfulness
  /HISTOGRAM
  /ORDER=ANALYSIS.

EXAMINE VARIABLES=pain BY sex age STAI_trait pain_cat cortisol_serum mindfulness
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

RECODE sex ('male'=0) ('female'=1) (MISSING=SYSMIS) INTO sex_dummy.
EXECUTE.

USE ALL.
COMPUTE filter_$=(pain_cat <= 52).
VARIABLE LABELS filter_$ 'pain_cat <= 52 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /METHOD=ENTER age sex_dummy
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN
  /SAVE PRED COOK RESID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=ID COO_1 MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: ID=col(source(s), name("ID"), unit.category())
  DATA: COO_1=col(source(s), name("COO_1"))
  GUIDE: axis(dim(1), label("ID"))
  GUIDE: axis(dim(2), label("Cook's Distance"))
  GUIDE: text.title(label("Simple Scatter of Cook's Distance by ID"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: point(position(ID*COO_1))
END GPL.


USE ALL.
COMPUTE filter_$=(COO_1   <=  0.025).
VARIABLE LABELS filter_$ 'COO_1   <=  0.025 (FILTER)'.
VALUE LABELS filter_$ 0 'Not Selected' 1 'Selected'.
FORMATS filter_$ (f1.0).
FILTER BY filter_$.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /METHOD=ENTER age sex_dummy
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

COMPUTE resid_sq=RES_2 * RES_2.
EXECUTE.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT resid_sq
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /METHOD=ENTER age sex_dummy
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.

REGRESSION
  /MISSING LISTWISE
  /STATISTICS COEFF OUTS CI(95) BCOV R ANOVA COLLIN TOL CHANGE SELECTION
  /CRITERIA=PIN(.05) POUT(.10)
  /NOORIGIN 
  /DEPENDENT pain
  /METHOD=ENTER age sex_dummy
  /METHOD=ENTER age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /SCATTERPLOT=(*ZRESID ,*ZPRED)
  /RESIDUALS DURBIN NORMPROB(ZRESID)
  /SAVE PRED COOK RESID.
