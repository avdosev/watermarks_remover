import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

import numpy as np
import cv2
import os
import albumentations as A

os.environ['TF_FORCE_GPU_ALLOW_GROWTH'] = 'true'

from tensorflow import keras
import tensorflow as tf
import math
import model as m

def train_pipe(name: str):
    img = cv2.imread(f'./data/train/{name}')
    # img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    return img

def result_pipe(name: str):
    img = cv2.imread(f'./data/test/{name}')
    # img = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    return img

class ImagesSequence(keras.utils.Sequence):
    def __init__(self, batch_size):
        self.batch_size = batch_size
        with open('data/names.txt') as f:
            self.images = [line[:-1] for line in f if len(line) > 0]
        

    def __len__(self):
        return math.ceil(len(self.images) / self.batch_size)

    def __getitem__(self, idx):
        batch_images = self.images[idx * self.batch_size:
                              (idx + 1) * self.batch_size]
        batch_x = np.array([train_pipe(name) for name in batch_images])
        batch_y = np.array([result_pipe(name) for name in batch_images])
        
        return batch_x, batch_y

def lr_scheduler(epoch, lr):
    if epoch > 25:
        lr = 0.001
    if epoch > 50:
        lr = 0.0001
    if epoch > 60:
        lr = 0.00001
    if epoch > 70:
        lr = 0.0000001
    return lr

def main():
    train_dataset = ImagesSequence(20)
    name = 'test_bgr'
    model_path = f'models/{name}_latest.hdf5'

    model = m.get_model()

    if os.path.exists(model_path):
        model.load_weights(model_path)

    model.summary()

    optimizer = keras.optimizers.Adam(lr=0.01)


    model.compile(optimizer=optimizer,
                  loss='mse',
                  metrics=['accuracy', 'mse', 'mae'])

    model.fit(
        train_dataset,
        epochs=80,
        initial_epoch=0,
        callbacks=[
            # keras.callbacks.EarlyStopping(monitor="loss", min_delta=0, patience=4, verbose=0, mode="min"),
            keras.callbacks.ModelCheckpoint(
                filepath=f'models/model_best_{name}.hdf5',
                save_weights_only=True,
                monitor='mean_squared_error',
                mode='min',
                save_best_only=True
            ),
            keras.callbacks.LearningRateScheduler(lr_scheduler, verbose=1)
        ]
    )

    model.save(model_path)


if __name__ == '__main__':
    main()