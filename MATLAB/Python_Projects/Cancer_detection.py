
# Convolution Neural network for Cancer Detection
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import tensorflow as tf
from keras.preprocessing.image import ImageDataGenerator
tf.__version__
from keras.tuners import RandomSearch

## Hyperparamaters
#How many numbers of hidden layers we should have
# Numbers of neurons
# Learning rate

def build_model(hp):
    model =keras.Sequential()
    for i in range (hp.Int('num_layers',2,20)):
        model.add(layers.Dense(units=hp.Int('units_'str(i),
                                            min_value =32,
                                            max_value =512,
                                            step =32),
                                            activation='relu'))
        model.add(layers.Dense(1, activation ='linear'))
        model.compile(
                optimizers =keras.optimizers.Adam(
                        hp.Choice('learning_rate',[1e-2,1e-2,1e-3])),
                        loss ='mean_absolute_error',
                        metrics =['mean_absolute_error'])
        

    return model
tuner =RandomSearch(
    build_model,
    objective ='val_mean_absolute_error',
    max_trials =5,
    execution_per_trial =3,
    directory ='project1',
    project_name ='Ai Quality Index'
)
tuner.search_space_summary()