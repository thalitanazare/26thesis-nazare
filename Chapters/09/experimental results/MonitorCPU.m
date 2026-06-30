classdef MonitorCPU
    properties
        executablePath
        outputPath
        data
    end

    methods
        function obj = MonitorCPU(executablePath, outputPath)
            % Constructor
            obj.executablePath = executablePath;
            obj.outputPath = outputPath;
        end
        
        function start(obj)
            % Run the executable and generate the text file
            cmd = ['"', obj.executablePath, '" &'];
            system(cmd);
        end
        
        function [obj, data] = stop(obj)
            msg = system('taskkill /F /IM ProcessorUtilization.exe')

            % Read data from the text file
            % Read the data from the text file
            data = importdata(obj.outputPath);

            % Extract the t and y values into separate arrays
            t = data(:, 1);
            y = data(:, 2);
            elapsedProcessorTime = data(:,3);
            % Create a 2D matrix with t values in the first column and y values in the second column
            data = [t, y, elapsedProcessorTime];
            obj.data = data;
            return
        end

    end
end


