% Create a figure with UIAxes
fig = uifigure('Name', 'Sound Source Localization');

% Create a layout for buttons and axes
mainLayout = uigridlayout(fig, [1, 3]);
mainLayout.RowHeight = {30}; % Adjust the height as needed
mainLayout.ColumnWidth = {'1x', '1x', '1x'}; % Adjust column widths as needed

% Create UIAxes
ax = uiaxes(mainLayout);
ax.Layout.Row = [1,7];
ax.Layout.Column = [1, 3]; % Span multiple columns
ax.XLim = [0 50];
ax.YLim = [0 50];
xlabel(ax, 'X-axis');
ylabel(ax, 'Y-axis');
grid(ax, 'on');

% Create buttons
startButton = uibutton(mainLayout, 'push', 'Text', 'Start');
clearButton = uibutton(mainLayout, 'push', 'Text', 'Clear');
exitButton = uibutton(mainLayout, 'push', 'Text', 'Exit');

% Set button positions and callbacks
startButton.Layout.Row = 8;
startButton.Layout.Column = 1;
startButton.ButtonPushedFcn = @(btn, event) startButtonCallback(btn, ax);

clearButton.Layout.Row = 8;
clearButton.Layout.Column = 2;
clearButton.ButtonPushedFcn = @(btn, event) clearButtonCallback(ax);

exitButton.Layout.Row = 8;
exitButton.Layout.Column = 3;
exitButton.ButtonPushedFcn = @(btn, event) exitButtonCallback(fig);

% Function to plot the sound source
function startButtonCallback(btn, ax)
    x = 53;
    y = 30;
    
    if 0 <= x && x <= 50 && 0 <= y && y <= 50
        plot(ax, x, y, 'bx', 'MarkerSize', 10, 'DisplayName', 'Sound source');
        legend(ax);
    else
        errordlg('Invalid input. X and Y values must be within the specified range.');
    end
end

% Function to clear the grid
function clearButtonCallback(ax)
    cla(ax);  % Clear the axes
end

% Function to close the figure
function exitButtonCallback(fig)
    delete(fig);
end
