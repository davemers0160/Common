import numpy as np
import math

from bokeh import events
from bokeh.io import curdoc, output_file
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider, Legend, CustomJS, HoverTool, LinearColorMapper
from bokeh.plotting import figure, show, output_file
from bokeh.layouts import column, row, Spacer
from bokeh.palettes import Magma, Magma256, magma, viridis
from bokeh.sampledata.periodic_table import elements
from bokeh.transform import dodge, factor_cmap, transform

import pandas as pd
output_file("periodic.html")

def blues(n):

    index = np.transpose(np.arange(n) * (12 / (n-1)))

    color_map = np.empty((n, 3), dtype=np.uint8)

    color_map[:, 0] = np.floor(255*(-0.0724*index + 0.90)).astype(np.uint8)
    color_map[:, 1] = np.floor(255*(-0.0541*index + 0.92)).astype(np.uint8)
    color_map[:, 2] = np.floor(255*(-0.0350*index + 1.00)).astype(np.uint8)

    return color_map


def rgb2hex(data):
    data = np.maximum(0, np.minimum(data, 255))

    cm = []

    for idx in range(data.shape[0]):
        # print("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))
        cm.append("#{0:02X}{1:02x}{2:02x}".format(data[idx, 0], data[idx, 1], data[idx, 2]))

    return cm


cm_plot_h = 800
cm_plot_w = 1400
err_plot_h = cm_plot_h
err_plot_w = 80

# cm_data = np.array([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 29, 0, 1, 29, 323, 3, 0, 0, 0, 0, 0, 48, 2621007]])

cm_data = np.array([[180893, 3142, 64, 68, 25, 18, 29, 99, 3, 6, 37, 29, 22, 0, 19, 65, 24, 34, 23, 60, 26, 65, 116],
                    [15061, 223222, 4625, 74, 84, 23, 61, 57, 14, 21, 21, 47, 70, 73, 35, 102, 49, 75, 53, 28, 26, 97, 16],
                    [75, 4129, 210703, 118, 49, 28, 33, 27, 4, 4, 12, 34, 30, 33, 46, 34, 4, 62, 40, 22, 21, 66, 47],
                    [442, 128, 193, 317581, 398, 17, 62, 54, 62, 71, 28, 81, 63, 26, 64, 55, 77, 102, 77, 41, 75, 136, 85],
                    [148, 48, 66, 150, 299886, 726, 102, 82, 88, 20, 39, 56, 66, 31, 80, 27, 47, 159, 18, 86, 56, 165, 10],
                    [6, 14, 15, 17, 29, 193427, 525, 45, 5, 101, 49, 41, 18, 23, 99, 81, 45, 22, 59, 19, 46, 87, 56],
                    [47, 39, 45, 61, 106, 420, 379589, 1390, 156, 114, 90, 13, 87, 65, 77, 83, 98, 145, 87, 111, 166, 157, 96],
                    [106, 37, 55, 48, 88, 142, 1680, 351654, 489, 50, 87, 115, 82, 50, 67, 131, 125, 217, 179, 52, 156, 157, 192],
                    [52, 7, 36, 63, 59, 13, 94, 481, 279054, 266, 136, 93, 35, 51, 73, 116, 86, 198, 102, 37, 103, 226, 131],
                    [62, 14, 8, 41, 28, 82, 67, 41, 306, 431253, 994, 190, 168, 60, 189, 216, 150, 157, 199, 91, 208, 441, 387],
                    [75, 11, 10, 30, 26, 40, 77, 173, 100, 789, 466890, 496, 325, 52, 150, 156, 125, 286, 418, 144, 53, 310, 487],
                    [44, 20, 34, 31, 83, 20, 2, 123, 83, 87, 277, 430505, 1405, 131, 382, 325, 162, 103, 295, 70, 219, 409, 55],
                    [55, 11, 22, 83, 43, 43, 61, 113, 130, 457, 517, 1837, 595014, 896, 476, 436, 445, 358, 515, 173, 86, 620, 576],
                    [3, 14, 21, 13, 33, 44, 55, 59, 86, 101, 77, 119, 327, 381548, 1681, 255, 204, 291, 141, 269, 72, 507, 186],
                    [109, 18, 27, 57, 49, 38, 71, 87, 172, 297, 295, 468, 673, 2654, 689267, 1320, 656, 267, 304, 252, 253, 805, 532],
                    [84, 25, 34, 63, 35, 112, 231, 265, 215, 382, 240, 446, 695, 610, 1725, 820302, 5634, 692, 566, 189, 595, 960, 368],
                    [29, 35, 5, 51, 32, 50, 96, 118, 92, 240, 103, 190, 491, 316, 617, 2805, 585703, 1831, 475, 331, 197, 670, 351],
                    [91, 33, 63, 65, 122, 24, 160, 173, 149, 143, 328, 143, 396, 514, 525, 1225, 5842, 945741, 1425, 814, 389, 1076, 615],
                    [80, 67, 35, 49, 28, 99, 168, 201, 99, 169, 704, 316, 560, 278, 516, 933, 1393, 2926, 827137, 8185, 982, 912, 1633],
                    [105, 38, 16, 31, 76, 25, 209, 94, 59, 143, 209, 182, 356, 477, 558, 541, 899, 1828, 8917, 579455, 1538, 1578, 2512],
                    [212, 67, 44, 119, 113, 96, 187, 230, 127, 319, 172, 382, 98, 147, 525, 678, 472, 704, 1972, 1609, 818971, 7634, 2106],
                    [123, 109, 109, 118, 210, 108, 218, 168, 275, 693, 520, 892, 963, 767, 1128, 1369, 1573, 1848, 2502, 3954, 16561, 1997608, 26796],
                    [81, 16, 92, 44, 5, 54, 140, 157, 163, 404, 636, 23, 581, 254, 444, 305, 593, 509, 1231, 1902, 2198, 11272, 842610]])

