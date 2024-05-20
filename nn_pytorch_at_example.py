# -*- coding: UTF-8 -*-
"""
Created on 2024-04-14

:author: Robert-Vincent Lichterfeld
:github: https://github.com/RobertLicht

Tutorial from Adrian Tam PhD explaining how to develop a first (Artificial) Neural Network with PyTorch, Step by Step
Source: https://machinelearningmastery.com/develop-your-first-neural-network-with-pytorch-step-by-step/

Usage
* Windows PowerShell: & %PUBLIC%/NN_PyTorch_AT_Example/venv_nn_pytorch/Scripts/python.exe %PUBLIC%/NN_PyTorch_AT_Example/nn_pytorch_at_example.py
* Command Prompt Shell: START CMD /C CD %PUBLIC%\\NN_PyTorch_AT_Example ^& \\venv_nn_pytorch\\Scripts\\activate ^& title=NeuronalNetwork_PyTorch_AT_Example ^& ECHO [i] INITIALIZING - This may take some time... ^& python nn_pytorch_at_example.py
* Command Prompt Shell launching a PowerShell: START POWERSHELL -executionpolicy bypass -noexit -command "[console]::Title='NeuronalNetwork_PyTorch_AT_Example'; [console]::WindowWidth=140; [console]::WindowHeight=40; [console]::BufferWidth=[console]::WindowWidth"; CD %PUBLIC%/NN_PyTorch_AT_Example; ./venv_nn_pytorch/Scripts/activate.ps1; Write-Host "`r`n[i] INITIALIZING - This may take some time..."; python nn_pytorch_at_example.py

"""

# =========================================================================
#   Import of modules
# =========================================================================
import datetime
import logging
import numpy as np
import os
import pathlib
import sys
import torch
import torch.nn as nn
import torch.optim as optim

from time import sleep, gmtime, localtime
from typing import List

# ---- IMPORT OWN MODULES ----
from human_bytes import HumanBytes

#--------------------------------------------------------------------------
#   Specific Configuration
#--------------------------------------------------------------------------

# =========================================================================
#   Global variables or constants
# =========================================================================
# __version__ = f'{datetime.datetime.now().timetuple().tm_year}a{datetime.datetime.now().timetuple().tm_yday}'
# print(f'{datetime.datetime.now(tz=datetime.timezone.utc).timetuple().tm_year}a{datetime.datetime.now().timetuple().tm_yday}')
__version__ = "2024a140"
__author__ = "Lichterfeld Robert-Vincent"
# Get file name of python modul
str_py_filename = str(os.path.basename(__file__).replace('.py', ''))
# Set name of Application
str_app_name = "NeuronalNetwork_PyTorch_AT_Example"
# Set name of directory for log files
str_log_outputdir = "Logs_NN_PyTorch_AT_Example"
# Set base path for logging
str_base_path_logging_dir = os.path.join(os.path.dirname(__file__), str_log_outputdir)


# .........................................................................
#    Configuration - logging
# .........................................................................
# Create directory for log files
os.makedirs(str_base_path_logging_dir, exist_ok=True)

# Create timestamp
str_timestamp = f"{datetime.datetime.now().timetuple().tm_year}-{datetime.datetime.now().timetuple().tm_mon}-" \
    f"{datetime.datetime.now().timetuple().tm_mday}_-_" \
    f"{datetime.datetime.now().timetuple().tm_hour}_{datetime.datetime.now().timetuple().tm_min}_" \
    f"{datetime.datetime.now().timetuple().tm_sec}"

# Create filename for log
str_file_save_log = os.path.join(str_base_path_logging_dir, f'{str_app_name}_{str_timestamp}.log')

# .... Setup and configure logging handler ....
handlers: List[logging.Handler] = []

# ... Create a file handler for logging ...
obj_file_handler = logging.FileHandler(filename=str_file_save_log)

# .. Append configured file handler to list of handlers ..
handlers.append(obj_file_handler)

