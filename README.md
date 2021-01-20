<p align="center">
    <img src="https://user-images.githubusercontent.com/7321411/105377624-e8c75680-5c02-11eb-9bdf-837bceb041e2.png" width="600px">
</p>

</p>
<h1 align="center">TPB Travel Demand Forecasting Model, Generation 2</h1>

## Table of contents
  * [Disclaimer](#Disclaimer)
  * [Model Versions](#Model-Versions)
    * [Ver. 2.4](#Ver-24)
    * [Ver. 2.3.78](#Ver-2378)
    * [Ver. 2.3.75](#Ver-2375)
  * [How do I run the model?](#How-do-I-run-the-model?)
  * [How can I contribute to the repo?](#How-can-I-contribute-to-the-repo?)

## Disclaimer
> This repository is the code tracking effort by COG staff for their **Gen2** *developmental* work. The model inputs are excluded from the repo. No component should be used for any CLRP or project planning work. 

> To request a copy of the TPB regional travel demand model, model-related data sets, and/or documentation not found on the [MWCOG website](https://www.mwcog.org/transportation/data-and-tools/modeling/), please contact us [here](https://www.mwcog.org/transportation/data-and-tools/modeling/data-requests/).

## Model Versions
The developmental model versions are listed below.

### [Ver. 2.4](https://github.com/MWCOG/Gen2_Model/releases/tag/v.2.4)
The Version 2.4 Travel Model is the latest series of the Version 2.4 family of model versions. This production-use travel model in 2021 was built based on Ver. 2.3.78. 

This version comprises of five major enhanced features:

    1. Revised treatment of external travel distribution within the modeled study area
    2. Re-calibrated the nested-logit mode choice (NLMC) model to year-2007, following recent updates to person trip calibration targets for commuter rail
    3. Restored number of iterations in External Trip Distribution of: HBS and HBO
    4. Created additional node ranges for each jurisdiction in the modeled area
    5. Adjusted volume-to-capacity (V/C) ratio toll-search stopping criteria
    
All the updates, with the exception of update #4, cause some changes in the model results.

### [Ver. 2.3.78](https://github.com/MWCOG/Gen2_Model/releases/tag/v2.3.78) 
This production-use travel model in 2020 was built based on Ver. 2.3.75 with three minor updates. 

    1. Updated the ArcPy process to be compatible with ArcGIS Engine 10.6 in Cube 6.4.5 (beta)    
    2. Fixed the potential use of Iter_HWY.net incorrectly
    3. Corrected misleading names of sub-nodes processes by adding two sub-nodes of PM and NT

None of the updates made any impacts to the model results.

### [Ver. 2.3.75](https://github.com/MWCOG/Gen2_Model/releases/tag/v2.3.75)
This version was built based on Ver. 2.3.70 with five updates:

    1. Removed the highway skim replacement (HSR) procedure from the model
    2. Added a check for the existence of the constraining trip files for the model years after 2020 
    3. Added a check to report the active transit stations with “zero” skim values 
    4. Updated unbuild_net.s with the latest version 
    5. Revised run_ModelSteps_[year].bat file to be consistent for all modeled years. 

## How do I run the model?

   1. Install Bentley Systems Cube Base and Cube Voyager software (preferred Cube 6.4.1) on a 64-bit Windows computer.
   2. Add the following two paths to your Windows PATH environment variable:
        `C:\cygwin\bin`
        `C:\Program Files (x86)\Citilabs\CubeVoyager`
   3. Make sure that the input files of the scenario to run are set up. Launch the run_Model_[year].bat

## How can I contribute to the repo?
   1. Fork the repository
   2. Clone the forked repository to your machine
   3. Create a branch
   4. Make necessary changes and commit those changes
   5. Push changes to GitHub
   6. Submit your changes by pulling a request for review

[⬆️ UP](#Table-of-contents)
