import PySimpleGUI as gui
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
# TODO: Import all the files such as triangulation, gccphat etc
import numpy as np

def grid():
    grid, ax = plt.subplots()
    ax.set_xlim(0, 50)
    ax.set_ylim(0, 50)
    ax.set_xlabel('X-axis')
    ax.set_ylabel('Y-axis')
    ax.grid(True)
    return grid

def plot_source(grid, x, y):
    ax = grid.gca()
    ax.plot(x, y, marker='x', markersize=10, color='blue', label='Sound source')
    ax.legend()
    return grid

def draw_figure(canvas, figure):
    figure_canvas_agg = FigureCanvasTkAgg(figure, canvas)
    figure_canvas_agg.draw()
    figure_canvas_agg.get_tk_widget().pack(side="top", fill="both", expand=1)
    return figure_canvas_agg

# Define PySimpleGUI layout
layout = [[gui.Canvas(key='canvas')],
          [gui.Button('Start'), gui.Button('Exit')],
]

# Create initial empty grid plot
fig = grid()

# Create PySimpleGUI window
window = gui.Window('Sound Source Localization', layout, resizable=True, finalize=True, element_justification='center')

# Get the canvas element
canvas_elem = window['canvas']
canvas = canvas_elem.Widget

canvas_elem.Widget = FigureCanvasTkAgg(fig, master=canvas)
canvas_elem.Widget.draw()
canvas_elem.Widget.get_tk_widget().pack(side='top', fill='both', expand=1)

while True:
    event, values = window.read()

    if event in (gui.WIN_CLOSED, 'Exit'):
        break
    elif event == 'Start':    # This portion of the code needs to be changed to actually start the system
        try:
            # All completed by importing files and using the relevant functions
            # TODO: Read the files 
            # TODO: Separate the File
            # TODO: Pass files through the filter
            # TODO: GCCPhat 
            # TODO: Triangulation 
            x = 20
            y = 30

            if 0 <= x <= 50 and 0 <= y <= 50:
                fig = plot_source(fig, x, y)
                canvas_elem.Widget.draw()
            else:
                gui.popup_error('Invalid input. X and Y values must be within the specified range.')
        except ValueError:
            gui.popup_error('Invalid input. Please enter valid numeric values for X and Y.')

window.close()
