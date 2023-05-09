# SETUP INSTRUCTIONS - TEST

## Step 1: Clone the MWCOG Gen3_Model GitHub repository
- Open **git bash** in the directory where you want the Gen3 Model
- Type the following in the git bash window (this will clone the repo)
  - **_git clone -b main https://github.com/MWCOG/Gen3_Model.git_**
- Browse to the */Gen3_Model* folder. There are 3 sub-folders in this directory -
  - **documentation** - This folder contains all model documentation (currently empty).
  - **scenario_template** - This is the template scenario folder. This folder can be copied over within the */Gen3_Model* directory to run scenarios. The scenario template folder has an *inputs* folder, an *outputs* folder and the batch scripts to run the model.
  - **source** - This folder contains the scripts and settings files to run various components of the model. The *configs* folder contains the activitysim configuration files. The *scripts* folder contains the batch scripts, cube scripts and python scripts used to run the model. The *software* folder contains the supporting software executables. The *visualizer* folder contains the ABM Visualizer setup.

## Step 2: Install ActivitySim
- Install [Anaconda 64-bit Python 3](https://www.anaconda.com/products/individual)
  - If Anaconda is not installed here -> **_C:\ProgramData\Anaconda3_**, the user needs to update the default Anaconda path on line 61 of the RunABM.bat file located in */source/scripts/batch* directory.
- Create an Anaconda environment (basically a Python install just for this project) using Anaconda Prompt
  - Open Anaconda prompt and navigate to **/source/configs/activitysim** using `CD /d ` DOS command
  - Next, run `conda env create -f environment.yml`. This will create an environment named gen3_model and install all necessary Python packages. To use a different name for the environment, update the *Name* field in the environment.yml file. When using a different environment name, update the path to the default environment on lines 73 and 79 of the */source/scripts/batch/RunABM.bat* file.
  - Run the following command on Anaconda prompt to ensure that the environment was successfully created: `conda activate gen3_model`
  
## Step 3: Download Model Inputs and Dependencies from BOX
- Download [input files from Box](https://app.box.com/s/vfmk9ixst9izcqagd8s86u97b4dxxm0n)
- Unzip ('*extract here*') inside the **inputs** (*/Gen3_Model/scenario_template/inputs*) folder
- Download [software files from Box](https://app.box.com/s/2kcy61gp6wg26dqt5qlwf6c0spsqhxuj)
- Unzip ('*extract here*') inside the **software** (*/source/software*) folder
- Download [visualizer dependencies from Box](https://app.box.com/s/ekbnaqmyep31pqi20uz9q158etfskgp5)
- Unzip ('*extract here*') inside the **dependencies** (*/source/visualizer/dependencies*) folder

## Step 4: Check system configuration and run ActivitySim chunk size training
Before running Gen3 Model, the user must ensure that the system has enough memory (RAM). The Cube processes in the Gen3 Model do not require a lot of memory but ActivitySim has significant memory requirements. For the MWCOG implementation of ActivitySim, 250+ GBs of RAM is recommended for reasonable performance. Insufficient memory may result in memory-related ActivitySim errors. ActivitySim provides *chunk_size* settings to circumvent low memory issues. The user can set the `chunk_size` and `num_processes` in the ActivitySim settings file to fit the problem within the available RAM. Depending on these settings, ActivitySim splits the memory-intensive calculations into batches and then processes the batches in sequence. To achieve the fastest possible runtimes given the hardware, model inputs, and model configuration, ActivitySim must first be trained with the model setup and the machine. ActivitySim can be run in the training mode with the following setting: `chunk_training_mode: training`. In training mode, ActivitySim tracks the memory used by each process and produces a *chunk_cache* file that can be used for production runs. In production mode, ActivitySim is run with the following settings: `chunk_training_mode: production`. The Gen3 Model has been designed to be run in training or production mode. In training mode, Gen3 Model runs only initial skimming (highway and transit) and a 100% run of ActivitySim in training mode. Please note that ActivitySim runtimes in training mode are significantly higher (up to 5 times) than production runs. For a training mode run, set `num_processes` to about 80% of the physical cores and `chunk_size` to about 80% of the available RAM. More information on ActivitySim chunk size configuration can be found on ActivitySim's [wiki](https://activitysim.github.io/activitysim/core.html#chunk-size).

We recommend performing ActivitySim chunk size training before running Gen3 Model on a new machine or if the inputs have changed significantly (e.g., a future year run). To run Gen3 Model in chunk training mode, follow these steps:
- Set `ASIM_CHUNK_TRAINING` on line 33 of */Gen3_Model/scenario_template/run_Model.bat* file to `True`
- Set the `chunk_size` to 80% of available RAM in the */source/configs/activitysim/comfigs_mp/settings_source.yaml* file. The units are in bytes (200 GB is specified as 200_000_000_000)
- Set the `num_processes` to 80% of physical cores on the machine in the */source/configs/activitysim/comfigs_mp/settings_source.yaml* file
- The `households_sample_size` and `chunk_training_mode` are set on the fly by Gen3 Model
- After configuring the above settings, run Gen3 Model by following the instructions in [Step 5](#Step-5-Run-the-model). The *chunk_cache.csv* file is generated in the */Gen3_Model/scenario_template/outputs/activitysim/cache* directory
- After completing the training run, set the `ASIM_CHUNK_TRAINING` on line 33 of */Gen3_Model/scenario_template/run_Model.bat* file to `False` to run Gen3 Model in production mode. The *chunk_cache.csv* file is not overwritten by the production runs.

The Gen3 Model includes a default *chunk_cache.csv* file in the */Gen3_Model/scenario_template/outputs/activitysim/cache* directory. This *chunk_cache* file was generated by training MWCOG ActivitySim on a Windows server with 256 GBs of RAM, 24 physical cores, and an Intel Xeon Gold 6126 CPU @ 2.6 GHz processor. The default *chunk_cache* file can be used on machines with a similar configuration.

The user should also make sure that there is enough disk space on the machine before launching a model run. The final size of the Gen3_Model directory will be 265-275 GBs after a full model run.

## Step 5: Run the model
- Open a DOS window in the */Gen3_Model/scenario_template* folder
- Open and edit the run_ModelSteps.bat file to turn on/off various model components
- Run the run_Model.bat file
