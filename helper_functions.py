# https://raw.githubusercontent.com/SirajuddinShaik/helper/main/helper_functions.py

import zipfile
import tensorflow as tf
import pandas as pd
import numpy as np


def unzip_data(filename):
    """
    Unzips filename into the current working directory.

    Args:
      filename (str): a filepath to a target zip folder to be unzipped.
    """
    zip_ref = zipfile.ZipFile(filename, "r")
    zip_ref.extractall()
    zip_ref.close()


def earlyStop(pat, loss_num=0):
    losses = ["val_loss", "val_accuracy", "val_mse", "val_mae"]
    return tf.keras.callbacks.EarlyStopping(
        monitor=losses[
            loss_num
        ],  # Metric to monitor for early stopping (e.g., 'val_loss', 'val_accuracy')
        patience=pat,  # Number of epochs with no improvement after which training will be stopped
        restore_best_weights=True,  # Restores model weights from the epoch with the best monitored value
    )


def kaggleCsv(preds,columns,id_start=1):
    if onehoted:
        preds = np.argmax(preds, axis=1)
    id=[i+id_start for i in range(len(preds))]
    d={}
    d["id"]=id
    for i in range(len(columns):
        d[columns[i]]=preds[columns[i]]
    submission_df = pd.DataFrame(d)
    submission_df.to_csv("submission.csv", index=False)
