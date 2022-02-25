* Encoding: UTF-8.

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /HISTOGRAM
  /ORDER=ANALYSIS.

RECODE sex ('female'=1) ('male'=0) INTO sex_dummy.
EXECUTE.

DESCRIPTIVES VARIABLES=pain1 pain2 pain3 pain4 age STAI_trait pain_cat cortisol_serum mindfulness
  /STATISTICS=MEAN STDDEV MIN MAX.



CORRELATIONS
  /VARIABLES=pain1 pain2 pain3 pain4
  /PRINT=TWOTAIL NOSIG FULL
  /MISSING=PAIRWISE.

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT | SUBJECT(ID) COVTYPE(VC)
   /SAVE=PRED.

MIXED pain WITH age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy Day
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT Day | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

SORT CASES BY ID.
SPLIT FILE SEPARATE BY ID.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Day MEAN(Pain)[name="MEAN_Pain"] obs_or_pred 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Day=col(source(s), name("Day"), unit.category())
  DATA: MEAN_Pain=col(source(s), name("MEAN_Pain"))
  DATA: obs_or_pred=col(source(s), name("obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("Day"))
  GUIDE: axis(dim(2), label("Mean Pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of Pain by Day by obs_or_pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Day*MEAN_Pain), color.interior(obs_or_pred), missing.wings())
END GPL.

DESCRIPTIVES VARIABLES=Day
  /STATISTICS=MEAN STDDEV MIN MAX.

DATASET ACTIVATE DataSet2.
COMPUTE day_centered=Day  -  2.5.
EXECUTE.

COMPUTE day_centered_sq=day_centered * day_centered.
EXECUTE.

MIXED pain_exp WITH age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy day_centered 
    day_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy day_centered day_centered_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT day_centered day_centered_sq | SUBJECT(ID) COVTYPE(UN).

SORT CASES BY ID.
SPLIT FILE SEPARATE BY ID.


MIXED pain_exp WITH age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy day_centered 
    day_centered_sq
  /CRITERIA=DFMETHOD(SATTERTHWAITE) CIN(95) MXITER(100) MXSTEP(10) SCORING(1) 
    SINGULAR(0.000000000001) HCONVERGE(0, ABSOLUTE) LCONVERGE(0, ABSOLUTE) PCONVERGE(0.000001, ABSOLUTE)    
  /FIXED=age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy day_centered day_centered_sq 
    | SSTYPE(3)
  /METHOD=REML
  /PRINT=SOLUTION
  /RANDOM=INTERCEPT day_centered day_centered_sq | SUBJECT(ID) COVTYPE(UN)
  /SAVE=PRED.

VARSTOCASES
  /MAKE Pain FROM pain_exp pred_slope pred_squared
  /INDEX=Obes_or_pred(Pain) 
  /KEEP=ID age STAI_trait pain_cat cortisol_serum mindfulness sex_dummy Day day_centered 
    day_centered_sq
  /NULL=KEEP.

* Chart Builder.
GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Day MEAN(Pain)[name="MEAN_Pain"] Obs_or_pred 
    MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE.
BEGIN GPL
  SOURCE: s=userSource(id("graphdataset"))
  DATA: Day=col(source(s), name("Day"), unit.category())
  DATA: MEAN_Pain=col(source(s), name("MEAN_Pain"))
  DATA: Obs_or_pred=col(source(s), name("Obs_or_pred"), unit.category())
  GUIDE: axis(dim(1), label("Day"))
  GUIDE: axis(dim(2), label("Mean Pain"))
  GUIDE: legend(aesthetic(aesthetic.color.interior), label("Obs_or_pred"))
  GUIDE: text.title(label("Multiple Line Mean of Pain by Day by Obs_or_pred"))
  SCALE: linear(dim(2), include(0))
  ELEMENT: line(position(Day*MEAN_Pain), color.interior(Obs_or_pred), missing.wings())
END GPL.