# cm_err_data = 127/128*np.ones(23, dtype=np.float32)*100
dm_min = 0
dm_max = 22

cm_err_sum = np.sum(cm_data, axis=1)

cm_err_data = (np.diag(cm_data)/cm_err_sum)*100 + [(4.5*x-95) for x in range(dm_min, dm_max+1)]

cm_min = np.min(cm_data)
cm_max = np.max(cm_data)
cm_max = 100000


dm_values_str = [str(x) for x in range(dm_min, dm_max+1)]

df2 = pd.DataFrame(data=cm_data, index=dm_values_str, columns=dm_values_str)
df2.index.name = 'Actual'
df2.columns.name = 'Predicted'

df2 = df2.stack().rename("value").reset_index()

cm_values_str = ["{:3.1f}%".format(cm_err_data[x]) for x in range(dm_min, dm_max+1)]

cm_err_df = pd.DataFrame(data=cm_err_data, index=dm_values_str, columns=["1"])
cm_err_df.index.name = 'Error'
cm_err_df.columns.name = 'Label'
cm_err_df = cm_err_df.stack().rename("value").reset_index()
cm_err_df['str_value'] = cm_values_str

# this is the colormap from the original NYTimes plot
# colors = ["#FFFFFF", "#a5bab7", "#c9d9d3", "#e2e2e2", "#dfccce", "#ddb7b1", "#cc7878", "#933b41", "#0000EE"]
# colors = list(reversed(['#084594', '#2171b5', '#4292c6', '#6baed6', '#9ecae1', '#c6dbef', '#deebf7', '#f7fbff']))
# colors = list(reversed(magma(250)))
colors = rgb2hex(blues(200))

mapper = LinearColorMapper(palette=colors, low=cm_min, high=cm_max)
source = ColumnDataSource(df2)

# p = figure(title="Periodic Table", plot_width=1000, plot_height=450,
#            x_range=groups, y_range=list(reversed(periods)),
#            tools="hover, save")

# r = p.rect("group", "period", 0.95, 0.95, source=df, fill_alpha=0.6, legend_field="metal",
#            color=factor_cmap('metal', palette=list(cmap.values()), factors=list(cmap.keys())))

p = figure(plot_width=cm_plot_w, plot_height=cm_plot_h,
           x_range=dm_values_str, y_range=list(reversed(dm_values_str)),
           tools="", toolbar_location=None
           )

p.rect(x="Predicted", y="Actual", width=1.0, height=1.0, source=source, fill_alpha=0.6, line_color='black',
           fill_color=transform('value', mapper))

text_props = {"source": source, "text_align": "center", "text_font_size": "13px", "text_baseline": "middle"}

x = dodge("Predicted", 0.0, range=p.x_range)

r = p.text(x=x, y="Actual", text=str("value"), **text_props)
r.glyph.text_font_style = "bold"

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
           x_range="1", y_range=list(reversed(dm_values_str)),
           tools="", toolbar_location=None
           )

p2.rect(x="Label", y="Error", width=1.0, height=1.0, source=ColumnDataSource(cm_err_df), fill_alpha=0.6, line_color='black',
       fill_color=transform('value', LinearColorMapper(palette=colors, low=0, high=100)))

r2 = p2.text(x="Label", y="Error", text="str_value", source=ColumnDataSource(cm_err_df), text_align="center", text_font_size="13px", text_baseline="middle")
r2.glyph.text_font_style = "bold"

p2.axis.major_tick_line_color = None
p2.grid.grid_line_color = None
p2.xaxis.major_label_text_font_size = '0pt'  # turn off x-axis tick labels
p2.yaxis.major_label_text_font_size = '0pt'  # turn off y-axis tick labels

layout = row(p, Spacer(width=20), p2)


show(layout)

bp = 1

