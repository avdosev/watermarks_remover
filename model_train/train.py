import numpy as np
import cv2
import os
import albumentations as A

from tensorflow import keras
import tensorflow as tf
import math
import model as m

def train_pipe(name):
    img = cv2.imread(f'data/train/{name}')
    print(name, img)
    return img

def result_pipe(name):
    img = cv2.imread(f'data/test/{name}')
    return img

class ImagesSequence(keras.utils.Sequence):
    def __init__(self, batch_size):
        self.batch_size = batch_size
        with open('data/names.txt') as f:
            self.images = [line for line in f if len(line) > 0]
        

    def __len__(self):
        return math.ceil(len(self.images) / self.batch_size)

    def __getitem__(self, idx):
        batch_images = self.images[idx * self.batch_size:
                              (idx + 1) * self.batch_size]
        batch_x = np.array([train_pipe(name) for name in batch_images])
        batch_y = np.array([result_pipe(name) for name in batch_images])
        
        return batch_x, batch_y

def main():
    train_dataset = ImagesSequence(10)
    name = 'test_1'
    model_path = f'models/{name}_latest.hdf5'

    model = m.get_model()
    model.summary()
    model.compile(optimizer='adam',
                  loss='mse',
                  metrics=['accuracy', 'mse', 'mae'])

    if os.path.exists(model_path):
        model.load(model_path)

    model.fit(
        train_dataset,
        epochs=10,
        callbacks=[
            keras.callbacks.EarlyStopping(monitor="loss", min_delta=0, patience=4, verbose=0, mode="min"),
            keras.callbacks.ModelCheckpoint(
                filepath=os.path.join(model_path, f'model_best_{name}.hdf5'),
                save_weights_only=False,
                monitor='mse',
                mode='min',
                save_best_only=True
            )
        ]
    )

    model.save(model_path)


if __name__ == '__main__':
    main()