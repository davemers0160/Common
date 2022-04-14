import platform
import os

# numpy
import numpy as np
import cv2 as cv

# File dialog stuff
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QFileDialog, QWidget, QApplication

import pandas as pd
from bokeh.io import curdoc
from bokeh.models import ColumnDataSource, Spinner, HoverTool, Button, Div, Slider, LinearColorMapper
from bokeh.plotting import figure, show
from bokeh.layouts import column, row, Spacer
from bokeh.transform import dodge, factor_cmap, transform

# set up some global variables that will be used throughout the code
script_path = os.path.realpath(__file__)
iq_filename = ""
iq_data_path = os.path.dirname(os.path.dirname(script_path))

iq_data = []

spin_width = 110

app = QApplication([""])

# source for the spectrogram
spectrogram_source = ColumnDataSource(data=dict(spectrogram_data=[], freq_range=[], time_range=[]))

# interactive control definitions
fft_length = Spinner(title="FFT Length", low=2, high=2**32, step=2, value=32, width=spin_width)
fft_overlap = Spinner(title="FFT Overlap", low=0, high=2**32, step=1, value=0, width=spin_width)
sample_rate = Spinner(title="Sample Rate (MHz)", low=0, high=2000, step=0.1, value=20, width=spin_width)
start_time = Spinner(title="Start Time (s)", low=0, high=2e9, step=0.000001, value=0, width=spin_width)
stop_time = Spinner(title="Stop Time (s)", low=0, high=2e9, step=0.000001, value=1, width=spin_width)

# define the main plot
spectrogram_fig = figure(plot_height=800, plot_width=1300)


# -----------------------------------------------------------------------------
def jet_clamp(v):
    v[v < 0] = 0
    v[v > 1] = 1
    return v

def blues(n):

    index = np.transpose(np.arange(n) * (12 / (n-1)))

    color_map = np.empty((n, 3), dtype=np.uint8)

    color_map[:, 0] = np.floor(255*(-0.0724*index + 0.93)).astype(np.uint8)
    color_map[:, 1] = np.floor(255*(-0.0541*index + 0.95)).astype(np.uint8)
    color_map[:, 2] = np.floor(255*(-0.0350*index + 1.00)).astype(np.uint8)

    return color_map

# -----------------------------------------------------------------------------
def jet(n):

    t_max = n
    t_min = 0
    t_range = t_max - t_min

    p1 = t_min + t_range * (1 / 4)
    p2 = t_min + t_range * (2 / 4)
    p3 = t_min + t_range * (3 / 4)

    color_map = np.empty((n, 3), dtype=np.uint8)

    color_map[:, 0] = (255*jet_clamp((1.0 / (p3 - p2)))).astype(np.uint8)
    color_map[:, 1] = (255*jet_clamp(2.0 - (1.0 / (p1 - t_min)))).astype(np.uint8)
    color_map[:, 2] = (255*jet_clamp((1.0 / (p1 - p2)))).astype(np.uint8)

    return color_map


