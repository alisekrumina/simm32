﻿* Encoding: UTF-8.

DATASET ACTIVATE DataSet2.
FREQUENCIES VARIABLES=Survived Pclass Sex Age SibSp Parch Ticket Fare Cabin Embarked
  /HISTOGRAM
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=PassengerId Survived Pclass Age SibSp Parch Fare
  /STATISTICS=MEAN STDDEV MIN MAX.

EXAMINE VARIABLES=Survived BY Pclass Name Sex Age SibSp Parch Ticket Fare Cabin Embarked
  /PLOT BOXPLOT STEMLEAF
  /COMPARE GROUPS
  /STATISTICS DESCRIPTIVES
  /CINTERVAL 95
  /MISSING LISTWISE
  /NOTOTAL.

RECODE Sex ('male'=0) ('female'=1) INTO sex_dummy.
EXECUTE.

RECODE Pclass (1=1) (ELSE=0) INTO class_1.
EXECUTE.

RECODE Pclass (2=1) (ELSE=0) INTO class_2.
EXECUTE.

RECODE Pclass (3=1) (ELSE=0) INTO class_3.
EXECUTE.

COMPUTE age_sex=Age * sex_dummy.
EXECUTE.

COMPUTE age_parch=Age * Parch.
EXECUTE.


NOMREG Survived (BASE=FIRST ORDER=ASCENDING) WITH Age sex_dummy Parch SibSp class_2 class_3 age_sex 
    age_parch
  /CRITERIA CIN(95) DELTA(0) MXITER(100) MXSTEP(5) CHKSEP(20) LCONVERGE(0) PCONVERGE(0.000001) 
    SINGULAR(0.00000001)
  /MODEL
  /STEPWISE=PIN(.05) POUT(0.1) MINEFFECT(0) RULE(SINGLE) ENTRYMETHOD(LR) REMOVALMETHOD(LR)
  /INTERCEPT=INCLUDE
  /PRINT=CLASSTABLE PARAMETER SUMMARY LRT CPS STEP MFI IC.
