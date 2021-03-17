import warnings
warnings.simplefilter(action='ignore', category=FutureWarning)

from tensorflow import keras
import config

def decoder(filters, kernel):
    return keras.Sequential([
        keras.layers.Conv2D(filters, kernel_size=kernel, strides=1, padding='same'),
        keras.layers.MaxPooling2D(pool_size=2),
        keras.layers.BatchNormalization(),
        keras.layers.LeakyReLU(),

        keras.layers.Conv2D(filters, kernel_size=kernel, strides=1, padding='same'),
        keras.layers.BatchNormalization(),
        keras.layers.LeakyReLU(),
    ])

def encoder(filters, kernel):
    return keras.Sequential([
        keras.layers.BatchNormalization(),
        
        keras.layers.Conv2D(filters, kernel_size=kernel, strides=1, padding='same'),
        keras.layers.BatchNormalization(),
        keras.layers.LeakyReLU(),
        
        keras.layers.Conv2D(filters, kernel_size=1, strides=1),
        keras.layers.BatchNormalization(),
        keras.layers.LeakyReLU(),

        keras.layers.UpSampling2D(size=2, interpolation='nearest'),
    ])

def skip(filters, kernel):
    return keras.Sequential([
        keras.layers.Conv2D(filters, kernel_size=kernel, strides=1, padding='same'),
        keras.layers.BatchNormalization(),
        keras.layers.LeakyReLU(),
    ])

def get_model(): 
    nd = [16, 32, 64, 128, 256, 256]
    nu = nd
    ku = kd = [3, 3, 3, 3, 3, 3]

    ns = [4, 4, 4, 4, 4]
    ks = [1, 1, 1, 1, 1, 1]

    d0 = decoder(nd[0], kd[0])
    d1 = decoder(nd[1], kd[1])
    d2 = decoder(nd[2], kd[2])
    d3 = decoder(nd[3], kd[3])
    d4 = decoder(nd[4], kd[4])
    d5 = decoder(nd[5], kd[5])
    
    e0 = encoder(nu[0], ku[0])
    e1 = encoder(nu[1], ku[1])
    e2 = encoder(nu[2], ku[2])
    e3 = encoder(nu[3], ku[3])
    e4 = encoder(nu[4], ku[4])
    e5 = encoder(nu[5], ku[5])

    s0 = skip(ns[0], ks[0])
    s1 = skip(ns[1], ks[1])
    s2 = skip(ns[2], ks[2])
    s3 = skip(ns[3], ks[3])
    s4 = skip(ns[4], ks[4])

    input = keras.Input(shape=config.size)
    d0_output = d0(input)
    d1_output = d1(d0_output)
    d2_output = d2(d1_output)
    d3_output = d3(d2_output)
    d4_output = d4(d3_output)
    d5_output = d5(d4_output)

    e5_output = e5(d5_output)
    e5_d4_concat = keras.layers.concatenate([e5_output, s4(d4_output)])
    
    e4_output = e4(e5_d4_concat)
    e4_d3_concat = keras.layers.concatenate([e4_output, s3(d3_output)])

    e3_output = e3(e4_d3_concat)
    e3_d2_concat = keras.layers.concatenate([e3_output, s2(d2_output)])

    e2_output = e2(e3_d2_concat)
    e2_d1_concat = keras.layers.concatenate([e2_output, s1(d1_output)])

    e1_output = e1(e2_d1_concat)
    e1_d0_concat = keras.layers.concatenate([e1_output, s0(d0_output)])
    
    e0_output = e0(e1_d0_concat)
    
    r = e0_output

    output = keras.layers.Conv2D(config.size[-1], kernel_size=3, strides=1, padding='same')(r)

    return keras.models.Model(inputs=input, outputs=output)

if __name__ == "__main__":
    model = get_model()
    print(model.summary())