def rgb2hex(data):
    data = np.maximum(0, np.minimum(data, 255))

    cm = []

    for idx in range(data.shape[0]):
        # print("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))
        cm.append("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))

    return cm


# -----------------------------------------------------------------------------
def generate_spectrogram(iq_data, N, O, fs):

    S = []
    for k in range(0, iq_data.shape[0] + 1, N-O):
        x = np.fft.fftshift(np.fft.fft(iq_data[k:k + N], n=N))//N
        # assert np.allclose(np.imag(x*np.conj(x)), 0)
        Pxx = 20 * np.log10(np.real(x*np.conj(x)))
        S.append(Pxx)

    S = np.array(S)

    # Frequencies:
    f = np.fft.fftshift(np.fft.fftfreq(N, d=1 / fs))

    # Time Range:
    t = np.fft.fftfreq(N, d=1 / fs)

    return S, f, t


def update_plot(attr, old, new):
    global iq_data

    spectrogram_data, f, t = generate_spectrogram(iq_data, fft_length.value, fft_overlap.value, sample_rate.value*1e6)

    s_min = np.min(spectrogram_data)
    s_max = np.max(spectrogram_data)

    # frequency string
    freq_min = f[0]
    freq_max = f[-1]
    # freq_values_str = [str(x) for x in range(freq_min, freq_max+1)]
    freq_values_str = [str(x) for x in np.linspace(freq_min, freq_max, f.shape[0])]

    # time string
    time_min = t[0]
    time_max = t[-1]
    # time_values_str = [str(x) for x in range(time_min, time_max+1)]
    time_values_str = [str(x) for x in np.linspace(freq_min, freq_max, spectrogram_data.shape[0])]

    spectrogram_df = pd.DataFrame(data=spectrogram_data, index=time_values_str, columns=freq_values_str)
    spectrogram_df.index.name = "Time"
    spectrogram_df.columns.name = "Frequency"
    spectrogram_df = spectrogram_df.stack().rename("value").reset_index()
    spectrogram_df['color_value'] = spectrogram_data.reshape(-1)

    spectrogram_source = ColumnDataSource(spectrogram_df)

    # update the cm_fig X and Y values
    # spectrogram_fig.x_range.factors = freq_values_str
    # spectrogram_fig.y_range.factors = time_values_str

    cm_colors = rgb2hex(blues(200))
    cm_mapper = LinearColorMapper(palette=cm_colors, low=s_min, high=s_max)

    spectrogram_fig.rect(x="Frequency", y="Time", width=1.0, height=1.0, source=spectrogram_source, fill_alpha=1.0, line_color='black',
                fill_color=transform('color_value', cm_mapper))


# -----------------------------------------------------------------------------
def get_input():
    global iq_filename, iq_data_path, iq_data

    iq_filename = QFileDialog.getOpenFileName(None, "Select a file",  iq_data_path, "IQ files (*.bin *.dat);;All files (*.*)")
    filename_div.text = "File name: " + iq_filename[0]
    if(iq_filename[0] == ""):
        return

    print("Processing File: ", iq_filename[0])
    # load in an image
    iq_data_path = os.path.dirname(iq_filename[0])
    x = np.fromfile(iq_filename[0], dtype=np.int16, count=-1, sep='', offset=0).astype(np.float32)

    # convert x into a complex numpy array
    x2 = x.reshape(-1, 2)

    iq_data = np.empty(x2.shape[0], dtype=complex)
    iq_data.real = x2[:, 0]
    iq_data.imag = x2[:, 1]

    # color_img = cv.imread(iq_filename[0])

    # convert the image to RGBA for display
    # rgba_img = cv.cvtColor(color_img, cv.COLOR_RGB2RGBA)
    # p1_src.data = {'input_img': [np.flipud(rgba_img)]}
    #p1.image_rgba(image=[np.flipud(rgba_img)], x=0, y=0, dw=400, dh=400)

    # run_detection(color_img)
    update_plot(1, 1, 1)


# the main entry point into the code
file_select_btn = Button(label='Select File', width=100)
file_select_btn.on_click(get_input)
filename_div = Div(width=800, text="File name: ", style={'font-size': '100%', 'font-weight': 'bold'})

# color palettes for plotting
cm_colors = rgb2hex(blues(200))
cm_mapper = LinearColorMapper(palette=cm_colors, low=-100, high=0)

get_input()


# setup the event callbacks for the plot
for w in [fft_length, fft_overlap, sample_rate, start_time, stop_time]:
    w.on_change('value', update_plot)


# create the layout for the controls
btn_layout = row(Spacer(width=30), file_select_btn, Spacer(width=10), filename_div)
input_layout = column(fft_length, fft_overlap, sample_rate, start_time, stop_time)

layout = column(btn_layout, row(input_layout, Spacer(width=20, height=20), spectrogram_fig))

#show(layout)

doc = curdoc()
doc.title = "Confusion Matrix Viewer"
doc.add_root(layout)

