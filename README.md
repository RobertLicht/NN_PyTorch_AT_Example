# Demo of a first deep learning neuronal network model in Python
This demonstration is based on the great [tutorial](https://machinelearningmastery.com/develop-your-first-neural-network-with-pytorch-step-by-step/) from Adrian Tam PhD, in which he explains Step by Step how to develop an (Artificial) Neural Network with PyTorch. 🤖🧠🇦🇮👾

## Quick links
* [Overview](#overview)
* [Requirements](#requirements)
* [Setup and Installation](#setup-and-installation)
* [Usage](#usage)

## Overview
This demonstration is primarily focused on the usage of a machine that is using Windows as an OS.

To ease the entry and reduce difficulties with basics like the setup of a virtual environment for Python, this demonstration provides helpful batch files. Those batch files support the initial setup, the installation of packages, and the launch of the main process.

The main process consists of the following steps, which are provided by the [tutorial](https://machinelearningmastery.com/develop-your-first-neural-network-with-pytorch-step-by-step/):
* Load the Dataset
* Define the PyTorch Model
* Define a Loss Function and Optimizers
* Run a Training Loop
* Evaluate the Model
* Make Predictions

## Requirements
* An installation of Windows OS
    * Windows 10 or greater
* An installation of Python
    * [Python 3.10](https://www.python.org/downloads/release/python-3100/) or greater
* An optional installation of Git
    * [Git](https://git-scm.com/downloads)
* Minimum available Disk space of 2 GB
    * Recommended available Disk space of 6 GB

## Setup and Installation
The initial setup, the installation of packages is heavily supported by the batch file _setup_install_pytorch_at_example_on_windows.bat_.
To get this batch file and all other necessary data, the repository can be cloned by using Git or downloaded to the local machine of the user.

### Get the fles and data
This guide will show two ways, which can be used to retrieve the necessary data from GitHub.

#### Clone the repository
The utilization of Git is the most comfortable way to transfer the data of the repository to the recommended default location.
* On a system using Windows, the following expression can be used to clone the repository
    * Command Line Shell (CMD)
        ```
        git clone https://github.com/RobertLicht/NN_PyTorch_AT_Example.git %PUBLIC%\NN_PyTorch_AT_Example
        ```
    * Git Bash Shell
        ```
        git clone https://github.com/RobertLicht/NN_PyTorch_AT_Example.git /c/Users/Public/NN_PyTorch_AT_Example
        ```

#### Download the repository
As an alternative to Git, the data of the repository can be downloaded as an archive (ZIP) to the local machine of the user.
* Use the URL to [download the repository](https://github.com/RobertLicht/NN_PyTorch_AT_Example/archive/refs/heads/main.zip):
    * https://github.com/RobertLicht/NN_PyTorch_AT_Example/archive/refs/heads/main.zip
* Extract the downloaded archive into the recommended default location:
    * Windows
        > %PUBLIC%\NN_PyTorch_AT_Example\
    * Linux
        > /c/Users/Public/NN_PyTorch_AT_Example/

#### Use only the setup file
It is possible to use only the batch file _setup_install_pytorch_at_example_on_windows.bat_ to get all files from the repository and install the necessary packages.
* Navigate to the file inside the Repository _NN_PyTorch_AT_Example_
    * Use the URL to [get to the file _setup_install_pytorch_at_example_on_windows.bat_](https://github.com/RobertLicht/NN_PyTorch_AT_Example/blob/main/setup_install_pytorch_at_example_on_windows.bat)
        *  https://github.com/RobertLicht/NN_PyTorch_AT_Example/blob/main/setup_install_pytorch_at_example_on_windows.bat
* Use the button with three dots ・・・ (_more file actions_) or use the keyboard shortcut **_ctrl_** + **_shift_** + **_s_** to download the raw content
* Save or move the downloaded batch file to the recommended default location:
    * Windows
        > %PUBLIC%\NN_PyTorch_AT_Example\
    * Linux
        > /c/Users/Public/NN_PyTorch_AT_Example/

### Launch the setup process
After the initial data is gathered and stored at the local machine the process to set up everything else can be launched.
* Navigate to the file **_setup_install_pytorch_at_example_on_windows.bat_** and execute the batch script with a double-click
    * The batch script will handle all requirements that are necessary to set up the demo
    * During the setup, the user will be prompted to decide how to proceed
        * In most cases pressing **ENTER** or entering **n** will be suitable to follow the default configuration

## Usage
After the setup has been completed successfully, the Demonstrator is ready for usage.

### Start the Demo
The startup is handled by the batch file _start_nn_pytorch_at_example.bat_, which should be available at the recommended default location.
* Navigate to the file **_start_nn_pytorch_at_example.bat_** and execute the batch script with a double-click
* During the startup, an additional Command Line Shell running [_nvitop_](https://github.com/XuehaiPan/nvitop/tree/main) will be launched
    * The tool _nvitop_ provides some insights, considering the usage of system resources
* After initializing of libraries and _nvitop_ a Windows PowerShell instance will be launched
