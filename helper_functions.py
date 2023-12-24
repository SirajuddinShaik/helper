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


def kaggleCsv1(preds, columns, id_start=1, onehoted=False):
    if onehoted:
        preds = np.argmax(preds, axis=1)
    id = [i + id_start for i in range(len(preds))]
    d = {}
    d["id"] = id
    for i in range(len(columns)):
        d[columns[i]] = preds[columns[i]]
    submission_df = pd.DataFrame(d)
    submission_df.to_csv("submission.csv", index=False)


def kaggleCsv(preds, columns, id_start=1, onehoted=False):
    id = [i + id_start for i in range(len(preds))]
    if onehoted:
        preds = np.argmax(preds, axis=1)
    d = {"id": id}
    for i in range(preds.shape[1]):
        col_name = columns[i]
        d[col_name] = preds[:, i]

    submission_df = pd.DataFrame(d)
    submission_df.to_csv("submission1.csv", index=False)


import matplotlib.pyplot as plt


def plot_loss_curve(history):
    """
    Plots the training and validation loss curves from the given training history.

    Parameters:
    - history: A dictionary containing training history, typically obtained from model.fit().
    """
    plt.plot(history["loss"], label="Training Loss")
    plt.plot(history["val_loss"], label="Validation Loss")
    plt.title("Training and Validation Loss")
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.legend()
    plt.show()


def callbacksV1(
    name,
    patience=3,
    filepath="/model",
    monitor="loss",
    save_best_only=True,
    save_weights_only=True,
    min_lr=0.00001,
    factor=0.2,
):
    if name == "earlystop":
        # losses = ["val_loss", "val_accuracy", "val_mse", "val_mae"]
        return tf.keras.callbacks.EarlyStopping(
            monitor=monitor,  # Metric to monitor for improvement
            min_delta=0.001,  # Minimum change in monitored metric to qualify as improvement
            patience=patience,  # Number of epochs to wait for improvement before stopping
            verbose=1,  # Verbosity mode (0 = silent, 1 = progress bar, 2 = one line per epoch)
            mode="auto",  # Whether to monitor for min ('min'), max ('max'), or no specific direction ('auto')
            baseline=None,  # Baseline value for the monitored metric to compare against
            restore_best_weights=True,  # Whether to restore model weights from the epoch with the best monitored metric
        )
    elif name == "modelckpt":
        return tf.keras.callbacks.ModelCheckpoint(
            filepath=filepath,  # model_weights.h5
            monitor=monitor,  # Metric to monitor for improvement
            verbose=1,
            save_best_only=save_best_only,  # Save only the model with the best monitored metric
            save_weights_only=save_weights_only,  # Save only model weights, not entire model architecture
            mode="min",  # Monitor for minimum monitored metric
        )
    elif name == "autoreducer":
        return tf.keras.callbacks.ReduceLROnPlateau(
            monitor=monitor,  # Metric to monitor for plateau
            factor=factor,  # Factor by which to reduce the learning rate
            patience=patience,  # Number of epochs to wait before reducing the learning rate
            min_lr=min_lr,  # Minimum learning rate to reach
            verbose=1,  # Verbosity mode
        )
    elif name == "lrshedule":

        def lr_schedule(epoch):
            # Example schedule: decrease learning rate by a factor of 10 every 20 epochs
            lr = factor * (0.1 ** (epoch // width))
            return lr

        return tf.keras.callbacks.LearningRateScheduler(lr_schedule)

    else:
        print("---plrrr")
    return None


def useTpu():
    # Connect to the TPU
    try:
        tpu = tf.distribute.cluster_resolver.TPUClusterResolver()  # TPU detection
        print("Running on TPU ", tpu.master())
    except ValueError:
        tpu = None

    if tpu:
        tf.config.experimental_connect_to_cluster(tpu)
        tf.tpu.experimental.initialize_tpu_system(tpu)
        strategy = tf.distribute.TPUStrategy(tpu)
    else:
        # Default strategy for CPU and single GPU
        strategy = tf.distribute.get_strategy()

    print("Number of devices: {}".format(strategy.num_replicas_in_sync))
    return strategy


import pandas as pd
import numpy as np


def one_hot_or_not(
    df, label=None, label_one_hot=False, removed_cols=["id"], max_hot=10
):
    one = {}
    normal = []

    for col in df.columns:
        if col not in removed_cols:
            v = pd.get_dummies(df[col]).values

            if len(v[0]) <= max_hot:
                one[col] = v
                print(f"{col} : {len(v[0])} unique values")
            elif df[col].apply(lambda x: type(x) == str).any():
                print(f"{col} : {len(v[0])} unique values")
            else:
                normal.append(col)
                print(f"{col} : {len(v[0])}")

    x_one_hot = np.hstack(list(one.values())).astype("float32")
    x = np.hstack((x_one_hot, df[normal].values))

    if label and label in df.columns:
        if label_one_hot:
            y = pd.get_dummies(df[label]).values
        else:
            y = df[label].values.astype("float32")
        return x, y
    elif label:
        print(f"Label column '{label}' not found in DataFrame.")
    return x
