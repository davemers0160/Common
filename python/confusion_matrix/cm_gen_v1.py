import os
import math
import numpy as np

from bokeh import events
from bokeh.io import curdoc, output_file
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider, Legend, CustomJS, HoverTool, LinearColorMapper, CategoricalColorMapper
from bokeh.plotting import figure, show, output_file
from bokeh.layouts import column, row, Spacer
from bokeh.palettes import Magma, Magma256, magma, viridis
from bokeh.sampledata.periodic_table import elements
from bokeh.transform import dodge, factor_cmap, transform

import pandas as pd

# File dialog stuff
from PyQt5.QtGui import QIcon
from PyQt5.QtWidgets import QFileDialog, QWidget, QApplication

app = QApplication([""])

output_file("periodic.html")

##-----------------------------------------------------------------------------
def blues(n):

    index = np.transpose(np.arange(n) * (12 / (n-1)))

    color_map = np.empty((n, 3), dtype=np.uint8)

    color_map[:, 0] = np.floor(255*(-0.0724*index + 0.93)).astype(np.uint8)
    color_map[:, 1] = np.floor(255*(-0.0541*index + 0.95)).astype(np.uint8)
    color_map[:, 2] = np.floor(255*(-0.0350*index + 1.00)).astype(np.uint8)

    return color_map


