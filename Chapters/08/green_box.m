%% INITIALISATION
clear all
clc
close all
format long


%% LOAD AND PRE-PROCESS DATA
% System to be identified.
load y_cc.csv
load u_cc.csv

% Downsample the measured output and input signals.
yData = y_cc(1:500:250000)';
uData = u_cc(1:500:250000);

% Normalise signals using the absolute value of their maximum sample.
yData = yData / abs(max(yData));
uData = uData / abs(max(uData));


%% MODEL STRUCTURE CONFIGURATION
% Maximum output and input lags.
lagY = 2;
lagU = 2;

% Generate the complete set of candidate terms.
terms = genterms(2, lagY, lagU, 0);

% Number of available candidate terms for genterms(2,2,2).
numberOfAvailableTerms = size(terms, 1);


%% TRAINING AND VALIDATION DATASETS
% Training data.
uTrain = uData(1:250);
yTrain = yData(1:250);

% Validation data.
uVal = uData(251 + lagY:end);
yVal = yData(251 + lagY:end);


%% STORAGE VARIABLES
nrmseAll     = [];
operationAll = [];
ySimAll      = {};


%% EXHAUSTIVE MODEL EVALUATION
% Evaluate models with different numbers of terms.
for nTerms = 7:12

    nrmseCurrent      = [];
    operationsCurrent = [];
    ySimValidCurrent  = {};

    % Generate all possible combinations with nTerms selected terms.
    termCombinations = nchoosek(1:numberOfAvailableTerms, nTerms);
    numberOfModels   = size(termCombinations, 1);

    for modelIdx = 1:numberOfModels

        %% BUILD CURRENT MODEL STRUCTURE
        model = terms(termCombinations(modelIdx, :), :);


        %% PARAMETER ESTIMATION
        % Estimate model parameters using orthogonal regression.
        [m, x] = orthreg(model, uTrain, yTrain', [nTerms 0], 0);

        theta = x(:, 1);

        % Retrieve model information.
        [npr, nno, lag, ny, nu, ne, newmodel] = get_info(m); %#ok<ASGLU>


        %% COMPUTATIONAL COST ESTIMATION
        % Base bit cost associated with the number of terms.
        bitCost = (nTerms - 1) * 64;

        % Additional cost according to the type of each term.
        for termIdx = 1:nTerms

            currentTerm = model(termIdx, :);

            if all(currentTerm == 0)
                % Constant term: no additional bit cost.

            elseif any(currentTerm == 0)
                % Linear term.
                bitCost = bitCost + 64^1.585;

            else
                % Non-linear term with two non-zero components.
                bitCost = bitCost + 2 * (64^1.585);
            end
        end


        %% DISCARD INVALID PARAMETER SETS
        if any(isnan(theta)) || any(isinf(theta))
            continue
        end


        %% MODEL SIMULATION
        % Simulate the model over the validation dataset.
        ySim = simodeld(m, theta, uVal, yData(251:250 + lagY)');

        % Discard invalid simulations.
        if any(isnan(ySim)) || any(isinf(ySim))
            continue
        end

        ySim = ySim';


        %% VALIDATION METRIC: NRMSE
        numerator   = (yVal - ySim) * (yVal - ySim)';
        denominator = (yVal - mean(ySim)) * (yVal - mean(ySim))';

        if denominator <= 0
            continue
        end

        nrmseCandidate = sqrt(numerator) / sqrt(denominator);


        %% STORE VALID MODELS
        if nrmseCandidate < 1

            nrmseCurrent      = [nrmseCurrent; nrmseCandidate];
            operationsCurrent = [operationsCurrent; bitCost];

            % Store the time response of each valid model.
            ySimValidCurrent{end + 1, 1} = ySim;
        end
    end


    %% APPEND RESULTS FOR THE CURRENT NUMBER OF TERMS
    nrmseAll     = [nrmseAll; nrmseCurrent];
    operationAll = [operationAll; operationsCurrent];
    ySimAll      = [ySimAll; ySimValidCurrent];
end


%% CONVERT COMPUTATIONAL COST TO CO2 EQUIVALENT
co2All = operationAll * 6.0190e-4;


%% PARETO FRONT IDENTIFICATION
paretoMatrix = [co2All, nrmseAll];

% Identify non-dominated solutions.
paretoIdx = getNonDominated(paretoMatrix);

% Sort Pareto-front points by CO2 emissions.
paretoPoints = paretoMatrix(paretoIdx, :);
[~, sortOrder] = sort(paretoPoints(:, 1));

paretoIdxSorted = paretoIdx(sortOrder);

% First and last models on the Pareto front.
idxFirst = paretoIdxSorted(1);       % Lowest CO2 on the Pareto front.
idxLast  = paretoIdxSorted(end);     % Highest CO2 on the Pareto front.

% Time responses of the selected Pareto-front models.
ySimParetoFirst = ySimAll{idxFirst};
ySimParetoLast  = ySimAll{idxLast};

% CO2 and NRMSE values of the selected Pareto-front models.
co2First = co2All(idxFirst);
co2Last  = co2All(idxLast);

nrmseFirst = nrmseAll(idxFirst);
nrmseLast  = nrmseAll(idxLast);


%% GENERAL PLOT CONFIGURATION
lineWidth   = 2;
width       = 2;
fontSize    = 20;
markerSize  = 10;
axesWidth   = 2;

figurePosition = [5 3 18 18];    % [left bottom width height] in centimetres.
rendererOption = 'Painters';

colourMapH = bone(20);
colourMapT = pink(20);
colourMapT = flipud(colourMapT);


%% PLOT: PARETO FRONT
paretoX = co2All(paretoIdxSorted);
paretoY = nrmseAll(paretoIdxSorted);

figure
set(gcf, ...
    'Units', 'centimeters', ...
    'Position', figurePosition, ...
    'Renderer', rendererOption);

plot(paretoX, paretoY, 'k-', 'LineWidth', width)
hold on

% Select marker colours safely, regardless of the number of Pareto points.
colourIdx = round(linspace(14, 2, length(paretoX)));
colourIdx = max(1, min(size(colourMapT, 1), colourIdx));

for k = 1:length(paretoX)

    plot(paretoX(k), paretoY(k), 'o', ...
        'MarkerSize', markerSize, ...
        'MarkerFaceColor', colourMapT(colourIdx(k), :), ...
        'MarkerEdgeColor', colourMapT(colourIdx(k), :));

    label = sprintf('(%.1f, %.3f)', paretoX(k), paretoY(k));

    text(paretoX(k), paretoY(k), label, ...
        'FontSize', fontSize, ...
        'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'left');
end

hold off

hX = xlabel('$\mu gCO_2e$', 'FontSize', fontSize);
hY = ylabel('NRMSE', 'FontSize', fontSize);

ax = gca;
set(ax, ...
    'LineWidth', axesWidth, ...
    'FontSize', fontSize);

set([hX, hY], 'Interpreter', 'latex')

axis square
grid off
box off


%% PLOT: ALL VALID MODELS
allModelColourMap = pink(20);

figure
set(gcf, ...
    'Units', 'centimeters', ...
    'Position', figurePosition, ...
    'Renderer', rendererOption);

plot(co2All, nrmseAll, 'o', ...
    'LineWidth', 1, ...
    'Color', allModelColourMap(2, :))

hX = xlabel('$\mu gCO_2e$');
hY = ylabel('NRMSE');

ax = gca;
set(ax, ...
    'LineWidth', axesWidth, ...
    'FontSize', fontSize);

set([hX, hY], 'Interpreter', 'latex')

axis square
grid off
box off


%% BOXPLOT: NRMSE GROUPED BY CO2 EQUIVALENT
co2Group = round(co2All, 1);

figure
set(gcf, ...
    'Units', 'centimeters', ...
    'Position', figurePosition, ...
    'Renderer', rendererOption);

boxplot(nrmseAll, co2Group, ...
    'Symbol', '+', ...
    'OutlierSize', 6, ...
    'Widths', 0.6, ...
    'Colors', 'k');

hold on

% Box outline.
set(findobj(gca, 'Tag', 'Box'), ...
    'Color', colourMapH(6, :), ...
    'LineWidth', 1.5);

% Median line.
set(findobj(gca, 'Tag', 'Median'), ...
    'Color', colourMapT(10, :), ...
    'LineWidth', lineWidth);

% Whiskers.
set(findobj(gca, 'Tag', 'Whisker'), ...
    'Color', 'k', ...
    'LineStyle', '--', ...
    'LineWidth', 1.5);

% Upper and lower adjacent values.
set(findobj(gca, 'Tag', 'Upper Adjacent Value'), ...
    'Color', 'k', ...
    'LineWidth', 1.8);

set(findobj(gca, 'Tag', 'Lower Adjacent Value'), ...
    'Color', 'k', ...
    'LineWidth', 1.8);

% Outliers.
set(findobj(gca, 'Tag', 'Outliers'), ...
    'Marker', '+', ...
    'MarkerEdgeColor', colourMapT(10, :), ...
    'LineWidth', 0.8, ...
    'MarkerSize', 6);

hold off

hX = xlabel('$\mu gCO_2e$', 'FontSize', fontSize);
hY = ylabel('NRMSE', 'FontSize', fontSize);

ax = gca;
set(ax, ...
    'LineWidth', axesWidth, ...
    'FontSize', fontSize);

set([hX, hY], 'Interpreter', 'latex')

grid off
box off
xtickangle(45)


%% TIME RESPONSE: VALIDATION DATA AND PARETO-FRONT EXTREMES
sampleIdx = 1:length(yVal);

figure
set(gcf, ...
    'Units', 'centimeters', ...
    'Position', figurePosition, ...
    'Renderer', rendererOption);

plot(sampleIdx, yVal, '-', ...
    'LineWidth', 3.2, ...
    'Color', colourMapH(1, :))

hold on

plot(sampleIdx, ySimParetoFirst, '-', ...
    'LineWidth', 2.5, ...
    'Color', colourMapT(12, :))

plot(sampleIdx, ySimParetoLast, '-.', ...
    'LineWidth', 1.8, ...
    'Color', colourMapT(4, :))

hold off

hX = xlabel('Sample', 'FontSize', fontSize);
hY = ylabel('Angular Velocity [rpm]', 'FontSize', fontSize);

legend({ ...
    'Validation Data', ...
    sprintf('$\\mu gCO_2e$ = %.3f, NRMSE = %.3f', co2First, nrmseFirst), ...
    sprintf('$\\mu gCO_2e$ = %.3f, NRMSE = %.3f', co2Last, nrmseLast)}, ...
    'Location', 'best', ...
    'Interpreter', 'latex');

ax = gca;
set(ax, ...
    'LineWidth', axesWidth, ...
    'FontSize', fontSize);

set([hX, hY], 'Interpreter', 'latex')

grid off
box off
axis tight


%% INTERACTIVE ZOOM
% Add a zoomed region to the current figure.
zoomPlot = BaseZoom();
zoomPlot.run;