# .. Configure logging ...
logging.basicConfig(
    level=logging.DEBUG,
    # evel=logging.INFO,
    # level=logging.WARNING,
    style="{",
    format='{asctime} [{levelname}]  "{name}" | {message}',
    datefmt='%Y-%m-%d %H:%M:%S',
    encoding='utf-8',
    handlers=handlers,
    )

# .. Define logger for this module ..
# Source: https://stackoverflow.com/a/15729700
logger = logging.getLogger(__name__)

# .. Log message with information ..
# logging.Formatter.converter = gmtime
# logger.info(f"---- Logging is using united coordinated time (utc) ----")
logging.Formatter.converter = localtime
logger.info(f"---- Logging is using localtime time ----")

# -------------------------------------------------------------------------
#   Functions
# -------------------------------------------------------------------------
def func_get_size_of_dir_or_file(
    str_item: str | None = None,
    str_unit: str | None = 'bytes'
    ) -> int:
    """Determines the size of a directory or a file
    
    Parameters
    ----------
    str_item (None) : String
        Path to the directory or file. Defaults to None.
    str_unit (bytes): Sting
        Unit in which the size of the file is shown (bytes, kB, MB, GB, TB, PB). Defaults to 'bytes'.

    Returns
    -------
    int_item_size (None) : Integer
        Number showing the size of the directory or file
        
    Raises
    ------
    ValueError: Must select from ['bytes', 'kB', 'MB', 'GB', 'TB', 'PB']
    """
    # .... Get size of directory or file ....
    if os.path.isdir(str_item):
        # ... Get size of directory (recursive) ...
        try:
            # Initialize variable
            int_dir_size = 0
            # Walk into directory and add up sizes of items
            #   Source: https://stackoverflow.com/a/1392549
            # # for dirpath, dirnames, filenames in os.walk(str_item):
            # #     for f in filenames:
            # #         fp = os.path.join(dirpath, f)
            # #         # skip if it is symbolic link
            # #         if not os.path.islink(fp):
            # #             int_dir_size += os.path.getsize(fp)
            root_directory = pathlib.Path(str_item)
            int_dir_size = sum(f.stat().st_size for f in root_directory.glob('**/*') if f.is_file())
        except OSError as ose:
            str_text_error = f"Error code: {ose.code}\nFailed with: {ose.strerror}"
            logger.error(str_text_error)
            # print(str_text_error)
            return str_text_error
        # .. Convert bytes to selectet unit ..
        exponents_map = {'bytes': 0, 'KiB': 1, 'MiB': 2, 'GiB': 3, 'TiB': 4, 'PiB': 5}
        if str_unit not in exponents_map:
            raise ValueError("Must select from ['bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB']")
        else:
            int_item_size = int_dir_size / 1024 ** exponents_map[str_unit]
            return round(size, 3)
    else:
        file_size = os.path.getsize(str_item)
        exponents_map = {'bytes': 0, 'KiB': 1, 'MiB': 2, 'GiB': 3, 'TiB': 4, 'PiB': 5}
        if str_unit not in exponents_map:
            raise ValueError("Must select from \
            ['bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB']")
        else:
            size = file_size / 1024 ** exponents_map[str_unit]
            return round(size, 3)
        
# .... Get number of parameters of the model ....
# Source: https://discuss.pytorch.org/t/how-do-i-check-the-number-of-parameters-of-a-model/4325
def count_parameters(model): return sum(p.numel() for p in model.parameters() if p.requires_grad)