def rgb2hex(data):
    data = np.maximum(0, np.minimum(data, 255))

    cm = []

    for idx in range(data.shape[0]):
        # print("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))
        cm.append("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))

    return cm


def get_input(start_path):
    # global detection_windows, results_div, filename_div, image_path, rgba_img

    file_name = QFileDialog.getOpenFileName(None, "Select a confusion matrix csv file",  start_path, "Text Files (*.txt);;CSV Files (*.csv);;All Files (*.*)")
    filename_text = "File name: " + file_name[0]
    if(file_name[0] == ""):
        return

    print("Processing File: ", file_name[0])
    # load in an image
    # file_path = os.path.dirname(file_name[0])
    # color_img = cv.imread(image_name[0])

    cm_data = pd.read_csv(file_name[0], header=None).values

    # convert the image to RGBA for display
    # rgba_img = cv.cvtColor(color_img, cv.COLOR_RGB2RGBA)
    # p1_src.data = {'input_img': [np.flipud(rgba_img)]}
    #p1.image_rgba(image=[np.flipud(rgba_img)], x=0, y=0, dw=400, dh=400)

    # run_detection(color_img)
    # update_plots()

    return cm_data

##-----------------------------------------------------------------------------

start_path = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

# plot specific variables that are used in plot formatting (size/color)...
cm_plot_h = 800
cm_plot_w = 1500
err_plot_h = 130
err_plot_w = cm_plot_w

cm_colors = rgb2hex(blues(200))
error_colors = ["#00FF00", "#FFA700", "#FF0000"]

# cm_data = pd.read_csv('D:/Projects/dfd/dfd_dnn_analysis/results/tb23b_test/tb23b_confusion_matrix_results.txt', header=None).values
cm_data = get_input(start_path)

cm_data_size = cm_data.shape[0]

# cm_err_data = 127/128*np.ones(23, dtype=np.float32)*100
dm_min = 0
dm_max = cm_data_size - 1

# sum up the total number of times a depthmap value is in the dataset
cm_err_sum = np.sum(cm_data, axis=1)

# calculate how many times the prediction is correct
cm_err_diag = np.diag(cm_data)
cm_err_data = 100 * np.divide(cm_err_diag, cm_err_sum, out=np.zeros(cm_err_diag.shape, dtype=np.float32), where=(cm_err_sum != 0))
cm_err_data = np.subtract(100, cm_err_data, out=np.zeros(cm_err_data.shape, dtype=np.float32), where=(cm_err_data != 0))
# np.subtract(np.divide(cm_err_diag, cm_err_sum, out=np.zeros(cm_err_diag.shape, dtype=np.float32), where=(cm_err_sum != 0)), 1, out=np.zeros(cm_err_diag.shape, dtype=np.float32), where=(cm_err_sum != 0))*100
#+ [(4.5*x-95) for x in range(dm_min, dm_max+1)]
# cm_err_data = np.array([0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11])
cm_err_cat = 1*(cm_err_data > 5)+1*(cm_err_data > 10)

# get the min and max for the color shading of the confusion matrix.  Min is assumed to be 0.
cm_min = 0
cm_max = 100 #np.mean(cm_err_diag)

dm_values_str = [str(x) for x in range(dm_min, dm_max+1)]

cm_df = pd.DataFrame(data=cm_data, index=dm_values_str, columns=dm_values_str)
cm_df.index.name = "Actual"
cm_df.columns.name = "Predicted"
cm_df = cm_df.stack().rename("value").reset_index()
cm_df['color_value'] = 100 * np.divide(cm_data, cm_err_sum, out=np.zeros(cm_data.shape, dtype=np.float32), where=(cm_err_sum != 0)).reshape(-1)
cm_source = ColumnDataSource(cm_df)


cm_values_str = ["{:4.2f}%".format(cm_err_data[x]) for x in range(dm_min, dm_max+1)]

cm_err_df = pd.DataFrame(data=cm_err_data.reshape(1, -1), index=["1"], columns=dm_values_str)
cm_err_df.index.name = 'Error'
cm_err_df.columns.name = 'Label'
cm_err_df = cm_err_df.stack().rename("value").reset_index()
cm_err_df['str_value'] = cm_values_str
cm_err_df['err_cat'] = [str(cm_err_cat[x]) for x in range(dm_min, dm_max+1)]

mapper = LinearColorMapper(palette=cm_colors, low=cm_min, high=cm_max)

text_mapper = LinearColorMapper(palette=["#000000", "#FFFFFF"], low=75, high=cm_max)


p = figure(plot_width=cm_plot_w, plot_height=cm_plot_h,
           x_range=dm_values_str, y_range=list(reversed(dm_values_str)),
           tools="save", toolbar_location="right"
           )

p.rect(x="Predicted", y="Actual", width=1.0, height=1.0, source=cm_source, fill_alpha=1.0, line_color='black',
           fill_color=transform('color_value', mapper))

text_props = {"source": cm_source, "text_align": "center", "text_font_size": "13px", "text_baseline": "middle", "text_font_style": "bold"}

x = dodge("Predicted", 0.0, range=p.x_range)

r = p.text(x=x, y="Actual", text=str("value"), text_color=transform('color_value', text_mapper), **text_props)

p.axis.major_tick_line_color = None
p.grid.grid_line_color = None

# x-axis formatting
p.xaxis.major_label_text_font_size = "13pt"
p.xaxis.major_label_text_font_style= "bold"
p.xaxis.axis_label_text_font_size = "16pt"
p.xaxis.axis_label_text_font_style = "bold"
p.xaxis.axis_label = "Predicted Depthmap Values"

# y-axis formatting
p.yaxis.major_label_text_font_size = "13pt"
p.yaxis.major_label_text_font_style= "bold"
p.yaxis.axis_label_text_font_size = "16pt"
p.yaxis.axis_label_text_font_style = "bold"
p.yaxis.axis_label = "Actual Depthmap Values"


p2 = figure(plot_width=err_plot_w, plot_height=err_plot_h,
           y_range="1", x_range=dm_values_str,
           tools="save", toolbar_location="below"
           )

p2.rect(x="Label", y="Error", width=1.0, height=1.0, source=ColumnDataSource(cm_err_df), fill_alpha=1.0, line_color='black',
       fill_color=transform('err_cat', CategoricalColorMapper(palette=error_colors, factors=["0", "1", "2"])))


r2 = p2.text(x="Label", y="Error", text="str_value", source=ColumnDataSource(cm_err_df), text_align="center",
             text_color=transform('err_cat', CategoricalColorMapper(palette=["#000000", "#000000", "#FFFFFF"], factors=["0", "1", "2"])),
             text_font_size="13px", text_baseline="middle", text_font_style="bold")

p2.axis.major_tick_line_color = None
p2.grid.grid_line_color = None
# p2.xaxis.major_label_text_font_size = '0pt'  # turn off x-axis tick labels
p2.yaxis.major_label_text_font_size = '0pt'  # turn off y-axis tick labels
p2.xaxis.major_label_text_font_size = "13pt"
p2.xaxis.major_label_text_font_style= "bold"
p2.xaxis.axis_label_text_font_size = "16pt"
p2.xaxis.axis_label_text_font_style = "bold"
p2.xaxis.axis_label = "Actual Depthmap Errors"

layout = column(p, Spacer(height=20), p2)

show(layout)

bp = 1

