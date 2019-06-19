# TPB_TDFM_Gen2
## TPB Travel Demand Model Forecasting Model, Generation 2.3
### NOTE: This repository is the tracking effort by COG staff for their developmental work. No component should be used for any CLRP or project planning work. Should you have any questions, please contact us [here](https://www.mwcog.org/transportation/data-and-tools/modeling/data-requests/).

## Model Versions:
The developmental model versions are listed below

### Ver. 2.3.78 
This version was built based on Ver. 2.3.75. The model comprises of three updates

    1. Updated the ArcPy process to be compatible with ArcGIS Engine 10.6 in Cube 6.4.5 (beta)
       - Files changes:
         - ArcPy_Walkshed_Process.bat
         - Scripts/MWCOG_ArcPY_Walkshed_Process.py
       - Mode output change: No
    
    2. Fixed the potential use of Iter_HWY.net incorrectly
       - Files changes:
         - Average_Link_Speeds.bat
         - Highway_Skims.bat
         - Scripts/Average_Link_Speeds.s
         - Scripts/Highway_Assignment_Parallel.s
         - Model output change: No
    
    3. Corrected misleading names of sub-nodes processes by adding two sub-nodes of PM and NT
      - Files changes:
        - Highway_Assignment_Parallel.bat
        - Highway_Assginment_Paralle.s
      - Model output change: No

### Ver. 2.3.75
This version was built based on Ver. 2.3.70