# =========================================================================
#   Execution logic
# =========================================================================
def func_execute_all():
    # ...................................
    #   Check if a GPU can be utilized
    # ...................................
    # torch.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    #   Source: https://stackabuse.com/how-to-use-gpus-with-pytorch/
    # * Possible devices: cpu, cuda, ipu, xpu, mkldnn, opengl, opencl, ideep, hip, ve, fpga, ort, xla, lazy, vulkan, mps, meta, hpu, mtia
    if torch.cuda.is_available():
        # Setting the default device using torch version >= 2.3 
        #   Source: https://stackoverflow.com/a/76390984
        if str(torch.version.__version__).split(sep="+")[0] >= "2.3":
            torch.set_default_device(device="cuda")
            str_msg = f"""
                At least one GPU can be utilized
                Number of GPUs: {torch.cuda.device_count()}
                Device in use: {torch.cuda.current_device()}
                Initialized device: {torch.get_default_device()}
            """
        else:
            torch.device(device="cuda")
            str_msg = f"""
                At least one GPU can be utilized
                Number of GPUs: {torch.cuda.device_count()}
                Device in use: {torch.cuda.current_device()}
                Initialized device: {torch.device.type}
            """
    else:
        # Setting the default device using torch version >= 2.3 
        #   Source: https://stackoverflow.com/a/76390984
        if str(torch.version.__version__).split(sep="+")[0] >= "2.3":
            torch.set_default_device(device="cpu")
            str_msg = f"No GPU can be utilized. Initialized device: {torch.get_default_device()}"
        else:
            torch.device(device="cpu")
            str_msg = f"No GPU can be utilized. Initialized device: {torch.device.type}"

    logger.info(str_msg)
    print(str_msg)
    str_msg = None

    # ......................................
    #   Loading and preparing the data set  
    # ......................................
    # .... Load the dataset, split into input (X) and output (y) variables ....
    str_input_file = os.path.join(os.path.dirname(__file__), "pima-indians-diabetes-data.csv")
    nbr_size_bytes = func_get_size_of_dir_or_file(str_item=str_input_file, str_unit="bytes")
    str_size = HumanBytes.format(num=nbr_size_bytes, metric=False, precision=2)
    str_msg = f"Loading data set: {str_input_file} with the size of {str_size}"
    logger.info(str_msg)
    print(str_msg)
    str_msg = None
    #   The NumPy function loadtxt is used to load the file as a matrix wiht 8 input variables and one output variable
    #   * Input variables (X)
    #       1. Number of times pregnant
    #       2. Plasma glucose concentration at 2 hours in an oral glucose tolerance test
    #       3. Diastolic blood pressure (mm Hg)
    #       4. Triceps skin fold thikness (mm)
    #       5. 2-hour serum insulin (µlU/ml)
    #       6. Body mass index (weight in kg/(height in m)^2)
    #       7. Diabetes pedigree function
    #       8. Age (years)
    #   * Output Variables (y)
    #       Class label (0 or 1)
    #   By utilizing the slice operator of NumPy the input variables will be stored in a 2D array (rows, columns) as subset of the orignal array
    dataset = np.loadtxt(fname=str_input_file, delimiter=",")
    X = dataset[:,0:8]
    y = dataset[:,8]

    # ... Convert data to PyTorch tensors ...
    #   Numpy uses by default 64-bit floating point but PyTorch usually operates with 32-bit floating point
    #   The shape preferred or expected by PyTorch is a n x 1 matrix over n vectors
    X = torch.tensor(X, dtype=torch.float32)
    y = torch.tensor(y, dtype=torch.float32).reshape(-1, 1)

    # .......................
    #   Defining the Model  
    # .......................
    # .... Creating a sequential model ....
    #   The modell will take eight input features and utilize a fully-connected network structure (Linear class in PyTorch) with three layers
    #   * Rows of data with 8 variables are expected by the model (first argument at the first layer)
    #   * The number of outputs or neurons is set to 12 in the first hidden layer, which is followed by a ReLU activation function
    #   * The number of outputs or neurons is set to 8 in the second hidden layer, which is followed by a ReLU activation function
    #   * For the output layer 1 output or neuron is used, which is followed by a sigmoid activation function
    #   ** The sigmoid activation function ensurse that the output is between 0 and 1
    model = nn.Sequential(
        nn.Linear(8, 12),
        nn.ReLU(),
        nn.Linear(12, 8),
        nn.ReLU(),
        nn.Linear(8, 1),
        nn.Sigmoid()
    )

    # Information about the created model
    str_msg = "\n----\nSequential model utilizing a fully-connected network structure with "\
        f"three layers:\n {model}\n\nThis model has {count_parameters(model)} parameters\n\n"
    logger.info(str_msg)
    print(str_msg)
    str_msg = None

    # .... Create a Python class of the model, which is inherited from the nn.Module ....
    class PimaClassifier(nn.Module):
        """
        All layers of the model need to be defined
        in the constructor to prepare the all its componets
        without input
        """
        def __init__(self):
            """
            The constructor of the parents class is 
            bootstraped to to the model using the line
            super().__init__()
            """
            super().__init__()
            self.hidden1 = nn.Linear(8, 12)
            self.act1 = nn.ReLU()
            self.hidden2 = nn.Linear(12, 8)
            self.act2 = nn.ReLU()
            self.output = nn.Linear(8, 1)
            self.act_output = nn.Sigmoid()

        def forward(self, x):
            """
            This function tells the class, if an input tensor x is
            provided and how to produce the output tensor in return
            """
            x = self.act1(self.hidden1(x))
            x = self.act2(self.hidden2(x))
            x = self.act_output(self.output(x))
            return x
        
    # Information about the Python class of the model
    cls_model = PimaClassifier()
    str_msg = "\n----\nSequential Python class model utilizing a fully-connected network structure with "\
        f"three layers:\n {cls_model}\n\nThis model has {count_parameters(cls_model)} parameters\n\n"
    logger.info(str_msg)
    print(str_msg)
    str_msg = None

    # ..............................
    #   Preperation for Training    
    # ..............................
    # .... Select and configure a loss function as well as an optimizer ....
    # In this case of a binary classification problem a binary cross entropy loss function is used
    loss_fn = nn.BCELoss()

    # The use of a loss function requires an optimizer, in this case Adam is used
    optimizer = optim.Adam(params=cls_model.parameters(), lr=0.003)

    # ..............................
    #   Training a Model    
    # ..............................
    # Training a neural network model usually takes in epochs and batches. They are idioms for how data
    # is passed to a model:
    # * Epoch: Passes the entire training dataset to the model once
    # * Batch: One or more samples passed to the model, from which the gradient descent algorithm will be executed for one iteration
    #   * The size of the batch is limited by the available memory of the system
    # .... Creating a simple structure for training out of two for-loops ....
    n_epochs = 200
    batch_size = 16
    threshold_loss = 0.333
    loss = threshold_loss + 1
    str_msg = f"""
        The Gradient descent will be run to update the network parameters for a maximum
        of {n_epochs} epochs, or less if the loss is smaller or equal to {threshold_loss}.
    """
    logger.info(str_msg)
    print(str_msg)
    str_msg = None

    for epoch in range(n_epochs):
        for i in range(0, len(X), batch_size):
            X_batch = X[i:i+batch_size]
            y_pred = cls_model(X_batch)
            y_batch = y[i:i+batch_size]
            loss = loss_fn(y_pred, y_batch)
            optimizer.zero_grad(set_to_none=True)
            loss.backward()
            optimizer.step()
        str_msg = f"Finished epoch {epoch}, latest loss {loss:.6f}"
        logger.debug(str_msg)
        print(str_msg)
        if loss <= threshold_loss:
            break
    epoch = None
    i = None
    str_msg = None

    # ..............................
    #   Evaluate the Model    
    # ..............................
    # The performance of the network is evaluated on the same dataset to reduce the complexity in this example.
    # To get insights on how well the network will perform on new data, a separate dataset would be necessary.
    #   The evaluation of the model is using the same way as the call up used for training.
    #   Predictions for each input are computed and a score is shaped by converting the output (floating point) into an integer
    #   * The output (floating point) is rounded to the nearest integer by the function 'round()'
    #   * A Boolean tensor is compared and returned by the '==' operator
    #       * The retruned tensor is converted into floating point numbers utilizing 'float()'
    #       * The count of numbers of 1's is made available by 'mean()'
    #   * The usage of the context manager utilizing 'no_grad()' is optional, but suggested
    # .... Evaluation of compute accuracy of the model using the training dataset ...
    with torch.no_grad():
        y_pred = cls_model(X)
    accuracy = (y_pred.round() == y).float().mean()
    str_msg = f"\nAccuracy of the model, using the training dataset for evaluation: {(accuracy * 100):.1f}%"
    logger.info(str_msg)
    print(str_msg)
    str_msg = None

    # ..............................
    #   Make Predictions
    # ..............................
    # In this example it is peretended that the existing dataset is a new one and the model is called like
    # it is a function, to make predicions on the 'new' dataset.
    # Due to the use of a sigmoid activation function in the output layer the predictions will be
    # in a range between 0 and 1
    # .... Make probability predictions with the model ....
    predictions = cls_model(X)
    pred_rnded = predictions.round()
    # .... ALTERNATIVE - Make class predictions with the model ....
    pred_cls = (cls_model(X) > 0.5).int()
    # ... Showing size of tensors ...
    str_msg = f"\nShape of tensor 'predictions rounded': {pred_rnded.shape[0]} rows (m), {pred_rnded.shape[1]} columns (n)"\
        f"\nShape of tensor 'class predictions': {pred_cls.shape[0]} rows (m), {pred_cls.shape[1]} columns (n)"\
        f"\nShape of tensor 'output variables': {pred_cls.shape[0]} rows (m), {pred_cls.shape[1]} columns (n)"
    logger.debug(str_msg)
    str_msg = None
    # ... Showing values for the first five examples ...
    for i in range(10):
        str_msg = f"\nExample {i}\nPredictions\n{X[i].tolist()} => {(predictions[i].item() * 100):.1f}% | expected: {int(y[i].item()) * 100}%"\
            f"\nPredictions rounded\n{X[i].tolist()} => {pred_rnded[i].item()} | expected: {y[i].item()}"\
            f"\nClass predictions\n{X[i].tolist()} => {pred_cls[i].item()} | expected: {int(y[i].item())}\n"
        logger.info(str_msg)
        print(str_msg)
    str_msg = None


# =========================================================================
#   MAIN
# =========================================================================
def main():
    # .... Launch nvitop ....
    # React on operating system for action
    # Source 1: https://stackabuse.com/how-to-copy-a-file-in-python/
    # Source 2: https://stackoverflow.com/questions/8220108/how-do-i-check-the-operating-system-in-python
    if sys.platform == "win32":
        # Windows
        str_command_nvitop = "START CMD /C title=nvitop ^& mode con: cols=205 lines=65 ^& .\\venv_nn_pytorch\\Scripts\\activate.bat ^& python -m nvitop -m auto --ascii"
    elif sys.platform == "linux" or sys.platform == "linux2":
        # Linux
        str_command_nvitop = "START CMD /C title=nvitop ^& mode con: cols=205 lines=65 ^& .\\venv_nn_pytorch\\Scripts\\activate ^& python -m nvitop -m auto"
    elif sys.platform == "darwin":
        # OS X
        str_command_nvitop = "START CMD /C title=nvitop ^& mode con: cols=205 lines=65 ^& .\\venv_nn_pytorch\\Scripts\\activate ^& python -m nvitop -m auto"
    else:
        str_text_error = f"Unknown operating system '{sys.platform}'"
        logger.error(str_text_error)
        print(str_text_error)
        return str_text_error

    # .... Execute command using nvitop ....
    try:
        int_ret_code = os.system(str_command_nvitop)
    except Exception as excep:
        logging.error(excep)
        print(excep)
    if int_ret_code == 0:
        str_text_info = "Launched nvitop successfully"
        logger.info(str_text_info)
    else:
        str_text_error = f"Error return code: {int_ret_code}\nError launching nvitop using the following command:\n\t{str_command_nvitop}"
        logger.error(str_text_error)
        print(str_text_error)
    sleep(2)

    # .... Execute all of the execution logic ....
    func_execute_all()


if __name__ == '__main__':
    main()